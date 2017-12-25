#lang racket/base
(require racket/system
         racket/path
         script-plugin/utils)

(define-script open-terminal
  #:label "Open terminal here"
  #:menu-path ("&Utils")
  (λ(str #:file f) 
    (define dir (path->string (path-only f)))
    (system (string-append "gnome-terminal"
                           " --working-directory=\"" dir "\""
                           " -t \"" dir "\""
                           "&"))
    #f))

