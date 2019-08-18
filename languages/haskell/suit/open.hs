#!/usr/bin/env runhaskell
import Control.Exception (catch, SomeException)
import System.Environment (getProgName)
import System.Directory (doesFileExist)

main :: IO ()
main = do
  path <- getProgName
  exists <- doesFileExist path
  -- Read w/o exception
  input1 <- if exists then readFile path else return ""
  putStrLn $ input1 ++ "---"
  -- Handle exception
  input2 <- catch (readFile path) $ \e -> print (e::SomeException) >> return ""
  putStrLn $ input2 ++ "---"
