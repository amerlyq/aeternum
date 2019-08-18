#!/usr/bin/sbcl --script
;;SUMMARY: no dependencies -- very basic example

(defpackage #:example (:use :common-lisp))
(in-package #:example)

(eval-when (:execute)
  (format t "hello~%"))
