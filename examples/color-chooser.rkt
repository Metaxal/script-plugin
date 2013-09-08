#lang racket/base
(require racket/gui/base 
         racket/class
         racket/match
         racket/port)

;;; Laurent Orseau <laurent orseau gmail com> -- 2012-04-21

;; string? -> (or/c string? #f)
(provide item-callback)
(define (item-callback str)
  (define-values
    (r g b new-str)
    (match (port->list read (open-input-string str))
      [`((make-object color% ,(? number? r) ,(? number? g) ,(? number? b)))
       (values r g b "(make-object color% ~a ~a ~a)")]
      [`((make-color ,(? number? r) ,(? number? g) ,(? number? b)))
       (values r g b "(make-color ~a ~a ~a)")]
      [`(,(? number? r) ,(? number? g) ,(? number? b))
       (values r g b "~a ~a ~a")]
      [else (values #f #f #f "(make-color ~a ~a ~a)")]))
  (let ([c (get-color-from-user #f #f (and r (make-color r g b)))])
    (and c
         (format new-str
                 (send c red)
                 (send c green)
                 (send c blue)))))

; Select the following s-exp and click on the color-chooser script menu item:
; (make-object color% 90 158 163)
; 65 65 156
; (make-color 142 170 199)
