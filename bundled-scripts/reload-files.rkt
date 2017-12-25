#lang racket/base
(require racket/class
         racket/format
         racket/gui/base
         script-plugin/utils)

;; WARNING: does not currently work

(define-script reload-files
  #:label "Reload files"
  (λ(str #:frame fr)
    (define tabs (send fr get-tabs))
    (message-box "auie" 
                 (~v (for/list ([i (send fr get-tab-count)])
                       (send fr get-tab-filename i))))
    ; todo: reload all tabs
    #f))
