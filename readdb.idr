import Effects
import Effect.File
import Effect.State
import Effect.StdIO
import Control.IOExcept

FileIO : Type -> Type -> Type
FileIO st t
  = { [FILE_IO st, STDIO, STATE Int] } Eff t 

readFile' : FileIO (OpenFile Read) (List String)
readFile' = readAcc [] where
    readAcc : List String -> FileIO (OpenFile Read) (List String)
    readAcc acc = do e <- eof
                     if (not e)
                        then do str <- readLine
                                put (!get + 1)
                                readAcc (str :: acc)
                        else return (reverse acc)

loadFile : String -> FileIO () (List String)
loadFile fname = do ok <- open fname Read
                    toEff [FILE_IO _, _, _] $
                      case ok of
                       True => do lst <- readFile'
                                  putStrLn (show lst)
                                  --close
                                  return (lst)
                                  close
                       False => putStrLn ("Error Loading Database")
                    putStrLn ("No Database Loaded")
                    return []

main : IO ()
--main = run $ dumpFile "studentdb.tsv"
main = do stuff <- run $ loadFile "studentdb.tsv"
          putStrLn (show stuff)
          --putStrLn (index 0 stuff)
          return ()
