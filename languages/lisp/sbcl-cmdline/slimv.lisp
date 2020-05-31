#!/usr/bin/sbcl --script
;;SUMMARY: use universal (main) function

;; TODO: allow connecting slime directly to running cmdline app
;  REF: https://common-lisp.net/project/slime/doc/html/Setting-up-the-lisp-image.html#Setting-up-the-lisp-image
;  READ:VIZ: https://github.com/LispCookbook/cl-cookbook/issues/115
;;TARG
;  (load "/path/to/swank-loader.lisp")
;  (swank-loader:init)
;  (swank:create-server)
;  (swank:create-server :port 4005  :dont-close t :coding-system "utf-8-unix")
;;HOST
;>> M-x slime-connect RET RET
;OR: manually
;  (setq slime-net-coding-system 'utf-8-unix)
;  (slime-connect "localhost" 4005))
;  (add-to-list 'slime-filename-translations
;     (slime-create-filename-translator
;      :machine-instance "remote"
;      :remote-host "remote.example.com"
;      :username "user"))

(setf swank:*use-dedicated-output-stream* nil)

(defpackage #:example
  (:use :cl)
  (:export :main))
(in-package #:example)

(defun main (&key (myvar 2000))
  (format t "~A~%" myvar))

(eval-when (:execute)
  (main))

;; HACK: main entry point for services -- on error wait for SLIME connection
;; SRC: https://github.com/LispCookbook/cl-cookbook/issues/115
; (defun launch-daemon (&optional (port 4005))
;   (ql:quickload :swank)
;   (handler-case (swank:create-server :port port :dont-close t)
;     (error ())
;     ; (main)
;     ))
