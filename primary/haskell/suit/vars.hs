#!/usr/bin/env runhaskell

main :: IO ()
main = do
  let a = "initial"
  putStrLn a

  let b = 1
  let c = 2
  print b >> print c

  let d = True
  print d

  let e = undefined :: Int
  print e

  let f = "short"
  putStrLn f
