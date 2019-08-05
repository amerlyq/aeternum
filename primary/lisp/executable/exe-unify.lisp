#!/usr/bin/cl -E main
;;SUMMARY: combine multiple scripts into busybox-like single binary
;;USAGE:
;;  $ cat *.lisp | cl-launch --output /tmp/exe --dump ! --dispatch-entry some/main --file -
;;  $ ln -s ./$0 {aaa,bbb}
;;  $ ./$0 <aaa|bbb> [args...]
;;

(defpackage #:example (:use :cl))
(in-package #:example)

(defun main (argv)
  (format t "Second~%~S~%" argv)
  t)
