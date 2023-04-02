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

While numerous articles offer quick tips to enhance your async JavaScript performance using the Promise API, this discussion focuses on how simple program tweaks can lead to significant speed improvements. By optimizing your code, you could potentially achieve 1.9x or even 14x speed boosts.

I believe the untapped performance potential in asynchronous JavaScript features is due to the V8 engine not providing the expected level of optimization for these features; and there are a few key indicators that suggest this possibility.

## Context

You can skip this section if you want, but here's a brief overview of the context. I've been working with a [bnf-parser](https://www.npmjs.com/package/bnf-parser) library that currently needs a complete file to be loaded for parsing it into a BNF-specified syntax tree. However, the library could be refactored to use cloneable state generators, which output file characters sequentially and allow for copying at a specific point to resume reading later.

So I tried to implementing it in Javascript be able to parse large +1GB files into partial syntax trees for processing large XML, just partly for fun, partly because I know also soon I'll need to be implementing something similar in a lower level language and this could be good practice.

## The Case Study

I aimed to create a layer between the readable data stream from disk and allowing iteratively calling forward for small text portions with limited backtracking. I implemented a [Cursor](https://github.com/AjaniBilby/BNF-parser/blob/350e9a00fc4ca06acc98245377fb705f00d286b8/source/lib/cache.ts#L7-L45) that iterates forward, returning the passed-over characters as a string. Cursors can be cloned, and clones can independently move forward. Importantly cursors *may* need to wait for data currently streamed to become available before returning the next substring. To minimize memory usage, we discard unreachable data - implementing all of this into a async/await pattern to avoid complex callback chains or unnecessary event loop blocking.

> Side note: We use pooling for caching, placing each chunk read from the disk into an array and manipulating the array to free cached data. This method reduces resize operations and string manipulation. However, it can cause NodeJS to report false memory usage, as chunks allocated by the OS are sometimes not counted until manipulated within the application domain.

The cursor features an async read call, asynchronously connecting to a [StreamCache](https://github.com/AjaniBilby/BNF-parser/blob/350e9a00fc4ca06acc98245377fb705f00d286b8/source/lib/cache.ts#L52-L271) to read from the cache. Multiple cursors may attempt to read the latest unavailable information, requiring a [condition variable](https://en.cppreference.com/w/cpp/thread/condition_variable) lock - an async call to a [PromiseQueue](https://github.com/AjaniBilby/BNF-parser/blob/350e9a00fc4ca06acc98245377fb705f00d286b8/source/lib/promise-queue.ts) is used to manages this.

Reading a `1GB` file in `100-byte` chunks leads to at least `10,000,000 IOs` through three async call layers. The problem becomes catastrophic since these functions are essentially language-level abstractions of callbacks, lacking optimizations that come with their async nature. However, we can manually implement optimizations to alleviate this issue.

## Testing

So let's go through the base implementation, then a few different variations and optimisations; or you can skip ahead to the [results](#results) then work your way backwards if you prefer.

A quick note about the testing methodology: Each test ran 10 times consecutively, starting from a cold state. The first result was consistently slower, while the other nine were nearly identical. This suggests either NodeJS temporarily saves optimized code between runs, or the NAS intelligently caches the file for quicker access. The latter is more likely, as longer durations between cold starts result in slower initial executions.

The test file used is [here](https://dumps.wikimedia.org/simplewiki/latest/simplewiki-latest-pages-articles.xml.bz2) (streamed as a standalone XML file).

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

> The cursor  is added before piping to ensure the first bytes of data can't be read into the cache, then dropped because of it being inaccessible by any cursors

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

In the cursor before we could see we had an async function basically just acting as a wrapper, if you understand the async abstraction you'd know an async function just returns a promise, so there is no actual need in creating this extra async function, and instead we can just return the one created from the child call. (This has a level of performance benefit it really shouldn't :D)

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
> Note: I didn't rewrite the `signal.wait()` as trying to create an optimised call back system inside a for loop will be hell on earth to implement.
> And yes we do need a while loop, because it might take more than one chunk to load in to fulfill the requested read - chunk sizes can be weird sometimes and inconsistent, plus maybe you just want a large chunk read at once :shrug:

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

| Case                                       | Duration (Min) | Median | Mean | Max |
| :- | -: | -: | -: | -: |
| [Full Async](#full-async)                  | 27.742s | 28.339s | 28.946s | 35.203s |
| [Async Wrapper Opt](#wrapper-optimisation) | 14.758s | 14.977s | 15.761s | 22.847s |
| [Callback](#callback)                      | 13.753s | 13.902s | 14.683s | 21.909s |
| [Inlined Async](#inlined)                  |  2.025s |  2.048s |  3.037s | 11.847s |
| [Async w/ Peaking](#async-with-peaking)    |  1.970s |  2.085s |  3.054s | 11.890s |
| [Disk Read](#disk-read)                    |  1.970s |  1.996s |  2.982s | 11.850s |

It's kind of terrifying how well changing just the wrapper function `Cursor.next` is, it shows that there is easily optimisation improvements available, that plus the inlining `13.9x` performance improvement shows that there is room that even if V8 doesn't get around to implementing something, tools like Typescript certainly could.

Also if you look at the peaking example, we hit quite an interesting limit. In that case only `0.078%` of requests were fulfilled by the async function, meaning only about `9194` of `11746006` requests were waiting for the data to be loaded. This would imply our CPU is almost perfectly being feed by the incoming data.

## Conclusion

The performance of asynchronous JavaScript functions can be significantly improved by making simple tweaks to the code. The results of this case study demonstrate the potential for 1.9x to 14x speed boosts with manual optimizations. The V8's current lack of optimization for these features leaves room for further improvements in the future.

When using direct raw `Promise` API calls, there can be a strong argument made that attempting to optimise this behaviour without potentially altering execution behaviour can be extraordinarily hard to implement. But when we use the `async`/`await` syntax without even using the term `Promise`, our functions are now written in such a way you can make some pretty easy performance guaranteed optimisations.

The fact that simply [altering the wrapper call](#wrapper-optimisation) creates an almost 1.9x boost in performance should be horrifying for anyone who has used a compiled language. It's a simple function call redirection and can be easily optimised out of existence in most cases.

We don't need to wait for the browsers to implement these optimisations, tools such as Typescript already offer transpiling to older ES version, clearly showing the compiler infrastructure has a deep understanding of the behaviour of the language. For a long time people have been saying that Typescript doesn't need to optimise your Javascript, since V8 already does such a good job, however that clearly isn't the case with this new async syntax - and with a little bit of static analysis an inlining alone Javascript can become way more performant.

## Take Away

Currently in V8's implementation of Javascript, `async` is just an abstraction of `Promise`s, and `Promise`s are just an abstraction of callbacks, and V8 doesn't appear to use the added information that an `async` function provides over a traditional callback to make any sort of optimisations.