#!/usr/bin/sbcl --script
;;SUMMARY: parse cmdline options
;;DEPS: $ sudo sbcl --noprint --load /etc/default/quicklisp --script /dev/stdin <<< '(ql:quickload :unix-opts)'
;;REF: https://github.com/libre-man/unix-opts/blob/master/example/example.lisp

(require :asdf)
(eval-when (:compile-toplevel :load-toplevel :execute)
  (load "/etc/default/quicklisp")
  (handler-bind ((asdf:bad-system-name #'muffle-warning))
    (require :unix-opts)))

(defpackage #:example (:use :cl))
(in-package #:example)

(opts:define-opts
  (:name :help
   :description "print this help text"
   :short #\h
   :long "help")
  (:name :verbose
   :description "verbose output"
   :short #\v
   :long "verbose")
  (:name :level
   :description "the program will run on LEVEL level"
   :required t
   :short #\l
   :long "level"
   :arg-parser #'parse-integer
   :meta-var "LEVEL")
  (:name :output
   :description "redirect output to file FILE"
   :short #\o
   :long "output"
   :arg-parser #'identity
   :meta-var "FILE"))


(defun unknown-option (condition)
  (format t "warning: ~s option is unknown!~%" (opts:option condition))
  (invoke-restart 'opts:skip-option))

(defmacro when-option ((options opt) &body body)
  `(let ((it (getf ,options ,opt)))
     (when it
       ,@body)))

(eval-when (:execute)
  (multiple-value-bind (options free-args)
      (handler-case
          (handler-bind ((opts:unknown-option #'unknown-option))
            (opts:get-opts))
        (opts:missing-arg (condition)
          (format t "fatal: option ~s needs an argument!~%"
                  (opts:option condition)))
        (opts:arg-parser-failed (condition)
          (format t "fatal: cannot parse ~s as argument of ~s~%"
                  (opts:raw-arg condition)
                  (opts:option condition)))
        (opts:missing-required-option (con)
          (format t "fatal: ~a~%" con)
          (opts:exit 1)))
    ;; Here all options are checked independently, it's trivial to code any
    ;; logic to process them.
    (when-option (options :help)
      (opts:describe
      :prefix "example—program to demonstrate unix-opts library"
      :suffix "so that's how it works…"
      :usage-of "example.sh"
      :args     "[FREE-ARGS]"))
    (when-option (options :verbose)
      (format t "OK, running in verbose mode…~%"))
    (when-option (options :level)
      (format t "I see you've supplied level option, you want ~a level!~%" it))
    (when-option (options :output)
      (format t "I see you want to output the stuff to ~s!~%"
              (getf options :output)))
    (format t "free args: ~{~a~^, ~}~%" free-args)))
