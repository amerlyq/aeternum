#!/usr/bin/cl -Q -E main
;;SUMMARY: busybox-like single binary with multiple entry points
;;USAGE: $ ln -s ./$0 {aaa,bbb} && ./$0 <aaa|bbb> [args...]
;;DEPS: install everything required beforehand
;;  $ sudo sbcl --noprint --load /etc/default/quicklisp --script /dev/stdin <<< '(ql:quickload :cl-scripting)'
;;BINARY: $ cl-launch --output /tmp/exe --dump ! --entry main --file ./$0
;;OR: --dispatch-entry example:help

;; SEE: https://github.com/fare/cl-scripting
;; https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=cl-launch
;; https://github.com/fare/fare-scripts/

; (ql:quickload :cl-scripting)
(require :cl-scripting)

; (eval-when (:compile-toplevel :load-toplevel :execute)

; (handler-bind ((asdf:bad-system-name #'muffle-warning))
;   (require :cl-scripting))
; )

;(defvar *entry-fn* (string-upcase "main"))

(defun main (argv)
  (let* ((entry (first argv))
         (args (rest argv))
         (pkg (find-package (string-upcase entry))))
    (if entry
      (if pkg
        (let ((fn (find-symbol *entry-fn* pkg)))
          (if fn
            (funcall fn args)
            ; FIXME: must return error
            (format t "Err: no such function: (~A:~A)~%" entry *entry-fn*)))
        (format t "Err: no such package: (~A)~%" entry))
      (format t "Err: need entry point: <arg1>~%")))
  t)


;;;;;;;;;;;;;;;;;;;;;

(defpackage #:aaa (:use :cl :cl-scripting) (:export :main))

;; (uiop:define-package #:aaa
;;   (:use #:cl #:uiop #:cl-launch/dispatch)
;;   (:export #:main))

(in-package #:aaa)

(defun main (argv)
  (format t "aaa ~S~%" argv)
  t)


(register-commands :aaa/main)

;;;;;;;;;;;;;;;;;;;;;

(defpackage #:bbb (:use :cl :cl-launch/dispatch) (:export :main))
(in-package #:bbb)

(defun main (argv)
  (format t "bbb ~S~%" argv)
  t)

(register-commands :bbb/main)
