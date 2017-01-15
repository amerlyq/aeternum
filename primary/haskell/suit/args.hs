#!/usr/bin/env runhaskell
import System.Environment (getArgs)
import System.Exit

main :: IO ()
main = do
    args <- getArgs >>= parse
    -- tac = unlines . reverse . lines
    print args

parse ["-h"] = usage   >> exitSuccess
parse []     = getContents  -- Input from stdin/tty
parse fs     = concat `fmap` mapM readFile fs

usage = putStrLn "Usage: $0 [-vh] [file ..]"
