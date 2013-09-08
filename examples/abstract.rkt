#lang racket/gui


;; Demo: https://www.youtube.com/watch?v=qgjAZd4eBBY

; Sample identity function:
;; string? -> (or/c string? #f)
(provide item-callback)
(define (item-callback str) 
  (define var (get-text-from-user "Variable Abstraction" "Variable name:"
                                  #:validate (λ(s)#t)))
  (if var
      (begin
        (send the-clipboard set-clipboard-string 
              (string-append "(define " var " " str ")")
              0)
        var)
      str))

