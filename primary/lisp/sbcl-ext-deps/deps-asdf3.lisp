#!/usr/bin/sbcl --script
;;SUMMARY: importing deps from distribution-specific location
;;SEE: https://wiki.archlinux.org/index.php/Lisp_package_guidelines
;;ARCH
;;  * /usr/share/common-lisp/source/<pkgname>/*.lisp
;;  * /usr/share/common-lisp/systems/<system>.asdf -> ../<pkgname>/<system>.asdf
;;
;;DEPS:IDEA: pack the same way as |aur/cl-airy|
;;

(require :asdf)
(require :alexandria)

(defpackage #:example (:use :cl :alexandria))
(in-package #:example)

(eval-when (:execute)
  (format t "~A" (read-file-into-string *load-truename*)))
