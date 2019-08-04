#!/usr/bin/sbcl --script
;;SUMMARY: use universal (main) function

(defpackage #:example
  (:use :cl)
  (:export :main))
(in-package #:example)

(defun main (&key (myvar 2000))
  (format t "~A~%" myvar))

(eval-when (:execute)
  (main))
