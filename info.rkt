#lang setup/infotab

(define deps (list "base"))

(define name                 "User Script Plugin")
(define drracket-tools       '(("tool.rkt")))
(define drracket-tool-names  '("Script Plugin"))
(define drracket-tool-icons  '(#f))

(define scribblings '(("scribblings/manual/manual.scrbl" () (tool 3.2))))

(define blurb
  '("Easily make plugin scripts for DrRacket."
    (p (it "Script examples:")
       " On-screen documentation, Git commands, Word completion, Bookmarks, Regexp-replace in selection, Code snippets, Table spacing (auto-spacer), Color chooser, Title/sections comment maker...")))

(define required-core-version  "5.0")
(define repositories           '("4.x"))
(define categories             '(devtools))

(define can-be-loaded-with  'none)
(define primary-file        "tool.rkt")

(define version "1.15")
(define release-notes
  '((ul
     (li "New scripts")
     (ul (li "open-collects: Shortcut to open a racket collection file")
         (li "open-dir: Opens the OS explorer in the directory of the current file")
         (li "git: Unix-specific (uses xterm); Modify to suit your needs")
         (li "Use 'Scripts/Import bundled script'"))
     (li "The script menu does not reload itself on each menu click anymore. It must now be reloaded explicitly with Scripts/Manage scripts/Reload scripts menu")
     (li "Feedback welcome")
     )))
