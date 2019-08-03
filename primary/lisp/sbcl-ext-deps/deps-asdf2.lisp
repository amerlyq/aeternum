#!/usr/bin/sbcl --script
;;SUMMARY: very old way to use asdf<2009
;;

(require :asdf)

;; NOTE:(pushnew): only for older ASDF<2009
(pushnew #p"/usr/share/common-lisp/systems/" asdf:*central-registry* :test #'equal)

;; HACK: suppress submodule naming warning for asdf>=2 uncompliant libs
;; REF: https://codebase.site/question/show_question_details/11582
(handler-bind ((asdf:bad-system-name #'muffle-warning))
  (asdf:operate 'asdf:load-op :cl-ppcre))

(defpackage #:example (:use :cl :cl-ppcre))
(in-package #:example)

(eval-when (:execute)
  (format t "~A~%" (regex-replace "(?i)fo+" "FOO bar" "frob")))
