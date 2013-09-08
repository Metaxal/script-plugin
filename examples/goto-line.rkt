#lang racket/base
(require racket/gui/base racket/class)

; Sample identity function:
;; string? -> (or/c string? #f)
(provide item-callback)
(define (item-callback str #:editor ed) 
  (define line (get-text-from-user "Goto line" "Line number:"
                                   #:validate string->number))
  (when line
    (send ed set-position (send ed paragraph-start-position
                                (sub1 (string->number line)))))
  #f)

;; See the manual in the Script/Help menu for more information.
