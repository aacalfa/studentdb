> import Effects
> import Effect.File
> import Effect.State
> import Effect.StdIO
> import Control.IOExcept
> import studentrecords
> 
> FileIO : Type -> Type -> Type
> FileIO st t
>   = { [FILE_IO st, STDIO, STATE Int] } Eff t 
 
Reads a file line by line and returns them as a list of strings

> readFile' : FileIO (OpenFile Read) (List String)
> readFile' = readAcc [] where
>     readAcc : List String -> FileIO (OpenFile Read) (List String)
>     readAcc acc = do e <- eof
>                      if (not e)
>                         then do str <- readLine
>                                 put (!get + 1)
>                                 readAcc (str :: acc)
>                         else return (reverse acc)
 
Write to a file, line by line

> writeFile : List StudentAssignment -> FileIO (OpenFile Write) ()
> writeFile [] = do writeLine ""
> writeFile (x :: xs) = do writeLine (show x)
>                          writeFile xs
 
Opens a file for read and returns its lines as a list of strings

> loadFile : String -> FileIO () (List String)
> loadFile fname = do ok <- open fname Read
>                     toEff [FILE_IO _, _, _] $
>                       case ok of
>                        True => do lst <- readFile'
>                                   close
>                                   return (lst)
>                        False => do putStrLn ("Error Loading Database")
>                                    return []
 
Saves a list of StudentAssignment records into a file.

> saveFile : List StudentAssignment -> String -> FileIO () ()
> saveFile recs fname = do ok <- open fname Write
>                          toEff [FILE_IO _, _, _] $
>                            case ok of
>                               True => do ok <- writeFile recs
>                                          close
>                                          return ()
>                               False => do putStrLn ("Error Writing Database")
>                                           return ()
 
Returns whether a student is a failing student or not

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
 
 
 
> dbfilename : String
> dbfilename = "studentdb.tsv"
 
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
