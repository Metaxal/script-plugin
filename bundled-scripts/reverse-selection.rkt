#lang racket/base
(require script-plugin/utils)

;; See the manual in the Script/Help menu for more information.

(define-script reverse-selection
  #:label "Reverse selection"
  #:menu-path ("E&xamples")
  (λ(selection)
    (list->string (reverse (string->list selection)))))
