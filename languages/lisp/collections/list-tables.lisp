#!/usr/bin/sbcl --script
; #!/usr/bin/clisp

; http://www.gigamonkeys.com/book/practical-a-simple-database.html
;   -- save/load database based on lists

(print (getf
  (list :a 1 :b 2 :c 3)
  :b))

; (load (compile-file "hello.lisp"))

; This function works by looping over all the elements of *db* with the DOLIST
; macro, binding each element to the variable cd in turn. For each value of cd,
; you use the FORMAT function to print it.
(defvar *db* nil)
(defun dump-db ()
  (dolist (cd *db*)
    (format t "~{~a:~10t~a~%~}~%" cd)))

(defun select-by-artist (artist)
  (remove-if-not
   #'(lambda (cd) (equal (getf cd :artist) artist))
   *db*))
(select-by-artist "Dixie Chicks")
; ((:TITLE "Home" :ARTIST "Dixie Chicks" :RATING 9 :RIPPED T)
;  (:TITLE "Fly" :ARTIST "Dixie Chicks" :RATING 8 :RIPPED T))

(print (remove-if-not #'evenp '(1 2 3 4 5 6 7 8 9 10)))
(print (remove-if-not #'(lambda (x) (= 0 (mod x 2))) '(1 2 3 4 5 6 7 8 9 10)))

(defun select (selector-fn)
  (remove-if-not selector-fn *db*))
(select #'(lambda (cd) (equal (getf cd :artist) "Dixie Chicks")))

(defun artist-selector (artist)
  #'(lambda (cd) (equal (getf cd :artist) artist)))
(select (artist-selector "Dixie Chicks"))


(defun where (&key title artist rating (ripped nil ripped-p))
  #'(lambda (cd)
      (and
       (if title    (equal (getf cd :title)  title)  t)
       (if artist   (equal (getf cd :artist) artist) t)
       (if rating   (equal (getf cd :rating) rating) t)
       (if ripped-p (equal (getf cd :ripped) ripped) t))))
