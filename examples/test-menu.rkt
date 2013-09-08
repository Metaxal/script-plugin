#lang racket/gui

;;; Laurent Orseau <laurent orseau gmail com> -- 2012-04-23

(provide item-callback)
(define (item-callback str #:frame fr) 
  (define menu-bar (send fr get-menu-bar))
  (define menu (new menu% [parent menu-bar] [label "My Menu"]))
  (new menu-item% [parent menu] [label "Remove me"]
       [callback (λ _ (send menu delete))])
  (define count 0)
  (new menu-item% [parent menu] [label "Count me"]
       [callback (λ _ 
                   (set! count (add1 count))
                   (message-box "Count" (string-append "Count: " (number->string count)))
                   )])
  #f)

