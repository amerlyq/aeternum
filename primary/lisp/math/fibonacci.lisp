#!/usr/bin/cl -E main
;;SUMMARY: calculate fibonacci sequence

(defpackage #:fibonacci
  (:use #:cl)
  (:export #:generate))

(in-package #:cl-user)

(defun main (argv)
  (let ((maxval (if argv (parse-integer (first argv)) 10)))
    (format t "~A~%" (fibonacci:generate maxval))
    t))

(in-package #:fibonacci)

(defun generate (n &optional (a 0) (b 1) (acc (list)))
  (if (<= n 0)
    (reverse acc)
    (generate (1- n) b (+ a b) (push a acc))))
