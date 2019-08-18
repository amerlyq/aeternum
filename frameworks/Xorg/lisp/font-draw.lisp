#!/usr/bin/sbcl --script
;;SUMMARY: draw text in window
;;DEPS: $ sudo sbcl --noprint --load /etc/default/quicklisp --script /dev/stdin <<< '(ql:quickload :clx)'
;;REF: https://github.com/informatimago/hw
;;
(require :asdf)
(eval-when (:compile-toplevel :load-toplevel :execute)
  ; ALT: (load (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname)))
  (load "/etc/default/quicklisp")
  (handler-bind ((asdf:bad-system-name #'muffle-warning))
    ; (require :clx-truetype)
    (require :clx)))

(defpackage #:example (:use :cl :xlib))
(in-package #:example)

(defun main (&optional
              (host "")
              (display 0)
              (string "Xorg window with text")
              (font "fixed")
              &rest args)
  (let* ((display  (open-display host :display display))
         (screen (display-default-screen display))
         (black (screen-black-pixel screen))
         (white (screen-white-pixel screen))
         (font (open-font display font))
         (width  640) (height 480)
         (x 100) (y 100)
         (window (create-window :parent (screen-root screen)
                                :x x :y y
                                :width width :height height
                                :background black
                                :border white
                                :border-width 1
                                :colormap (screen-default-colormap screen)
                                :bit-gravity :center
                                :event-mask '(:exposure :button-press)))
         (gcontext (create-gcontext :drawable window
                                    :background black
                                    :foreground white
                                    :font font)))
    ;;NOTE: set misc hints for WM
    (set-wm-properties window
                       :name 'main
                       :icon-name string
                       :resource-name string
                       :resource-class 'main
                       :command (list* 'main host args)
                       :x x :y y :width width :height height
                       :min-width width :min-height height
                       :input :off :initial-state :normal)

    (map-window window)

    (event-case (display :discard-p t :force-output-p t)
                (exposure  (window count)
                           (when (zerop count) ;; use only last event "shown on screen"
                             (with-state (window)
                                         (let ((x (truncate (- (drawable-width window) width) 2))
                                               (y (truncate (- (+ (drawable-height window)
                                                                  (max-char-ascent font))
                                                               (max-char-descent font))
                                                            2)))
                                           ;; Draw centered text
                                           (clear-area window)
                                           (draw-glyphs window gcontext x y string)))
                             nil))  ;; VIZ: "nil" = continue, "t" = exit event-case
                (button-press () t)))  ;; Pressing any mouse-button exits


  (close-display display :abort nil))


(eval-when (:execute)
  ; ALT: (main "127.0.0.1" :display 1)
  (main))
