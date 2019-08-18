(in-package #:cl-user)

(defpackage #:fibonacci
  (:use #:cl)
  (:export #:generate
           #:generator
           #:next))

(in-package #:fibonacci)

(defun generate (n &optional (a 0) (b 1) (acc (list)))
  (if (<= n 0)
    (values (reverse acc) a b)
    (generate (1- n) b (+ a b) (push a acc))))

(defclass generator ()
  ((param-a :accessor generator-param-a :initform 0)
   (param-b :accessor generator-param-b :initform 1)))

(defgeneric next (obj)
            (:method ((obj generator))
                     (with-slots (param-a param-b) obj
                       (multiple-value-bind (result a b) (generate 1 param-a param-b)
                         (setf param-a a
                               param-b b)
                         (car result)))))

; (make-instance 'fibonacci:generator)
; (fibonacci:next (swank:lookup-presented-object 2))
