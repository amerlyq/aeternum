#!/usr/bin/sbcl --script
;;SUMMARY: print current ARGV and ENV

(defpackage #:example (:use :cl))
(in-package #:example)

(defun my-cmdline ()
  (or
    #+CLISP *args*
    #+SBCL sb-ext:*posix-argv*
    #+LISPWORKS system:*line-arguments-list*
    #+CMU extensions:*command-line-words*
    nil))

(defun my-get-file (filename)
  (with-open-file (stream filename)
    (loop for line = (read-line stream nil)
          while line
          collect line)))

(eval-when (:execute)
  (format t "~S~%~S~%~A~%"
          (my-cmdline)
          (sb-ext:posix-environ)
          (my-get-file *load-truename*)))
