#!/usr/bin/sbcl --script
;;SUMMARY: download and install all necessary "ql" deps
;;DEPS: automatically downloads deps from web
;;BAD: slow startup -- verifies all packages are up-to-date
;;BAD: each time prints "load system" 5-line text on startup
;;BAD:SECU: requires 'sudo' to actually install anything

;; IDEA: https://stackoverflow.com/questions/9832378/where-should-a-quicklisp-quickload-go-in-my-source-nowhere
(load "/etc/default/quicklisp")
(eval-when (:compile-toplevel :load-toplevel :execute)
  (ql:quickload :cl-unicode))

(defpackage #:example (:use :cl :cl-unicode))
(in-package #:example)

(eval-when (:execute)
  (format t "~A~%" (unicode1-name (code-char #x67e))))
