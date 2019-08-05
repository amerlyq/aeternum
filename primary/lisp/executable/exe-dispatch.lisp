#!/usr/bin/cl -E main
;;SUMMARY: dispatch first arg as global entry point
;;USAGE: $ ./$0 <aaa|bbb> [args...]
;;BINARY: $ cl-launch --output /tmp/exe --dump ! --entry main --file ./$0

; ALT: (find-method 'fn . .)
; ALT: (fboundp 'fn)
; ALT: (symbol-function (find-symbol (string-upcase "fn")))

(defun main (argv)
  (let* ((entry (first argv))
         (args (rest argv))
         (fn (find-symbol (string-upcase entry))))
    (if entry
      (if fn
        (funcall fn args)
        ; FIXME: must return error
        (format t "Err: unknown entry point: (cl-user:~A)~%" entry))
      (format t "Err: need entry point: <arg1>~%")))
  t)

(defun aaa (argv)
  (format t "aaa ~S~%" argv)
  t)

(defun bbb (argv)
  (format t "bbb ~S~%" argv)
  t)
