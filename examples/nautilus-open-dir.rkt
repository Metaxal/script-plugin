#lang racket/base
(require racket/system racket/path)

(provide item-callback)
(define (item-callback str #:file f)
  (system (string-append "nautilus " (path->string (path-only f))))
  #f)
