#!/usr/bin/cl -E main
;;SUMMARY: dispatch first arg to dedicated package entry point
;;USAGE: $ ./$0 <aaa|bbb> [args...]
;;BINARY: $ cl-launch --output /tmp/exe --dump ! --entry main --file ./$0

(defun main (argv)
  (let* ((entry (first argv))
         (args (rest argv))
         (pkg (find-package (string-upcase entry))))
    (if entry
      (if pkg
        (let ((fn (find-symbol (string-upcase "main") pkg)))
          (if fn
            (funcall fn args)
            (format t "Err: no such function: (~A:main)~%" entry)))
        (format t "Err: no such package: (~A)~%" entry))
      (format t "Err: need entry point: <arg1>~%"))
    t))


;;;;;;;;;;;;;;;;;;;;

(defpackage #:aaa (:use :cl) (:export :main))
(in-package #:aaa)

(defun main (argv)
  (format t "aaa ~S~%" argv)
  t)

;;;;;;;;;;;;;;;;;;;;

(defpackage #:bbb (:use :cl) (:export :main))
(in-package #:bbb)

(defun main (argv)
  (format t "bbb ~S~%" argv)
  t)
