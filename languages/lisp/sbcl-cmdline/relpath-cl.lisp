#!/usr/bin/sbcl --script
;;SUMMARY: access paths relative to current directory
; https://stackoverflow.com/questions/44682199/common-lisp-relative-path-to-absolute?rq=1
; http://www.lispworks.com/documentation/HyperSpec/Body/f_pn_hos.htm

(defpackage #:example (:use :cl))
(in-package #:example)

;; BUG: "merge-pathnames" tries to add '.lisp' to everything
(defvar *program-dir* (directory-namestring *load-truename*))
(defvar *assets-dir* (namestring (truename (merge-pathnames "../doc" *program-dir*))))
(defvar *res-path* (namestring (merge-pathnames "INFO.nou" *assets-dir*)))

;; ALT: construct in-place
; (print (make-pathname :directory *load-truename* :name "_rc"))

(eval-when (:execute)
  (write-line *res-path*))
