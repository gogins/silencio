Generative music, algorithmic composition, score generation, call it what you will.

Silencio is the first system for algorithmic composition that is designed to run on smartphones and tablets as well as personal computers. Silencio is written in the Lua programming language, and runs best on LuaJIT/FFI.

This project has come back to life! And it has also changed. I have resumed working on the project for two reasons. First, Mike Pall has created a port of LuaJIT/FFI, the fastest dynamic language on the planet, for the ARM architecture used by most Android devices. Second, Csound developers have created a Csound app for Android, and I have updated it to Csound 6 and incorporated in it my Lua opcodes for Csound.

As a result, while the original Silencio ran on Android devices only in regular Lua in the Android scripting environment (and will still run in that environment), but thus lacked facilities for sound synthesis, the new Silencio will also run inside Csound 6 for Android using the much faster LuaJIT/FFI, and therefore is completely integrated in one of the most powerful software synthesizers there is.

In short, you can really compose on phone now. I am now spending time seeing just what that is like, and so far it is very different and surprisingly good.

Of course, Silencio will still run in standalone Lua on personal computers, and it will run in Csound with LuaJIT/FFI on personal computers as well.
