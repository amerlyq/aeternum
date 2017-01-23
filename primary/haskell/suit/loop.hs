#!/usr/bin/env runhaskell
import Control.Monad.Cont

main :: IO ()
main = do
  forM_ [1..3] $ \i -> print i
  forM_ [7..9] $ \j -> print j

  withBreak $ \break ->
    forM_ [1..] $ \_ -> do
      p "loop"
      break ()

  where
  withBreak = (`runContT` return) . callCC
  p = liftIO . putStrLn
