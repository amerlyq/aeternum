#!/usr/bin/sbcl --script
;;SUMMARY: create simple empty screen
;;USAGE: $ ./$0
;;DEPS: |aur/cl-airy|
;;
(require :asdf)
(handler-bind ((asdf:bad-system-name #'muffle-warning)) (require :sdl2))
(defpackage #:example (:use :cl))
(in-package #:example)

; SEIZE
; https://github.com/lispgames/cl-sdl2/tree/master/examples
; https://github.com/TatriX/cl-sdl2-tutorial/tree/master/1
; http://landoflisp.com/source.html
; TRY: https://tamillisper.blogspot.com/2013/05/game-of-life-using-commonlisp-sdlopengl.html

; [_] TODO: pass color through cmdline argv
; [_] TODO: use cl-launch instead of raw sbcl

;;;;;;;;;;;;;;;;

(defparameter *screen-width* 640)
(defparameter *screen-height* 480)

(defun main (&key (delay 2000))
  (sdl2:with-init (:video)
    (sdl2:with-window (window :title "SDL2 Window" :w *screen-width* :h *screen-height*)
      (let ((screen-surface (sdl2:get-window-surface window)))
        (sdl2:fill-rect screen-surface
                        nil
                        (sdl2:map-rgb (sdl2:surface-format screen-surface) 255 255 255))
        (sdl2:update-window window)
        (sdl2:delay delay)))))
