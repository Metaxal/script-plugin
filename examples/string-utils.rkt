#lang racket/base

;;; Laurent Orseau <laurent orseau gmail com> -- 2012-04-21

(provide upper-case)
(define (upper-case str)
  (string-upcase str))

(provide lower-case)
(define (lower-case str)
  (string-downcase str))

(provide reverse-string)
(define (reverse-string str)
  (list->string (reverse (string->list str))))
