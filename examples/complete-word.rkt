#lang racket/base
(require racket/class racket/dict racket/list)

;;; Replaces the text abbreviation right before the caret by some expanded text
;;; Laurent Orseau <laurent orseau gmail com> -- 2012-04-19

;; TODO: Place selected text inside the inserted left and right parts.

(define words
  '(("dsr"   "(define-syntax-rule (" ")\n  )")
    ("ds"    "(define-syntax " "\n  )")
    ("sr"    "(syntax-rules ()\n    [(_ " ")])")
    ("sc"    "(syntax-case stx ()\n    [(_ " ")])")
    ("dsm"   "(define-simple-macro (" ")\n  )")
    ("lbd"   "(λ(" ")")
    ("param" "(parameterize ([current-" "])\n  )")
    ("wh"    "(with-handlers ([exn:" "])\n  )")
    ("wiff"  "(with-input-from-file " "\n  (λ _ ))")
    ("wotf"  "(with-output-to-file " " #:exists 'replace\n  (λ _ ))")
    
    ; slideshow:
    ("slide"    "(slide #:title \"" "\"\n       )")
    ("item"     "@item{" "}")
    ("subitem"  "@subitem{" "}")
    ("$"        "@${" "}")
    ("$$"       "@$${" "}")
    ))

(provide item-callback)
(define (item-callback s #:editor ed)
  (define pos (send ed get-end-position)) 
  (define str
    (send ed get-text 
          (send ed get-backward-sexp pos) 
          pos))
  (define str-ext (dict-ref words str #f))
  (define left (if (list? str-ext) (first str-ext) str-ext))
  (define right (and (list? str-ext) (second str-ext)))
  (when str-ext
    (send ed begin-edit-sequence)
    (send ed select-backward-sexp)
    (send ed insert left)
    (when right
      (define ipos (send ed get-start-position))
      (send ed insert right)
      (send ed set-position ipos))
    (send ed end-edit-sequence))
  #f)
  
#;(
   item
   para
   wh
   $$
   )