#!/usr/bin/sbcl --script
;;SUMMARY: merge .asd and .lisp to achive self-sufficient file
;;

(require :asdf)
(require :alexandria)

; TRY: https://stackoverflow.com/questions/9832378/where-should-a-quicklisp-quickload-go-in-my-source-nowhere
; (asdf:defsystem #:aserve
;  :serial t
;  :depends-on (#:hunchentoot :hunchentoot-cgi
;            #::bordeaux-threads
;            #:parenscript)
;  ...)

(defpackage #:example (:use :cl :alexandria))
(in-package #:example)

(eval-when (:execute)
  (format t "~A" (read-file-into-string *load-truename*)))
