-- USAGE: $ idris2 -q -x main shell-effects.idr

-- SRC: https://stackoverflow.com/questions/39812465/how-can-i-call-a-subprocess-in-idris

import System

-- read the contents of a file
readFileH : (fileHandle : File) -> IO String
readFileH h = loop ""
  where
    loop acc = do
      if !(fEOF h) then pure acc
        else do
          Right l <- fGetLine h | Left err => pure acc
          loop (acc ++ l)

execAndReadOutput : (cmd : String) -> IO String
execAndReadOutput cmd = do
  Right fh <- popen cmd Read | Left err => pure ""
  contents <- readFileH fh
  pclose fh
  pure contents

main : IO ()
main = do
  out <- (execAndReadOutput "echo \"Captured output\"")
  putStrLn "Here is what we got:"
  putStr out
