#lang racket/base
(require racket/system racket/path)

(define cmd
  (case (system-type 'os)
    [(unix)    "xdg-open"] ; or maybe mimeopen -n ?
    [(windows) "explorer"]
    [(macosx)  "open"]
    ))

(provide item-callback)
(define (item-callback str #:file f)
  (system (string-append cmd " \"" (path->string (path-only f)) "\""))
  #f)
