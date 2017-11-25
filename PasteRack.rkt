#lang racket/base
(require browser/external)
; Launch http://pasterack.org/ in browser
;; string? -> (or/c string? #f)
(provide item-callback)
(define (item-callback str)
  (send-url "http://pasterack.org/")
  str)

;; See the manual in the Script/Help menu for more information.
