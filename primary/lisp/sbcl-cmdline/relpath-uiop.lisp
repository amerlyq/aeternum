#!/usr/bin/sbcl --script
;;SUMMARY: generalized access paths relative to current directory

(require :uiop)
(defpackage #:example (:use :cl))
(in-package #:example)

;; ALT: relative to .asd system
; (defvar *assets-path* (asdf:system-relative-pathname :awesome-game #p"assets/"))

(defvar *program-dir* (directory-namestring *load-truename*))
(defvar *assets-dir* (uiop:unix-namestring (uiop:directory-exists-p (merge-pathnames "../doc" *program-dir*))))
(defvar *res-path* (uiop:unix-namestring (merge-pathnames "INFO.nou" *assets-dir*)))

(eval-when (:execute)
  (write-line *res-path*))
