#!/usr/bin/cl -E main
;;SUMMARY: pick entry point based on symlink name (busybox-like )
;;USAGE: $ ln -s ./$0 {aaa,bbb} && ./$0 <aaa|bbb> [args...]
;;BINARY: $ cl-launch --output /tmp/exe --dump ! --entry main --file ./$0

(defvar *entry-fn* (string-upcase "main"))

(require :uiop)

(defun main (argv)
  (let ((callname (file-namestring (uiop:argv0)))
        (realname (file-namestring (truename (uiop:argv0))))
        entry cmdline pkg fn)

    (if (string= callname realname)
      (setf entry (first argv) cmdline (rest argv))
      (setf entry callname cmdline argv))

    ; DEBUG: (format t "Err: ~A|~A~%" entry cmdline)

    (if (not entry)
      (uiop:die 1 "Err: use symlink to original exe or specify explicit entry point: <arg1>~%"))

    (setf pkg (find-package (string-upcase entry)))
    (if (not pkg)
      (uiop:die 1 "Err: no such package: (~A)~%" entry))

    (setf fn (find-symbol *entry-fn* pkg))
    (if (not pkg)
      (uiop:die 1 "Err: no such function: (~A:~A)~%" entry *entry-fn*))

    (funcall fn cmdline))
  t)


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
