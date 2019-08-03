#!/usr/bin/sbcl --script
;;SUMMARY: direct low-level loading of script
;;ARCH: directly use anything under /usr/share/common-lisp/source/<pkgname>/*.lisp
;;OR: from current directory ./deps.lisp
;;

;; NOTE: PWD-relative path
(defparameter *myfile*
  (merge-pathnames "deps-none.lisp" *default-pathname-defaults*))

;; OR: system-wide path
(load "~/.cache/roswell/lisp/quicklisp/dists/quicklisp/software/cl-fad-20180430-git/load.lisp")

(defpackage #:example (:use :cl))
(in-package #:example)

; ERROR:FAIL:
(eval-when (:execute)
  (load *myfile*))
