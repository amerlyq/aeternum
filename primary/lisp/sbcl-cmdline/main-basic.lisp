#!/usr/bin/sbcl --script
;;SUMMARY: basic main

(defun main ()
  (write-line "main")
  t)

(eval-when (:execute)
  (main))
