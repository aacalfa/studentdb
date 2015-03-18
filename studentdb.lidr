> import Effects
> import Effect.File
> import Effect.State
> import Effect.StdIO
> import Control.IOExcept
> import studentrecords

Here is a more complex example using Effects -- Effectful File IO.
Idris has a set of functions for dealing with files based on the "IO" effect.
However, these make you pass file handles around. That's boring.
Let's spice things up a bit

Idris provides a "FileIO" Effect in the Effects.File module.  Here's what the
user-facing part looks like:
 
> FileIO : Type -> Type -> Type
> FileIO st t
>   = { [FILE_IO st, STDIO, STATE Int] } Eff t 

This is the standard format for an effect in Idris.  In the {} are the effects
(usually in all-caps) that are being used. 

This is an effect that depends on a few other effects, namely:
 - FILE_IO: A lower-level effect, which holds the "mode" of the file as its
            own state.  
 - STDIO: The effect containing stuff needed to read and write StdIO
 - STATE Int: The STATE effect lets you store mutable state.  In this case,
              we hang on to one integer, the file descriptor itself
Here, t, the last parameter, is the return type of the IO actions, as before.
We can assign this to a type, as is done here (FileIO) to avoid all that ugly syntax

This reads a file line by line and returns them as a list of strings
Note that, obviously, the file has to be open, and open for reading, first.  Our type signature here
enforces this, by using the FILE_IO effect's state (as described above)
Note that here we define readFile', in contrast to "readFile" that Idris
provides, as reading the file to a list of lines, instead of one big string.

> readFile' : FileIO (OpenFile Read) (List String)
> readFile' = readAcc [] where
>     readAcc : List String -> FileIO (OpenFile Read) (List String)
>     readAcc acc = do e <- eof
>                      if (not e)
>                         then do str <- readLine
>                                 put (!get + 1)
>                                 readAcc (str :: acc)
>                         else return (reverse acc)
 
Similar to the above, this provides the ability to write out one of our
data files.  Given a list of StudentAssignment objects (see records.lidr)
write out the database.
Obviously the file has to be open for writing first.  We return (), since
nothing is returned from writeLine, short of failing outright and crashing.

> writeFile : List StudentAssignment -> FileIO (OpenFile Write) ()
> writeFile [] = do writeLine ""
> writeFile (x :: xs) = do writeLine (show x)
>                          writeFile xs
 
This loads a studentdb file (such as studentdb.tsv included)

This function contains both the opening, and closing, of the file, so the 
end result at the end is that no file is open.  We indicate this by using ()
for the state.  The actual result here is a list of strings.

> loadFile : String -> FileIO () (List String)
> loadFile fname = do ok <- open fname Read
>                     toEff [FILE_IO _, _, _] $
>                       case ok of
>                        True => do lst <- readFile'
>                                   close
>                                   return (lst)
>                        False => do putStrLn ("Error Loading Database")
>                                    return []

SImilarly to the above, this writes a whole file of StudentAssignment records.

> saveFile : List StudentAssignment -> String -> FileIO () ()
> saveFile recs fname = do ok <- open fname Write
>                          toEff [FILE_IO _, _, _] $
>                            case ok of
>                               True => do ok <- writeFile recs
>                                          close
>                                          return ()
>                               False => do putStrLn ("Error Writing Database")
>                                           return ()

Note that the toEff line explicitly declares which effect we want to work
under.  Here, it's any FILE_IO effect,  

Wait a second, where are all the file handles? How does it know what file
we are working with???
Confusingly, in sharp contrast to this kind of language's super-explicit
nature, there's a ton of inferred parameters being passed around, including
the file's handle itself.  

Now for some actual program logic.
This returns whether a student is a failing student or not

> isFailingStudent : StudentAssignment -> Bool
> isFailingStudent rec = (isNothing (assignment1 rec)) || (isNothing (assignment2 rec))
 
Returns whether a student is a passing student or not

> isPassingStudent : StudentAssignment -> Bool
> isPassingStudent rec = (isJust (assignment1 rec)) && (isJust (assignment2 rec))
 
Returns a list of students who are currently failing the class

> getFailingStudents : List StudentAssignment -> List StudentAssignment
> getFailingStudents recs = filter isFailingStudent recs
 
Returns a list of all students who are currently passing the class

> getPassingStudents : List StudentAssignment -> List StudentAssignment
> getPassingStudents recs = filter isPassingStudent recs
 
 
Command-line parsing is still broken.  Hard-code the DB name here.
 
> dbfilename : String
> dbfilename = "studentdb.tsv"
 

Given all of the above, this program does the following:
- Load a database (tab-separated) of students, their (fake) ID numbers, and
  their two class assignments
- Determine whether all of these students "pass" (did two assignments)
- Write out files containing the lists of passing and failing students.

"run" lets you run parts of program in a different Effect context.
Our main is IO (), and our functions are FileIO () (), so this is required.
This provides a sort of compartmentalization to your program.

> main : IO ()
> main = do dbstring <- run $ loadFile dbfilename
>           let records = ParseRecords dbstring
>           putStrLn ("Loaded " ++ (show (length records)) ++ " Records")
>           putStrLn ("Passing Students")
>           let passing = getPassingStudents records
>           putStrLn (show (studentrecords.GetNames passing)) 
>           run $ saveFile passing (dbfilename ++ ".passing")
>           putStrLn ("Failing students")
>           let failing = getFailingStudents records
>           run $ saveFile failing (dbfilename ++ ".failing")
>           putStrLn (show (studentrecords.GetNames failing)) 
>           return ()
