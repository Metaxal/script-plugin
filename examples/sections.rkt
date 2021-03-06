#lang racket/base
(require srfi/13 (only-in racket/gui/base get-text-from-user))

;;; Laurent Orseau <laurent orseau gmail com> -- 2012-04-21

;;; Surrounds the selected text by comments ASCII frames.
;;; Asks for input if nothing is selected.

(define (surround-char str char [prefix ""] [suffix (string-reverse prefix)])
  (let ([line (string-append prefix (build-string (+ 4 (string-length str)) (λ(i) char)) suffix "\n")])
    (string-append 
     line
     prefix (string char) " " str " " (string char) suffix "\n"
     line)))

(define (string-or-from-user section str)
  (if (string=? str "")
      (get-text-from-user section (string-append "Enter a " section ":"))
      str))

(define-syntax-rule (define-section (fun label str2) body ...)
  (begin
    (provide fun)
    (define (fun str)
      (define str2 (string-or-from-user label str))
      (and str2
           (begin body ...)))))

(define-section (title "Title" str)
  (let* ([str (string-titlecase str)]
         [spaces (build-string (max 0 (quotient (- 77 (string-length str)) 2))
                               (λ(n)#\space))])
    (surround-char 
     (string-append spaces str spaces)
     #\* ";***")))

(define-section (section "Section" str)
  (surround-char str #\= ";=="))

(define-section (subsection "Subsection" str)
  (surround-char str #\: ";:"))

(define-section (subsubsection "Subsubsection" str)
  (surround-char str #\- ";"))

(module+ main
  (displayln (title "this is the title"))
  (displayln (section "Section"))
  (displayln (subsection "Subsection"))
  (displayln (subsubsection "Subsubsection"))
  
  (displayln (title ""))
  )
