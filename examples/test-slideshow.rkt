#lang racket/base

;;; Laurent Orseau <laurent orseau gmail com> -- 2012-04-21

(require racket/class 
         slideshow
         racket/gui/base)

(define (pict->snip pic)
  (make-object image-snip% (pict->bitmap pic)))
 
(define (at pic x y)
  (vc-append (blank x) (hc-append (blank y) pic)))

(provide item-callback)
(define (item-callback str #:editor ed)
  (define pic
    (apply hc-append
           (for/list ([w (regexp-split #px"\\s+" str)])
             (text w '() 24 (/ pi 6))
             )))
  (send ed insert
        (pict->snip 
         (cc-superimpose (colorize pic "black")
                         (colorize (at pic 3 3) "white"))))
  #f)
