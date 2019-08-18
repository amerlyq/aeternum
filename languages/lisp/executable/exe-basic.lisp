#!/usr/bin/cl -E example:main
;;SUMMARY: compiled image binary with single entry point
;;USAGE: $ ./$0 [args...]
;;BINARY: $ cl-launch --output /tmp/exe --dump ! --entry example:main --file ./$0

(defpackage #:example (:use :cl) (:export :main))
(in-package #:example)

(defun main (argv)
  (format t "main~%~S~%" argv)
  t)
