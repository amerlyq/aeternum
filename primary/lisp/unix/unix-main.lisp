#!/usr/bin/cl -E main
;;SUMMARY: use universal (main) function
;;HELP:
;;  $ cl -h
;;  $ cl --more-help

; (in-package #:example)

; ALSO: *standard-input*
(defun main (argv)
  (format t "First~%~S~%" argv)
  t)
