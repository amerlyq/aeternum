-- USAGE: $ idris2 -q -p effects -x main shell-effects.idr
-- FAIL: no "Effects" in Idris2

-- SRC: https://stackoverflow.com/questions/39812465/how-can-i-call-a-subprocess-in-idris
-- http://docs.idris-lang.org/en/latest/effects/index.html

import Effects
import Effect.System
import Effect.StdIO

execAndPrint : (cmd : String) -> Eff () [STDIO, SYSTEM]
execAndPrint cmd = do
  exitCode <- system cmd
  putStrLn $ "Exit code: " ++ show exitCode

script : Eff () [STDIO, SYSTEM]
script = do
  execAndPrint "echo HelloWorld!"
  execAndPrint "sh -c \"echo HelloWorld!; exit 1\""

main : IO ()
main = run script
