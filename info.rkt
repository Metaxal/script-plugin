#lang setup/infotab

(define deps (list "base"))

(define name                 "User Script Plugin")
(define drracket-tools       '(("tool.rkt")))
(define drracket-tool-names  '("Script Plugin"))
(define drracket-tool-icons  '(#f))

(define scribblings '(("scribblings/manual/manual.scrbl" () (tool 3.3))))

(define blurb
  '("Easily make plugin scripts for DrRacket."
    (p (it "Script examples:")
       " On-screen documentation, Git commands, Word completion, Bookmarks, Regexp-replace in selection, Code snippets, Table indent, Color chooser, Title/sections comment maker...")))

(define required-core-version  "5.0")
(define repositories           '("4.x"))
(define categories             '(devtools))

(define can-be-loaded-with  'none)
(define primary-file        "tool.rkt")
