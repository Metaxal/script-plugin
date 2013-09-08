#lang racket/base

(require racket/gui/base
         racket/class
         setup/dirs)

;; Pops up a get-file dialog to open a file, starting in Racket's collects directory
(provide item-callback)
(define (item-callback str #:frame frame)
  (define f (get-file "Open a script" #f (find-collects-dir) #f #f '() 
                      '(("Racket" "*.rkt"))))
  (when f
    (send frame open-in-new-tab f))
  #f)

