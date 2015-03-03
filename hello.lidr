######## Useful Dependently-typed Programs through Monads and Effects ########

Most examples in dependently-typed functional languages showcase programs 
that are guaranteed to terminate, and which therefore we can reason about
statically.  One property we get out of this, is that all programs in
these languages, by default, have no side-effects.  However, we as programmers
need to interact with the outside world for them to be useful, and the outside
world is inherently side-effecting.  We have no static way to gaurantee that
any input or output operation will succeed, and therefore using any kind of
IO, without extra precautions, removes a lot of the benefits of these
languages.

To work around this, we introduce the concepts of monads and Effects, which
allow us to abstract away the side-effects in pieces of code, including I/O
 functions.

This is a "writeup-lementation" using "literate programs".  Lines with ">"s
in front are executable, and everything else is a comment.

In dependently-typed languages like Idris, this is necessary to do even the
most basic forms of interaction, including the usual "Hello, World!" program.

> main : IO ()
> main = putStrLn "Hello, World!"

In Idris, the "main" of a program has the type "IO ()", but why?
It clearly does I/O, but what's that unit type () for?

This is because "IO" in Idris is an "Effect", which denotes that the return
type of main depends on some IO action, which may fail.
In Idris, failure of IO results in the program crashing, but type-checking 
the program this way allows us to keep most of our static guarantees.
Here, the type "IO ()" means that the function will perform some IO, in this
case, printing to the screen, and return the type ().
This is also the return type of the "putStrLn" function (the "print"-equivalent"
in Idris)

 
