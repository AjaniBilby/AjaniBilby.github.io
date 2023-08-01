---
template: home.html
hide:
  - navigation
  - toc
  - feedback
  - tags
---

# About Me

I find it fascinating how the tools we use shape what we create, and then how we can design tools to encourage certain types of behaviour.

## Favorite Projects

<div class="card-grid project" large actionable markdown>

- <span>:material-robot: __Predictable Bot__
    <span class="date">:octicons-calendar-24: 2023</span></span>
    <span>:simple-typescript:</span>

    ---

    A discord bot + website to allow people to post predictions allowing people to place wagers on what they think will happen.

    The whole system was designed to be robust, ensuring no faux money is lost even in the even of an error.
    And also ensuring that there is zero down time even during upgrades.

    Ensuring as the old version is shutdown it completes currently active operations while not interrupting the start up of the new version

    [:octicons-arrow-right-24: Website](https://predictable.ajanibilby.com/)

- <span>:material-source-branch: __htmX Router__
    <span class="date">:octicons-calendar-24: 2023</span></span>
    <span>:simple-typescript:</span>

    ---

    A request router for generating html responses statically similarly to [remix.js](https://remix.run/docs/en/main/guides/routing)'s router.
    But instead being fully server-side rendered, also computing the minimal route returnable to a client given their current route,
    and sending only the minimal route back to the client and telling them where in the DOM to swap it out.

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/htmx-router)

- <span>:material-book-open: __Wiki Thesaurus__
    <span class="date">:octicons-calendar-24: 2023</span></span>
    <span>:simple-python:</span>

    ---

    Uses the simple-wiki dataset to generate a graph structure for wikipedia based on links between articles.

    From that it then uses Jaccard similarity to take any given input word or entity and attempt to find similar entities.
    Hopefully producing thesaurus like results (spoiler it's not thesaurus like)

    [:octicons-arrow-right-24: Source](https://github.com/AjaniBilby/wiki-thesaurus)

- <span>:material-keyboard: __BNF Parser__
    <span class="date">:octicons-calendar-24: 2021</span></span>
    <span>:simple-typescript:</span>

    ---

    Takes in a BNF representation of a syntax and compiles it all the way down to a wasm application for parsing that specific syntax with compiler optimisations applied to it.
    
    The compiler also generates type-definitions corresponding to the possible syntax tree layout.
    To create a much more ergonomic developer experience using the outputted syntax, since the structure will be somewhat known.

    [:octicons-arrow-right-24: Website](https://bnf-parser.ajanibilby.com)

</div>

<div markdown style="margin-left: 2em">

  [:octicons-arrow-right-24: All Projects](/project)

</div>