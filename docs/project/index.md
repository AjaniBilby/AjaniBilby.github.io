---
hide:
  - navigation
  - feedback
  - tags
---


# All Projects

## Programming Languages

<div class="card-grid project" actionable markdown>

- <span>:material-telescope: __Uniview__
    <span class="date">:octicons-calendar-24: Current</span></span>
    <span>:simple-javascript: :simple-c: :simple-llvm:</span>

    ---

    View once immutability enabling the safeties of immutable code, while enjoying near procedural performance

    [:octicons-arrow-right-24: Source](https://github.com/qupa-project/uniview-lang)

- <span>:rainbow: __Qupa__
    <span class="date">:octicons-calendar-24: 2020</span></span>
    <span>:simple-javascript:</span>

    ---

    *___Qu___eued ___Pa___rallelism Language*  
    The predecessor to Uniview, a C++ like language designed to encourage implementation design which leads to easily parrallelisable programs.

    

    [:octicons-arrow-right-24: Source](https://github.com/qupa-project/Qupa)

- <span>:material-telescope: __Fiber__
    <span class="date">:octicons-calendar-24: 2018</span></span>
    <span>:simple-javascript:</span>

    ---

    The original toy language project which compiled to a bytecode, which then ran on a bispoke interpreter to understand language development - which inspired the future language projects I have ventured onto.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/fabric-lang)
</div>


## Visualisations

<div class="card-grid project" actionable markdown>

- <span>:material-ghost-outline: __Slime Mould__
    <span class="date">:octicons-calendar-24: 2022</span></span>
    <span >:simple-webgl:</span>

    ---

    Used GPU shaders to compute a mould simulation. Each spore lays down attractors, and every spore is attracted to those. As the spores move around it creates a cool visualisation.

    [:octicons-arrow-right-24: Demo](https://www.shadertoy.com/view/7sByzW)

- <span>:material-chess-bishop: __DeepL Chess Notation__
    <span class="date">:octicons-calendar-24: 2020</span></span>
    <span>:simple-javascript: :simple-tensorflow:</span>

    ---

    This was a group project for a university assignment where we created a web app which you could take a photo of a chess board and it will give you the chess notation of the board. This runs completely on the mobile device with highly usable processing times for keeping board history for a local tournament.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/DeepL-Chess-Notation)

- <span>:material-bird: __Dots__
    <span class="date">:octicons-calendar-24: 2019</span></span>
    <span>:simple-javascript:</span>

    ---

    Modified boids animation for the front page where the parameters dictating the boids are constantly changing, including into negative values to lead to interesting patterns.

    [:octicons-arrow-right-24: Demo](/animation/dots/index.html)

- <span>:material-disc-player: __Musical Boids__
    <span class="date">:octicons-calendar-24: 2018</span></span>
    <span>:simple-javascript:</span>

    ---

    A modification of the dots animation where the parameters (*turnspeed, maxspeed, separation, attraction*) all change according to the music being played.

    [:octicons-arrow-right-24: Demo](/demo/music/index.html)

- <span>:material-waveform: __Musical Vector Field__
    <span class="date">:octicons-calendar-24: 2018</span></span>
    <span>:simple-javascript:</span>

    ---

    A large amount of particles are simulated across a vector flow field, where the fields are determined by the frequencies of the music playing.

    [:octicons-arrow-right-24: Demo](/demo/music-fluid/index.html)

- <span>:material-spider-web: __Wiki Web__
    <span class="date">:octicons-calendar-24: 2016</span></span>
    <span>:simple-javascript: :simple-electron:</span>

    ---

    Give the software a start and an end page, and it will use the Wikipedia APIs to crawl via a bredth first search to find a network of possible routes from A → B and visualise all of them.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/Wiki-Web)
</div>


## Applications

<div class="card-grid project" actionable markdown>

- <span>:material-robot: __Predictable Bot__
    <span class="date">:octicons-calendar-24: 2023</span></span>
    <span>:simple-typescript:</span>

    ---

    A discord bot + website to allow people to post predictions allowing people to place wagers on what they think will happen.

    The whole system was designed to be robust, ensuring no faux money is lost even in the even of an error.
    And also ensuring that there is zero down time even during upgrades.

    Ensuring as the old version is shutdown it completes currently active operations while not interrupting the start up of the new version

    [:octicons-arrow-right-24: Website](https://predictable.ajanibilby.com/)

- <span>:material-book-open: __Wiki Thesaurus__
    <span class="date">:octicons-calendar-24: 2023</span></span>
    <span>:simple-python:</span>

    ---

    Uses the simple-wiki dataset to generate a graph structure for wikipedia based on links between articles.

    From that it then uses Jaccard similarity to take any given input word or entity and attempt to find similar entities.
    Hopefully producing thesaurus like results (spoiler it's not thesaurus like)

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/wiki-thesaurus)

- <span>:material-newspaper-remove: __No Press__
    <span class="date">:octicons-calendar-24: 2020</span></span>
    <span>:simple-javascript:</span>

    ---

    A MVP for a drop in replacement for a dying Wordpress sight, which has built in conversion to ingest the pages from a Wordpress site converting it into a statically built blog.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/NoPress)

- <span>:material-radio: __J Plays__
    <span class="date">:octicons-calendar-24: 2016</span></span>
    <span>:simple-javascript: :simple-electron:</span>

    ---

    A light weight version of Dj Radio designed only as a local media player built in electron.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/J-Plays)

- <span>:material-radio: __Dj Radio__
    <span class="date">:octicons-calendar-24: 2016</span></span>
    <span>:simple-javascript:</span>

    ---

    *A NodeJS implementation of a alternative to IceRadio.*  

    It will read an entire folder and index the music in it, reading all metadata from the MP3s. The admin can then queue music or allow the server to play random music.
    
    The server will re-encode the audio so all devices will see it as a single stream of audio, with server side buffering to fill client side caches on connection for instant stream start, while remaining in sync with other users.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/Dj-Radio)

</div>


## Hardware

<div class="card-grid" actionable markdown>

- <span>:material-keyboard: __GKM27__
    <span class="date">:octicons-calendar-24: 2022</span></span>
    <span>:simple-c:</span>

    ---

    A macropad designed ergonomically for FPS shooters rather than typing. Also includes direct key-to-led mapping allowing reactive lighting visualisations, tuned to maintain a high polling rate.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/gkm27r)

</div>


## Libraries
> When I started learning NodeJS, I decided I wouldn't use anything other than the built in libraries to force myself to learn the full features of the language, and to understand how the popular libraries worked and how they were made.

<div class="card-grid project" actionable markdown>

- <span>:material-keyboard: __BNF Parser__
    <span class="date">:octicons-calendar-24: 2021</span></span>
    <span>:typescript-javascript:</span>

    ---

    Takes in a BNF representation of a syntax and compiles it all the way down to a wasm application for parsing that specific syntax with compiler optimisations applied to it.
    
    The compiler also generates type-definitions corresponding to the possible syntax tree layout.
    To create a much more ergonomic developer experience using the outputted syntax, since the structure will be somewhat known.

    [:octicons-arrow-right-24: Read More](https://bnf-parser.ajanibilby.com)

- <span>:material-keyboard: __Struct-DB__
    <span class="date">:octicons-calendar-24: 2018</span></span>
    <span>:simple-javascript:</span>

    ---

    A simple object oriented database implementation

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/struct-db)

- <span>:material-keyboard: __FlatFile-DB__
    <span class="date">:octicons-calendar-24: 2018</span></span>
    <span>:simple-javascript:</span>

    ---

    A very simple flat table database implementation.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/FlatFile-DB)

- <span>:material-keyboard: __Theader__
    <span class="date">:octicons-calendar-24: 2017</span></span>
    <span>:simple-javascript:</span>

    ---

    Give the API a function, then call the function through the API and it will send the data to a new worker to execute the function on.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/Threader)

- <span>:material-keyboard: __cosf__
    <span class="date">:octicons-calendar-24: 2017</span></span>
    <span>:simple-javascript:</span>

    ---

    **C**ompact **o**bject **s**torage **f**ormat. Basically a custom BJSON implementation.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/cosf)

- <span>:material-keyboard: __Passer__
    <span class="date">:octicons-calendar-24: 2016</span></span>
    <span>:simple-javascript:</span>

    ---

    A bispoke express like library with the ability for: wildcards in addresses; cookie decode/encode; query string decode/encode; multi-part form parsing (including files); session management; authorisation checks for certain url paths.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/passer)

- <span>:material-keyboard: __Custom Radix__
    <span class="date">:octicons-calendar-24: 2016</span></span>
    <span>:simple-javascript:</span>

    ---

    Define a character set for your radix, then it can convert to and from that stringified form.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/custom-radix)

- <span>:material-keyboard: __Adatre__
    <span class="date">:octicons-calendar-24: 2016</span></span>
    <span>:simple-javascript:</span>

    ---

    Asynchronous class-based referencing databasse

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/adatre)

- <span>:material-keyboard: __Mass Random__
    <span class="date">:octicons-calendar-24: 2016</span></span>
    <span>:simple-javascript:</span>

    ---

    Bounded random values, and random string generation

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/mass-random)

- <span>:material-keyboard: __Object Manipulation__
    <span class="date">:octicons-calendar-24: 2016</span></span>
    <span>:simple-javascript:</span>

    ---

    Difference of objects, merge two objects, deep copy of objects.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/object-manipulation)

</div>

## Other

<div class="card-grid project" actionable markdown>

- <span>:material-keyboard: __Woona IRC Bot__
    <span class="date">:octicons-calendar-24: 2016</span></span>
    <span>:simple-javascript:</span>

    ---

    A basic IRC bot which oberves how users react to it, and memorises those responses and attempts to use them later to respond to the user.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/Woona-IRC-Bot)

</div>