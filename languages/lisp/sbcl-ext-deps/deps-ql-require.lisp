#!/usr/bin/sbcl --script
;;SUMMARY: load "pre-installed" dependencies by system-wide quicklisp and "required"
;;DEPS: install everything required beforehand
;;  $ sudo sbcl --noprint --load /etc/default/quicklisp --script /dev/stdin <<< '(ql:quickload :alexandria)'
;;  $ sudo sbcl --noinform --disable-ldb --lose-on-corruption --end-runtime-options --no-userinit --noprint --disable-debugger --quit --sysinit /etc/default/quicklisp --eval '(progn (ql:quickload :alexandria) ...)' --end-toplevel-options

; SEE: https://stackoverflow.com/questions/25858237/confused-about-qlquickload-and-executable-scripts-in-sbcl

;; REF: http://clhs.lisp.se/Body/s_eval_w.htm
(require :asdf)
(eval-when (:compile-toplevel :load-toplevel :execute)
  (load "/etc/default/quicklisp")
  (handler-bind ((asdf:bad-system-name #'muffle-warning))
    (require 'cl-unicode)))

(defpackage #:example (:use :cl :cl-unicode))
(in-package #:example)

(eval-when (:execute)
  (format t "~A~%" (unicode1-name (code-char #x67e))))
