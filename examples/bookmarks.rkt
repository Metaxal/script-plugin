#lang racket/gui

#|
Bookmarks are "anchors" as comments in the source code, and thus are part of the file
(but they are very little invasive and can be used, for example, as section headers).

Each time the user uses "Go to line" or "Save line number" or uses a bookmark,
the current line position is saved.
The user can use "Go to previous line" to go back to the latest saved position.
The full history is saved, so the user can get back like in an undo list.

|#

(define saved-lines (make-hash))

(define (save-current-line! ed)
  (define ln (send ed position-paragraph (send ed get-start-position)))
  (hash-set! saved-lines ed
             (cons ln (hash-ref! saved-lines ed '()))))

(define (pop-saved-line! ed)
  (define lines (hash-ref! saved-lines ed '()))
  (if (empty? lines)
      #f
      (begin0 (first lines)
              (hash-set! saved-lines ed (rest lines)))))
         
(define (ed-goto-line ed ln)
  (define l-start (box #f))
  (define l-end (box #f))
  (send ed get-visible-line-range l-start l-end)
  ;(message-box "auie" (~a (list (unbox l-start) (unbox l-end))))
  (send ed set-position (send ed paragraph-start-position ln))
  (send ed scroll-to-position (send ed paragraph-start-position (- ln  5)))
  (send ed scroll-to-position (send ed paragraph-start-position (+ ln (- (unbox l-end) (unbox l-start) 5))))
  )

;; Saves the current line to be used with goto-previous
(provide temp-bookmark)
(define (temp-bookmark str #:editor ed)
  (save-current-line! ed)
  #f)

;; Saves the current line, and asks for the line to go to
(provide goto-line)
(define (goto-line str #:editor ed) 
  (define line (get-text-from-user "Go to line" "Line number:"
                                   #:validate string->number))
  (define lnum (and line (string->number line)))
  (when lnum
    (save-current-line! ed)
    (ed-goto-line ed (sub1 lnum)))
  #f)

;; Goes to the previous saved location 
(provide goto-previous)
(define (goto-previous str #:editor ed)
  ;(message-box "saved lines" (~a saved-lines))
  (define ln (pop-saved-line! ed))
  (when ln 
    (ed-goto-line ed ln))
  #f)
    
;; Shows the list of bookmarks
(provide bookmarks)
(define (bookmarks str #:definitions ed) 
  (define txt (send ed get-text))
  (define marks
    (filter values
            (for/list ([line (in-lines (open-input-string txt))]
                       [i (in-naturals)])
              ;(define m (regexp-match #px"^\\s*;@@\\s*(.*)" line))
              ; To be usable with section headers:
              (define m (or (regexp-match #px";(?:@@*|==*|::*)\\s*(.*[\\w-].*?)[@=:;]*" line)
                            (regexp-match #px"#:title \"(.*)\"" line))) ; for slideshow
              (and m (list i (second m))))))
  ;(message-box "Bookmarks" (string-append* (add-between (map ~a marks) "\n")))
  (bookmark-frame marks ed)
  #f)

;; Adds a bookmark on the current line
(provide add-bookmark)
(define (add-bookmark str)
  (string-append ";@@ " (if (string=? str "") 
                            (format "bookmark name")
                            str)))

;@@ Here and now

(define (bookmark-frame marks ed)
  (define topwin (send ed get-top-level-window))
  (define fr (new frame% [parent #f]
                  [label "Bookmarks"]
                  [min-width 300] [min-height 300]))
  (define msg (new message% [parent fr] [label "Press <space> to select"]))
  (define (list-box-select lb)
    (define sel (send lb get-selection))
    (when sel
      (save-current-line! ed)
      (ed-goto-line ed (first (list-ref marks sel))))
    (when (send cb get-value)
      (send fr show #f)))
  (define lb (new list-box% [label #f]
                  [parent fr]
                  [choices (map second marks)] ; show line number too?
                  [callback (λ(lb ev)
                              (print (send ev get-event-type))
                              (when (eq? (send ev get-event-type) 'list-box-dclick)
                                (list-box-select lb)))]
                  ))
  (define cb (new check-box% [parent fr] [label "Close on select?"] [value #t]))
  (define bt (new button% [parent fr] [label "Go!"] [callback (λ _ (list-box-select lb))]))
  ; Center frame on parent frame
  (send fr reflow-container)
  (send fr move (+ (send topwin get-x) (round (/ (- (send topwin get-width) (send fr get-width)) 2)))
        (+ (send topwin get-y) (round (/ (- (send topwin get-height) (send fr get-height)) 2))) )
  (send lb focus)
  (send fr show #t))

;@@ Another bookmark


;; See the manual in the Script/Help menu for more information.
