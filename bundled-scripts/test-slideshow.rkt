#lang racket/base
(require racket/class 
         racket/gui/base
         script-plugin/utils
         pict)

(define (pict->snip pic)
  (make-object image-snip% (pict->bitmap pic)))

(define-script insert-slideshow
  #:label "Insert slideshow pict"
  #:menu-path ("E&xamples")
  (λ(str)
    (pict->snip
     (hc-append -10
                (colorize (angel-wing 100 80 #t) "orange")
                (jack-o-lantern 100)
                (colorize (angel-wing 100 80 #f) "orange")))))