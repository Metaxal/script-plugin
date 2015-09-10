#lang racket/base
(require racket/class)

(define ((enter-submod submod) str #:interactions editor)
  (send* editor
    (insert
     (format "(require (only-in racket/enter dynamic-enter!)
           (only-in syntax/location quote-module-path))
(dynamic-enter! (quote-module-path ~a))" submod))))

(provide enter-drracket)
(define enter-drracket (enter-submod 'drracket))

(provide enter-test)
(define enter-test (enter-submod 'test))

(provide enter-main)
(define enter-main (enter-submod 'main))
