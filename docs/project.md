---
hide:
  - navigation
  - toc
  - feedback
  - tags
---

<style>
  .project-date {
    padding-left: 0.4em;
    font-size: .7em;
  }
</style>


# Projects

## Programming Languages

<div class="card-grid" actionable markdown>

- :material-telescope: __Uniview__
    <span class="project-date">:octicons-calendar-24: Current</span>

    ---

    View once immutability enabling the safeties of immutable code, while enjoying near procedural performance

    [:octicons-arrow-right-24: Source](https://github.com/qupa-project/uniview-lang)

- :rainbow: __Qupa__
    <span class="project-date">:octicons-calendar-24: 2020</span>

    ---

    *___Qu___eued ___Pa___rallelism Language*  
    The predecessor to Uniview, a C++ like language designed to encourage implementation design which leads to easily parrallelisable programs.

    [:octicons-arrow-right-24: Source](https://github.com/qupa-project/Qupa)

- :thread: __Fiber__
    <span class="project-date">:octicons-calendar-24: 2018</span>

    ---

    The original toy language project which compiled to a bytecode, which then ran on a bispoke interpreter to understand language development - which inspired the future language projects I have ventured onto.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/fabric-lang)
</div>


## Visualisations

<div class="card-grid" actionable markdown>

- :material-ghost-outline: __Slime Mould__
    <span class="project-date">:octicons-calendar-24: 2022</span>

    ---

    Used GPU shaders to compute a mould simulation. Each spore lays down attractors, and every spore is attracted to those. As the spores move around it creates a cool visualisation.

    [:octicons-arrow-right-24: Demo](https://www.shadertoy.com/view/7sByzW)

- :material-chess-bishop: __DeepL Chess Notation__
    <span class="project-date">:octicons-calendar-24: 2020</span>

    ---

    This was a group project for a university assignment where we created a web app which you could take a photo of a chess board and it will give you the chess notation of the board. This runs completely on the mobile device with highly usable processing times for keeping board history for a local tournament.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/DeepL-Chess-Notation)

- :material-bird: __Dots__
    <span class="project-date">:octicons-calendar-24: 2019</span>

    ---

    Modified boids animation for the front page where the parameters dictating the boids are constantly changing, including into negative values to lead to interesting patterns.

    [:octicons-arrow-right-24: Demo](/animation/dots/index.html)

- :material-disc-player: __Musical Boids__
    <span class="project-date">:octicons-calendar-24: 2018</span>

    ---

    A modification of the dots animation where the parameters (*turnspeed, maxspeed, separation, attraction*) all change according to the music being played.

    [:octicons-arrow-right-24: Demo](/demo/music/index.html)

- :material-waveform: __Musical Vector Field__
    <span class="project-date">:octicons-calendar-24: 2018</span>

    ---

    A large amount of particles are simulated across a vector flow field, where the fields are determined by the frequencies of the music playing.

    [:octicons-arrow-right-24: Demo](/demo/music-fluid/index.html)

- :material-spider-web: __Wiki Web__
    <span class="project-date">:octicons-calendar-24: 2016</span>

    ---

    Give the software a start and an end page, and it will use the Wikipedia APIs to crawl via a bredth first search to find a network of possible routes from A → B and visualise all of them.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/Wiki-Web)
</div>


## Applications

<div class="card-grid" actionable markdown>

- :material-newspaper-remove: __No Press__
    <span class="project-date">:octicons-calendar-24: 2020</span>

    ---

    A MVP for a drop in replacement for a dying Wordpress sight, which built in converstion to ingest the pages from a Wordpress site converting into a statically build blog.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/NoPress)

- :material-radio: __J Plays__
    <span class="project-date">:octicons-calendar-24: 2016</span>

    ---

    A light weight version of Dj Radio designed only as a local media player built in electron.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/J-Plays)

- :material-radio: __Dj Radio__
    <span class="project-date">:octicons-calendar-24: 2016</span>

    ---

    *A NodeJS implementation of a alternative to IceRadio.*  
    It will read an entire folder and index the music in it, reading all metadata from the MP3s. The admin can then queue music or allow the server to play random music. The server will re-encode the audio so all devices will see it as a single stream of audio, with server side buffering to fill client side caches on connection for instant stream start, while remaining in sync with other users.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/Dj-Radio)

</div>


## Hardware

<div class="card-grid" actionable markdown>

- :material-keyboard: __GKM27__
    <span class="project-date">:octicons-calendar-24: 2022</span>

    ---

    A macropad designed ergonomically for FPS shooters rather than typing. Also includes direct key-to-led mapping allowing reactive lighting visualisations, tuned to maintain a high polling rate.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/gkm27r)

</div>


## Libraries
> When I started learning NodeJS, I decided I wouldn't use anything other than the built in libraries to force myself to learn the full features of the language, and to understand how the popular libraries worked and how they were made.

<div class="card-grid" actionable markdown>

- :material-keyboard: __BNF Parser__
    <span class="project-date">:octicons-calendar-24: 2021</span>

    ---

    Takes in a BNF representation of a language and builds a syntax parser which than then be used to generate a syntax tree on language inputs.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/BNF-parser)

- :material-keyboard: __Struct-DB__
    <span class="project-date">:octicons-calendar-24: 2018</span>

    ---

    A simple object oriented database implementation

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/struct-db)

- :material-keyboard: __FlatFile-DB__
    <span class="project-date">:octicons-calendar-24: 2018</span>

    ---

    A very simple flat table database implementation.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/FlatFile-DB)

- :material-keyboard: __Theader__
    <span class="project-date">:octicons-calendar-24: 2017</span>

    ---

    Give the API a function, then call the function through the API and it will send the data to a new worker to execute the function on.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/Threader)

- :material-keyboard: __cosf__
    <span class="project-date">:octicons-calendar-24: 2017</span>

    ---

    **C**ompact **o**bject **s**torage **f**ormat. Basically a custom BJSON implementation.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/cosf)

- :material-keyboard: __Passer__
    <span class="project-date">:octicons-calendar-24: 2016</span>

    ---

    A bispoke express like library with the ability for: wildcards in addresses; cookie decode/encode; query string decode/encode; multi-part form parsing (including files); session management; authorisation checks for certain url paths.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/passer)

- :material-keyboard: __Custom Radix__
    <span class="project-date">:octicons-calendar-24: 2016</span>

    ---

    Define a character set for your radix, then it can convert to and from that stringified form.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/custom-radix)

- :material-keyboard: __Adatre__
    <span class="project-date">:octicons-calendar-24: 2016</span>

    ---

    Asynchronous class-based referencing databasse

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/adatre)

- :material-keyboard: __Mass Random__
    <span class="project-date">:octicons-calendar-24: 2016</span>

    ---

    Bounded random values, and random string generation

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/mass-random)

- :material-keyboard: __Object Manipulation__
    <span class="project-date">:octicons-calendar-24: 2016</span>

    ---

    Difference of objects, merge two objects, deep copy of objects.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/object-manipulation)

</div>

## Other

<div class="card-grid" actionable markdown>

- :material-keyboard: __Woona IRC Bot__
    <span class="project-date">:octicons-calendar-24: 2016</span>

    ---

    A basic IRC bot which oberves how users react to it, and memorises those responses and attempts to use them later to respond to the user.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/Woona-IRC-Bot)

</div>