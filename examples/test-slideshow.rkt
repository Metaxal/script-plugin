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
  (define pic (hc-append (colorize (filled-rectangle 10 10) "blue")
                         (colorize (disk 20) "green")
                         (colorize (filled-rectangle 10 30) "red")))
  (send* ed
    (insert "--> ")
    (insert (pict->snip pic))
    (insert " <--"))
  
  #f)
