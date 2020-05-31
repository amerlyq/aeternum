-- USAGE: $ idris2 -q -x main shell-cmd.idr
-- BAD: shebang only supported by Idris1
--   https://github.com/idris-lang/Idris-dev/pull/2289
-- #!/usr/bin/env -S idris2 -q -x main

-- SRC: https://stackoverflow.com/questions/39812465/how-can-i-call-a-subprocess-in-idris

import System

main : IO ()
main = do
  exitCode <- system "echo HelloWorld!"
  putStrLn $ "Exit code: " ++ show exitCode

  exitCode <- system "echo HelloWorld!; false"
  putStrLn $ "Exit code: " ++ show exitCode
