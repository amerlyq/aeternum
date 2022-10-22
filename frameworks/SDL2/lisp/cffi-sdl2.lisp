#!/usr/bin/sbcl --script
;;SUMMARY: show RGB window by ffi only
;;USAGE: $ ./$0
;;SRC https://www.thejach.com/view/2020/11/hello_world_to_get_with_the_times_using_sdl2_and_common_lisp
;;
#|Public domain. Does not unwind-protect errors like it should.|#
(in-package #:cl-user)
(defpackage #:sdl-intro
  (:use #:common-lisp))
(in-package #:sdl-intro)

(load "~/quicklisp/setup.lisp")
(ql:quickload "sdl2")

(defun null-ptr? (alien-val)
  (cffi:null-pointer-p (autowrap:ptr alien-val)))

(defun render-then-quit (&aux (w 800) (h 600) sz screen renderer texture buffer buffer-ptr)
  (setf sz (* w h))

  (unless (zerop (sdl2-ffi.functions:sdl-init sdl2-ffi:+sdl-init-video+))
    (error "Could not init"))

  (setf screen (sdl2-ffi.functions:sdl-create-window
                 "Tiny Renderer"
                 sdl2-ffi:+sdl-windowpos-undefined+ sdl2-ffi:+sdl-windowpos-undefined+ ; let the OS position window
                 w h
                 sdl2-ffi:+sdl-window-opengl+))
  (if (null-ptr? screen)
      (error "Could not make window screen"))

  (setf renderer (sdl2-ffi.functions:sdl-create-renderer
                   screen -1 0)) ; default monitor, no flags like vsync
  (if (null-ptr? renderer)
      (error "Could not make renderer"))

  (setf texture (sdl2-ffi.functions:sdl-create-texture
                  renderer
                  sdl2-ffi:+sdl-pixelformat-argb8888+
                  sdl2-ffi:+sdl-textureaccess-streaming+
                  w h))
  (if (null-ptr? texture)
      (error "Could not make texture"))

  (setf buffer (make-array sz :initial-element 0 :element-type '(unsigned-byte 32)))

  (loop for x from (* w 150) to (* w 250) do
        (setf (aref buffer x) #xFFFF0000)) ; red
  (loop for x from (* w 250) to (* w 350) do
        (setf (aref buffer x) #xFF00FF00)) ; green
  (loop for x from (* w 350) to (* w 450) do
        (setf (aref buffer x) #xFF0000FF)) ; blue

  (setf buffer-ptr (cffi:foreign-array-alloc buffer `(:array :uint32 ,sz)))
  ;(cffi:lisp-array-to-foreign buffer buffer-ptr `(:array :uint32 ,sz)) ; if ptr allocated separately

  (unless (zerop (sdl2-ffi.functions:sdl-update-texture texture nil buffer-ptr (* w (cffi:foreign-type-size :uint32))))
    (error "Could not update texture"))

  (cffi:foreign-array-free buffer-ptr)

  ; technically clearing is not needed since the texture is the size of the screen, but
  ; if another program drew over the display (like steam overlay) this would make sure
  ; it doesn't hang around.
  (sdl2-ffi.functions:sdl-set-render-draw-color renderer 0 0 0 255)
  (sdl2-ffi.functions:sdl-render-clear renderer)
  (sdl2-ffi.functions:sdl-render-copy renderer texture nil nil) ; copy the whole thing
  (sdl2-ffi.functions:sdl-render-present renderer)

  (sleep 5)

  (sdl2-ffi.functions:sdl-destroy-texture texture)
  (sdl2-ffi.functions:sdl-destroy-renderer renderer)
  (sdl2-ffi.functions:sdl-destroy-window screen)

  (sdl2-ffi.functions:sdl-quit))

(render-then-quit)
