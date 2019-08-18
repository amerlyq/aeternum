#!/usr/bin/sbcl --script
;;SUMMARY: example of a X window that properly handles closing events from the WM
;;USAGE: $ ./$0
;;DEPS: |aur/clx-git|
;;REF: https://gist.github.com/TeMPOraL/f393753f4c45ac07c17563dce03903cc
;;
(require :asdf)
(handler-bind ((asdf:bad-system-name #'muffle-warning)) (require :clx))
(defpackage #:example (:use :cl) (:export #:run))
(in-package #:example)

(defun delete-window-event-p (display type data)
  (and (eq type :wm_protocols)
       (eq (xlib:atom-name display (aref data 0)) :wm_delete_window)))

(defun run (&optional (host ""))
  (let* ((display (xlib:open-display host))
         (screen (first (xlib:display-roots display)))
         (black (xlib:screen-black-pixel screen))
         (root-window (xlib:screen-root screen))
         (my-window (xlib:create-window :parent root-window
                                        :x 0
                                        :y 0
                                        :width 400
                                        :height 300
                                        :background black
                                        :event-mask (xlib:make-event-mask :exposure
                                                                          :enter-window))))
    (xlib:map-window my-window)
    (setf (xlib:wm-protocols my-window) '(:wm_delete_window))
    (format t "Protocols: ~S~%" (xlib:wm-protocols my-window))

    (xlib:event-case (display :force-output-p t
                              :discard-p t)
      (:exposure () (format t "Exposed~%"))
      (:enter-notify () nil)
      (:client-message (type format sequence data)
                       (format t "Got client message!~%~2TType: ~S~%~2TFormat: ~S~%~2TSequence: ~S~%~2TData: ~S~%"
                               type format sequence data)
                       (delete-window-event-p display type data)))

    (xlib:destroy-window my-window)
    (xlib:close-display display)))

(eval-when (:execute)
  (run))
