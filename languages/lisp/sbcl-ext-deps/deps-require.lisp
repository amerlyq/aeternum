#!/usr/bin/sbcl --script
;;SUMMARY: reliable sbcl built-ins -- something in-between of (load "file") and (asdf "system")

(require 'sb-posix)
(defpackage #:example (:use :cl))
(in-package #:example)

(eval-when (:execute)
  (format t "~A~%" (sb-posix:getcwd)))
