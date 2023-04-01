---
title: Async functions are needlessly killing your Javascript performance
description: I tracked my KDR in Apex for 300days and here is what I found
date: 2023-04-01
tags:
  - Javascript
  - Asynchronous
  - Promise
  - Performance
  - Optimisation
hide:
  - navigation
---

# Async functions are needlessly killing your Javascript performance

There are already quite a few articles around which talk about little quick tips in the Promise APIs to help speed up your Async javascript problems, such as using `Promise.all`, however that isn't what this is about. Just a few simple tweaks to your program can create 1.9x speed ups, and ever more heavy overhauls can easily create a 14x speed BOOST to your program.

Personally I believe all of this performance left on the table is the V8 hasn't given the new asynchronous Javascript features the optimisation love we have came to expect with Javascript, and I think there are a few key signs that really point towards this.

## A little bit of context

Feel free to skip this part, but I'm just going to quickly outline how I got here. I have a [bnf-parser](https://www.npmjs.com/package/bnf-parser) library which so far requires an entire file to be loaded to be able to ingest a file into a syntax tree specified by a BNF, however the way it's written it could easily be written using clonable state generators (so basically a generator which spits out the sequential characters of a file individually, but you can copy it at a given point to return to reading from that point later).

So I tried to implement something similar in Javascript to allow be to parse large +1GB files into partial syntax trees for processing large XML, just partly for fun, partly because I know also soon I'll need to be implementing something similar in a low level language and this could be good practice.

## The Case Study

So I want a in-between layer between my readable stream of data from the disk, and being able to call iteratively forward for small parts of text, with small amounts of pre-define back tracking. So I create a [Cursor](https://github.com/AjaniBilby/BNF-parser/blob/350e9a00fc4ca06acc98245377fb705f00d286b8/source/lib/cache.ts#L7-L45) which can only iterate forwards, each time returning a string of the characters it passes over, and at any point it can be cloned, then the clones can independently move forward. Plus these cursors may need to wait for data currently being streamed before they can return - and for a bit of added difficulty we don't just want to cache the entire file in memory, so we'll discard information which can no longer be reached by any cursor. Also to make the code base nice to maintain we'll use the async/await pattern to avoid any potential nasty callback chains.

So we have a cursor, which has an **async** read call, which then **async**hronously calls to a [StreamCache](https://github.com/AjaniBilby/BNF-parser/blob/350e9a00fc4ca06acc98245377fb705f00d286b8/source/lib/cache.ts#L52-L271) to attempt to read from the cache, plus potentially multiple cursors could be attempting to read the latest information which hasn't been loaded yet, so we'll need a mutex lock situation to kind of wake up those cursors when the information is ready, so we'll need an **async** call to a [PromiseQueue](https://github.com/AjaniBilby/BNF-parser/blob/350e9a00fc4ca06acc98245377fb705f00d286b8/source/lib/promise-queue.ts).

Now if we're reading a `1GB` file, in `100 byte` chunks, that's going to be at least `10000000 IOs` IOs through three layers of asynchronous calls. And this is where the problem start's to be come catastrophic, because these aren't just asynchronous functions, they're actually just a language level abstraction of callbacks, with almost no added level of optimisations which can be inferred from their async nature (don't worry we can add some of these optimisations by hand pretty easily).

## Testing

So let's go through the base implementation, then a few different variations and optimisations; or you can skip ahead to the [results](#results) then work your way backwards if you prefer.

Also just a quick note about the methodology used, each test was ran 10 times instantly after one another from a cold idle start - the first result of each test was always greatly slower than preceding, with the other 9 results being almost identical. This is quite interesting since the tests we queued using CLI, rather than running the function multiple times in Javascript which would create the expected performance improvements over time as V8 optimises the code - however it seems to have done that anyway via some disk caching somewhere temporary, which is why also the cold start between each different test was required.

Also [here is the file](https://dumps.wikimedia.org/simplewiki/latest/simplewiki-latest-pages-articles.xml.bz2) I'm actually streaming in case you're wondering (I'm streaming it already decompressed though)

### Full Async
So we have a cursor which we can call next on, which forwards the request to the [StreamCache](https://github.com/AjaniBilby/BNF-parser/blob/350e9a00fc4ca06acc98245377fb705f00d286b8/source/lib/cache.ts#L52-L271) - which then handles all of the actual read behaviour.

```ts
class Cursor {
  // ...
  async next(highWaterMark = 1): Promise<string> {
    return await this._owner._read(this, highWaterMark);
  }
  // ...
};
```

We then have our main file which just creates a [StreamCache](https://github.com/AjaniBilby/BNF-parser/blob/350e9a00fc4ca06acc98245377fb705f00d286b8/source/lib/cache.ts#L52-L271), adds a cursor, and piping a `fs.createReadStream` in a kind of backwards way to the normal piping API, but this is due to the way `StreamCache` has been implemented to allow for NodeJS and WebJS readable stream API differences.

> The cusor is added before piping to ensure the first bytes of data can't be read into the cache, then dropped because of it being inaccessible by any cursors

```ts
let stream = new experimental.StreamCache();
let cursorA = stream.cursor();
stream.pipe_node(fstream);

async function main() {
  console.time("duration");

  while (!cursorA.isDone()) {
    let val = await cursorA.next(100);
    read += val.length;
  }

  cursorA.drop();

}
fstream.on('end', ()=>{
  console.timeEnd("duration");
});

main();
```

### Wrapper Optimisation

In the cursor before we could see we had an async function basically just acting as a wrapper, if you understand the async abstraction you'd know an async function just returns a promise, so there is no actual need in creating this extra async function, and instead we can just return the one created from the child call. (This has a level of performance benefit it really should't :D)

To:
```ts
class Cursor {
  next(highWaterMark = 1): Promise<string> {
    return this._owner._read(this, highWaterMark);
  }
};
```

### Inlined

In this case we pretended to be a compiler, and inlined our own function, so we literally just embedded the functionality of `StreamCache._read` into where it was being called, which completely broken our public private attribute protections :no_mouth::gun:  
If only there was a compiler like *Typescript* to do inlining safely for us :eyes:

```ts
let stream = new experimental.StreamCache();
let cursorA = stream.cursor();
stream.pipe_node(fstream);

async function main() {
  console.time("duration");

  while (!cursorA.isDone()) {
    if (cursorA._offset < 0) {
      throw new Error("Cursor behind buffer position");
    }

    while (cursorA._offset > stream._total_cache - 100) {
      if (stream._ended) {
        break;
      }

      await stream._signal.wait();
    }

    let loc = stream._offset_to_cacheLoc(cursorA._offset);
    if (loc[0] >= stream._cache.length) {
      return "";
    }

    let out = stream._cache[loc[0]].slice(loc[1], loc[1]+100);
    cursorA._offset += out.length;
    read += out.length;
  }

  cursorA.drop();

}
main();

fstream.on('end', ()=>{
  console.timeEnd("duration");
});
```

### Async With Peaking
If all else fails, avoid async when possible. So in this case I added a few functions.  
Peak will tell me if I can read without waiting, and in which case `_skin_read` is safe to call.  
Otherwise go back to calling the async method.

```js
let stream = new experimental.StreamCache();
let cursorA = stream.cursor();
stream.pipe_node(fstream);

async function main() {
  console.time("duration");

  while (!cursorA.isDone()) {
    let val = cursorA._skip_read(100);
    if (cursorA.isDone()) {
      break;
    }
    read += val.length;
    peaked += val.length;

    if (val == "") {
      let val = await cursorA.next(100);
      read += val.length;
    }
  }

  cursorA.drop();
}
main();

fstream.on('end', ()=>{
  console.timeEnd("duration");
});
```

In this use case this actually save a lot of time because a large amount of the calls didn't actually need to wait due to the load chunk sizes being so large.

| | Bits Read |
|-:|-:|
| Via Async | 919417 |
| Via Peaking | 1173681200
| Total | 1174600617

### Disk Read

As with all good tests, we need a base line - so in this case we don't even have an active cursor, we literally just let data flow in and out of the `StreamCache` as fast as possible giving us the limitation of our disk read, plus the `alloc` and `free` overhead as we add and remove cache pools.

```js
let stream = new experimental.StreamCache();
let cursorA = stream.cursor();
stream.pipe_node(fstream);

async function main() {
  console.time("duration");
  cursorA.drop();

}
main();

fstream.on('end', ()=>{
  console.timeEnd("duration");
});
```

### Callback

Finally we need a test to make sure this isn't a de-optimisation bug, if we go back to the callback hell days, however do we fair?  
Note: I didn't rewrite the `signal.wait()` as trying to create an optimised call back system inside a for loop will be hell on earth to implement. And yes we do need a while loop, because it might take more than one chunk to load in to fulfill the requested read - chunk sizes can be weird sometimes and inconsistent, plus maybe you just want a large chunk read at once :shrug:

```ts
export class StreamCache {
  async read(cursor: Cursor, size = 1, callback: (str: string) => void): Promise<void> {
    if (cursor._offset < 0) {
      throw new Error("Cursor behind buffer position");
    }

    // Wait for more data to load if necessary
    while (cursor._offset > this._total_cache - size) {
      // The required data will never be loaded
      if (this._ended) {
        break;
      }

      // Wait for more data
      //   Warn: state might change here (including cursor)
      await this._signal.wait();
    }

    // Return the data
    let loc = this._offset_to_cacheLoc(cursor._offset);
    if (loc[0] >= this._cache.length) {
      callback("");
    }

    let out = this._cache[loc[0]].slice(loc[1], loc[1]+size);
    cursor._offset += out.length;
    callback(out);
  }
}
```

```ts
function ittr(str: string) {
  read += str.length;
  if (cursorA.isDone()) {
    cursorA.drop();
    return;
  }

  stream.read(cursorA, 100, ittr);
}

async function main() {
  console.time("duration");
  ittr("");
}
main();

fstream.on('end', ()=>{
  console.timeEnd("duration");
});
```

## Results

| Case              | Duration (Min) | Median | Mean | Max |
| :-                | -: | -: | -: | -: |
| Full Async        | 27.742s | 28.339s | 28.946s | 35.203s |
| Async Wrapper Opt | 14.758s | 14.977s | 15.761s | 22.847s |
| Callback          | 13.753s | 13.902s | 14.683s | 21.909s |
| Inlined Async     |  2.025s |  2.048s |  3.037s | 11.847s |
| w/ Peaking        |  1.970s |  2.085s |  3.054s | 11.890s |
| Disk Read         |  1.970s |  1.996s |  2.982s | 11.850s |

It's kind of terrifying how well changing just the wrapper function `Cursor.next` is, it shows that there is easily optimisation improvements available, that plus the inlining `13.9x` performance improvement shows that there is room that even if V8 doesn't get around to implementing something, tools like Typescript certainly could.

Also if you look at the peaking example, we hit quite an interesting limit. In that case only `919417/1173681200` `0.078%` of requests were fulfilled by the async function, meaning only about `9194` of `11746006` requests were waiting for the data to be loaded. This would imply our CPU is almost perfectly being feed by the SSD, and does ask the question, what if we rate limit the read speed to make it closer to network speeds than disk speeds - which would be more realistic for real work performance.

However when we do limit it by IO of course we can no longer compare the throughput with `async` as easily since we're no longer CPU limited.

## Conclusion