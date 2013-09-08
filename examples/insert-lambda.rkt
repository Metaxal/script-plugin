#lang racket/base
(require racket/class)

;;; Laurent Orseau <laurent orseau gmail com> -- 2012-04-21

;; Surrounds the selection with a (λ()...)
;; and places the cursor in the argument list position.
;; Places the (λ()...) in the definition editor.
;; To place it in the editor where the cursor is, replace
;; #:definitions with #:editor.
(provide item-callback)
(define (item-callback str #:definitions edit) 
  (send edit begin-edit-sequence)
  (let ([selection-start (send edit get-start-position)]
        [selection-end (+ 1 (send edit get-end-position))])
    (send* edit 
      (set-position selection-start)
      (insert ")")
      (set-position selection-end)
      (insert ")")
      (set-position selection-start)
      (insert "(λ(")))
  (send edit end-edit-sequence)
  #f)
