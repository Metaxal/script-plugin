#lang racket/base
(require racket/date)

;;; 4 shortcuts to print the author [email] date [time] 
;;; Laurent Orseau <laurent orseau gmail com> -- 2012-04-19

; Replace by your own data:
(define auth "Laurent Orseau")
(define email "<laurent orseau gmail com>")

(define (date-iso [time? #f])
  (parameterize ([date-display-format 'iso-8601])
    (date->string (current-date) time?)))

(define (author [email? #f])
  (if email?
      (string-append auth " " email)
      auth))

(define (author-date-all [email? #f] [time? #f]) 
  (string-append (author email?) " -- " 
                 (date-iso time?)))

(provide author-date)
(define (author-date str) 
  (author-date-all #f #f))

(provide author-date-time)
(define (author-date-time str) 
  (author-date-all #f #t))

(provide author-email-date)
(define (author-email-date str) 
  (author-date-all #t #f))

(provide author-email-date-time)
(define (author-email-date-time str) 
  (author-date-all #t #t))

(provide license-wtfpl)
(define (license-wtfpl str) 
  "License: WTFPL - http://www.wtfpl.net")

(provide license-mit)
(define (license-mit str) 
  "License: MIT - http://opensource.org/licenses/MIT")
