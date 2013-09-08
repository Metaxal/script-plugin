#lang racket/base
(require racket/gui/base
         racket/class
         racket/system
         racket/path
         )

(provide git-commit-file
         git-commit-all)

;; Modify this command to suit your needs
(define (make-cmd sub-cmd)
  (string-append "xterm -hold -e '" (regexp-replace* #rx"'" sub-cmd "''") "'"))

(define (cmd-system sub-cmd)
  (define cmd (make-cmd sub-cmd))
  ;(message-box "Runnning command" cmd)
  (system (string-append cmd "&")))

(define-syntax-rule (define/dir-of-file (fun f) body ...)
  (begin
    (provide fun)
    (define (fun _str #:file f)
      (when f
        (define dir (path-only f))
        (parameterize ([current-directory dir])
          body ...
          )))))

(define/dir-of-file (git-commit-file f)
  (define filename (file-name-from-path f))
  (cmd-system (string-append "git commit \"" (path->string filename) "\"")))

(define/dir-of-file (git-add-file f)
  (define filename (file-name-from-path f))
  (cmd-system (string-append "git add \"" (path->string filename) "\"")))

(define/dir-of-file (git-commit-all f)
  ; todo: save all files?
  (cmd-system "git commit -a"))

(define/dir-of-file (git-push f)
  (cmd-system "git push"))

(define/dir-of-file (git-pull-rebase f)
  (cmd-system "git pull --rebase"))
