#!/usr/bin/sbcl --script
;;SUMMARY: load "pre-installed" dependencies through "asdf" and underlying "ql"
;;DEPS: install everything required beforehand

(require :asdf)
(eval-when (:compile-toplevel :load-toplevel :execute)
  (load "/etc/default/quicklisp")
  (handler-bind ((asdf:bad-system-name #'muffle-warning))
    (asdf:require-system 'cl-unicode)))

(defpackage #:example (:use :cl :cl-unicode))
(in-package #:example)

(eval-when (:execute)
  (format t "~A~%" (unicode1-name (code-char #x67e))))
