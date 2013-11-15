#lang racket/base

(require setup/xref
         scribble/xref
         scribble/manual-struct
         racket/class
         racket/list
         racket/format
         racket/string
         racket/gui/base)

(define x (load-collections-xref))
(define idx (xref-index x)) ; list of `entry's

(define (search word)
  (filter (λ(e) (regexp-match word (first (entry-words e))))
          idx))

(define (entry->list e)
  (list (entry-words e)
        (entry-tag e)
        (entry-desc e)))

(define (entry->string e)
  (define desc (entry-desc e))
  (if (exported-index-desc? desc)
      (format "~a\n  Provided by: ~a\n" 
              (first (entry-words e))
              #;(entry-desc e)
              (exported-index-desc-from-libs desc))
      ""))

(provide item-callback)
(define (item-callback s #:editor ed)
  (define start-pos (send ed get-start-position))
  (define end-pos   (send ed get-end-position)) 
  (define start-exp-pos
    (or (send ed get-backward-sexp start-pos) start-pos))
  (define end-exp-pos
    (or (send ed get-forward-sexp (- end-pos 1)) end-pos))
  (define str
    (send ed get-text start-exp-pos end-exp-pos))
  
  (message-box "Info" (string-join (map entry->string (search str)) "\n"))
  #f)
