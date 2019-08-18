#!/usr/bin/cl -E main
;;SUMMARY: use universal (main) function
;;HELP:
;;  $ cl -h
;;  $ cl --more-help

; ALSO: *standard-input*
(defun main (argv)
  (format t "Script~%~S~%" argv)
  t)
