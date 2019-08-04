#!/usr/bin/sbcl --script
;;SUMMARY: print current ARGV and ENV

(require :uiop)
(defpackage #:example (:use :cl))
(in-package #:example)

(eval-when (:execute)
  (format t "~S~%~S~%~A~%"
          uiop:*command-line-arguments*
          (uiop:getenv "HOME")
          (uiop:read-file-string *load-truename*)))
