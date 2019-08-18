#!/usr/bin/sbcl --script
;;SUMMARY: use universal (main) function

(require :asdf)
(require :alexandria)

(defpackage #:example
  (:use :cl :alexandria)
  (:export :main))
(in-package #:example)

(defun main (&key (myvar 2000))
  (format t "~A~%" (standard-deviation '(0 1 3))))

(eval-when (:execute)
  (main :myvar 30))
