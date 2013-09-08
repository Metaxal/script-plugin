#lang racket/base
(require racket/system racket/path)

(provide item-callback)
(define (item-callback str  #:file f) 
  (define dir (path->string (path-only f)))
  (system (string-append "gnome-terminal"
                         " --working-directory=\"" dir "\""
                         " -t \"" dir "\""
                         "&"))
  str)

