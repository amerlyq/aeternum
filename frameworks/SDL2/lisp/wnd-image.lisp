#!/usr/bin/sbcl --script
;;SUMMARY: load image into screen
;;USAGE: $ ./$0
;;DEPS: |aur/cl-airy|
;;
(require :asdf)
(handler-bind ((asdf:bad-system-name #'muffle-warning)) (require :sdl2))
(defpackage #:example (:use :cl))
(in-package #:example)

;;;;;;;;;;;;;;;;
(defvar *program-dir* (directory-namestring *load-truename*))
(defvar *assets-dir* (namestring (truename (merge-pathnames "../../_rc" *program-dir*))))
(defvar *img-path* (namestring (merge-pathnames "img/cat.bmp" *assets-dir*)))

(defparameter *screen-width* 640)
(defparameter *screen-height* 480)

(defmacro with-window-surface ((window surface) &body body)
  `(sdl2:with-init (:video)
                   (sdl2:with-window (,window
                                       :title "SDL2 Tutorial"
                                       :w *screen-width*
                                       :h *screen-height*
                                       :flags '(:shown))
                                     (let ((,surface (sdl2:get-window-surface ,window)))
                                       ,@body))))

(defun main(&key (delay 2000))
  (with-window-surface (window screen-surface)
                       (sdl2:blit-surface (sdl2:load-bmp *img-path*)
                                          nil
                                          screen-surface
                                          nil)
                       (sdl2:update-window window)
                       (sdl2:delay delay)))

(eval-when (:execute)
  (main))
