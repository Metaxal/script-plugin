#lang racket/base
(require racket/gui/base racket/class racket/match)

;;; Laurent Orseau <laurent orseau gmail com> -- 2012-04-21

;; string? -> (or/c string? #f)
(provide item-callback)
(define (item-callback str)
  (define c-old 
    (match (read (open-input-string str))
      [(list 'make-object 'color% r g b)
       (make-object color% r g b)]
      [else #f]))
  (let ([c (get-color-from-user #f #f c-old)])
    (and c
         (format "(make-object color% ~a ~a ~a)"
                 (send c red)
                 (send c green)
                 (send c blue)))))

; Select the following s-exp and click on the color-chooser script menu item:
; (make-object color% 77 156 161)
