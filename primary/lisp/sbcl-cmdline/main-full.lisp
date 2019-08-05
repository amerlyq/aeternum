#!/usr/bin/sbcl --script
;;SUMMARY: use universal (main) function

(defpackage #:example
  (:use :cl)
  (:export :main))
(in-package #:example)

(defun main (&optional argv)
  (declare (ignore argv))
  (write-line "main")
  (values))

(eval-when (:execute)
  (main))
