---
hide:
  - navigation
  - toc
  - feedback
  - tags
---

# History

---

#### :octicons-calendar-24: 2014
I first started programming when I realised, I could make my own choose your own venture with Windows bat files. This was my first real programming project which I developed completely from scratch, and without any example or tutorials on how to make it.

From there I continued playing around with different things, ending up hitting a complexity limit within bat files which forced me to move on. This led me to NodeJS (via realising I hated PHP & WordPress). Since I was still young and still had practically limitless time, I decided I’d take advantage of it. So, I set myself the goal of not using any libraries other than the language’s standard ones. I was going to build it all myself, so I knew how it all worked – even though I knew it wouldn’t be efficient or nice to work with, I was determined to do it for myself.

---

#### :octicons-calendar-24: 2016

I reverse engineered the `request` library, from there I made my own various small projects experimenting, requiring me to make my own libraries for different things such as: custom-radix conversion for base64 or another encoding; my own flat-file database library; a random library allows for weighted random on selecting items; a compact JSON format encoding numbers and other data in raw binary rather than text.

---

#### :octicons-calendar-24: 2017

I wanted more speed, I wanted the ability to run functions in multiple threads, so I created a basic library where you could pass a function and arguments in JSON format to different workers to dispatch tasks. It worked, but it was clunky, horrible, and had a lot of overhead. So, I researched the NodeJS internals and actually did a small presentation in 2017 about it to a local programming community. I realised I’d need to learn C++ and make custom modules to fulfil my goal.

So, I started learning C++, and realised it had the speed I wanted – so I went on similarly to NodeJS and eventually hit a speed cap again. Thus I started investigating how to do multithreading in C++. I originally wanted to make a library for C++, but after all of my research and new knowledge on the inability to manually keep variables synced between threads, and the bulk the API would become, I realised it needed to be its own language.

---

#### :octicons-calendar-24: 2018

Thus, we come to 2018. Originally, I started making a language in C++ calling the project `fiber`, designing it to be compiled to my own byte code which then can be run by a bispoke C++ application. This would then allow me to easily just to certain points during a function for callbacks from other threads. However, I started looking at the performance of bytecode languages like Java and C# verse Go and C++ and realised I would be penalising myself heavily from the start.

---

#### :octicons-calendar-24: 2019

I switched tactic, and decided to restart the project calling it `Qupa` (Queued Parallelism) – thinking I’d write an interpreter which translates the code into C++ doing that what would turn a horribly complex API much simpler to use due to it being integrated into the language. Then I could manage all of the pointers, and global variables myself to prevent sync problems. But then I rediscovered my old issue. Trying to check/force the synchronisation of variables in C++, there is no ideal way to flush your CPU’s cache to RAM for the other threads to access.

---

#### :octicons-calendar-24: 2020

Realising I’m going to have to compile to something lower level than C++ or C, I’ve decided to head down the path of compiling to LLVM IR – which will then allow me to still execute functions from compiled C/++ which will be helpful for filesystem access, networking capabilities and any other future functionality.