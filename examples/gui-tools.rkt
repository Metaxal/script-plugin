#lang racket/base

;; See the manual in the Script/Help menu for more information.
(provide add-frame)
(define (add-frame str)
  (set! str (if (string=? str "") "my-frame" str))
  (string-append "(define " str " (new frame% [label \"" str "\"] [min-width 200] [min-height 200]))\n"
                 "(send " str " show #t)\n"))

(provide add-message)
(define (add-message str)
  (set! str (if (string=? str "") "my-message" str))
  (string-append "(define " str " (new message% [parent #f] [label \"" str "\"]))\n"))
