#lang racket/base
(require script-plugin/utils)

(define-script current-file-example
  #:label "Current file example"
  #:menu-path ("E&xamples")
  #:output-to message-box
  (λ(selection #:file f)
    (string-append "File: " (if f (path->string f) "no-file")
                   "\nSelection: " selection)))
