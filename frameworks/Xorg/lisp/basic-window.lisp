#!/usr/bin/sbcl --script
;;SUMMARY: basic client-server echo service
;;DEPS: $ sudo sbcl --noprint --load /etc/default/quicklisp --script /dev/stdin <<< '(ql:quickload :clx)'
;;
(require :asdf)
(eval-when (:compile-toplevel :load-toplevel :execute)
  (load "/etc/default/quicklisp")
  (handler-bind ((asdf:bad-system-name #'muffle-warning))
    (require :clx)))

(defpackage #:example (:use :cl :xlib))
(in-package #:example)


(let ((display (open-default-display)))
  (unwind-protect
    (let* ((window (create-window :parent (screen-root (display-default-screen display))
                                  :x 10
                                  :y 10
                                  :width 100
                                  :height 100
                                  :event-mask '(:exposure :key-press)))
           (gc (create-gcontext :drawable window)))
      (map-window window)
      (event-case (display :discard-p t)
                  (exposure ()
                            (draw-rectangle window gc 20 20 10 10 t)
                            (draw-glyphs window gc 10 40 "Hello, World!")
                            nil #| continue receiving events |#)
                  (key-press ()
                             t #| non-nil result signals event-case to exit |#))))
  (close-display display))
