#lang racket/base
(require browser/external
         script-plugin/utils)

; Launch http://pasterack.org/ in browser
(define-script pasterack
  #:label "Pasterack (browser)"
  #:menu-path ("&Utils")
  #:help-string "Opens 'PasteRack' An evaluating pastebin for Racket."
  (λ(str)
    (send-url "http://pasterack.org/")
    #f))
