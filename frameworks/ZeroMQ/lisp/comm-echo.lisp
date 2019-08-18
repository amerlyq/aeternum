#!/usr/bin/sbcl --script
;;SUMMARY: basic client-server echo service
;;DEPS: $ sudo sbcl --noprint --load /etc/default/quicklisp --script /dev/stdin <<< '(ql:quickload :zmq)'
;;

(require :asdf)
(eval-when (:compile-toplevel :load-toplevel :execute)
  (load "/etc/default/quicklisp")
  (handler-bind ((asdf:bad-system-name #'muffle-warning))
    (require :zmq)))

(defpackage #:example (:use :cl))
(in-package #:example)

(print "hi")
