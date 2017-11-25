#|
Copyright (c) 2012 Laurent Orseau (laurent orseau gmail com)

License: LGPL v3 or higher (http://www.gnu.org/copyleft/lesser.html)

|#
#lang racket/base

(require drracket/tool
         racket/class
         racket/gui/base
         racket/unit
         racket/string
         racket/file
         racket/pretty ; for pretty-write
         racket/path ; for filename-extension
         racket/dict
         racket/list
         racket/runtime-path ; for the help menu
         help/search
         (for-syntax racket/base) ; for help menu
         net/sendurl ; for the help menu
         framework ; for preferences (too heavy a package?)
         planet/version ; for bug report
         )
(provide tool@)

#| TODO:
- Simplify the user's work: Remove the .rktd file, keep only the rkt file, and 
  take only the "exported" procedures for a menu item.
  It must also be possible to give a location for the script in the menu, and a string, 
  and a keybinding. Use submodules instead?
  Use the name of the function as the string item?
  Make a language or a collection that can be required to have access to useful tools 
  to create a new menu item, like a macro with keywords to define the keybinding, string, etc.?
  A language would be better, so that only the line #lang script-plugin is necessary.
- Follow folder organization for the menus?
- rethink the rktd file
  Use a logical hierarchy. Sub-menus and menu items, and have a dictionary hierarchy according to that
  (currently it's a bit messy)
- Bundled scripts should be updated automatically. Keep a separate directory for user's scripts?
- import menu: allow to import only the rktd file (ask for overwrite for both files)
- automatic testing with the framework
- auto-load (+ automatically persistent): a script is automatically run as soon as possible,
  no need to click on a menu. Usefull to add some menu to DrRacket?
  - may require to add a 'on-exit' method, that is run when 'Unload persistent scripts' is clicked.
- rename "examples" directory to "scripts" or "bundled-scripts"

Scripts:
- new file in same directory
- "command line" bar? Opens a small frame (with shortcut) where queries can be made
- Make an Overview frame for scrbl (or LaTeX) documents, with links to (sub)sections; 
  This could also be added as an automatically refreshed menu to DrRacket
|#

(define-logger script-plugin)

(define-runtime-path examples-path
  (build-path "examples"))

(define base-default-user-script-dir (find-system-path 'pref-dir))

(preferences:set-default 'user-script-dir
                         (path->string (build-path base-default-user-script-dir 
                                                   "user-scripts"))
                         path-string?)

(define (script-dir)
  (preferences:get 'user-script-dir))

(log-script-plugin-info "Using script-directory: ~a" (script-dir))

; Copy sample scripts at installation (or if user's script directory does not exist):
(unless (directory-exists? (script-dir))
  (make-directory* base-default-user-script-dir)
  ;(message-box "copy scripts" "The scripts are being copied to your user directory")
  (copy-directory/files examples-path (script-dir)))

(define (set-script-dir dir)
  (preferences:set 'user-script-dir (if (path? dir) (path->string dir) dir)))

(define (choose-script-dir)
  (let ([d (get-directory "Choose a directory to store scripts" #f
                          (script-dir))])
    (when d (set-script-dir d))))

(define (error-message-box filename e)
  (message-box filename
               (format "Error in script file ~s: ~a" filename (exn-message e))
               #f '(stop ok)))

(define-namespace-anchor a)

;; the preference panel is automatically added by DrRacket (nice feature!)
(preferences:add-panel 
 "Scripts"
 (λ(parent)
   (define pref-panel (new vertical-panel% [parent parent] 
                           [alignment     '(center center)]
                           [spacing       10]
                           [horiz-margin  10]
                           [vert-margin   10]
                           ))
   (define dir-panel (new horizontal-panel% [parent pref-panel]))
   (define text-dir (new text-field% [parent dir-panel] 
                         [label       "Script directory:"]
                         [init-value  (script-dir)]
                         [enabled     #f]))
   (new button% [parent dir-panel] 
        [label     "Change script directory"]
        [callback  (λ _ (choose-script-dir))])
   (preferences:add-callback 'user-script-dir
                             (λ(p v)(send text-dir set-value v)))
   pref-panel))
 

(define tool@
  (unit
    (import drracket:tool^)
    (export drracket:tool-exports^)
 
    (define script-menu-mixin
      (mixin (drracket:unit:frame<%>) ()
        (super-new)
        (inherit get-button-panel
                 get-definitions-text
                 get-interactions-text
                 ;register-toolbar-button
                 create-new-tab
                 )
        
        (define (get-the-text-editor)
          ; for a frame:text% :
          ;(define text (send frame get-editor))
          ; for DrRacket:
          (define defed (get-definitions-text))
          (if (send defed has-focus?)
              defed
              (get-interactions-text)))
        
        (define frame this)
        
        (define props-default
          `((functions . item-callback)
            (shortcut . #f)
            (shortcut-prefix . #f)
            (help-string . "Help String")
            (output-to . selection) ; outputs the result in a new tab
            (persistent . #f)
            (active . #t)
            ))
        
        (define (prop-dict-ref props key)
          (dict-ref props key (dict-ref props-default key)))
        
        (define (new-script)
          (define name (get-text-from-user "Script name" "Enter the name of the script:"))
          (when name
            (define script-name  (string-append name ".rkt"))
            (define f-script     (build-path (script-dir) script-name))
            (define f-prop       (build-path (script-dir) (string-append script-name "d")))
            
            (with-output-to-file f-prop
              (λ _ (pretty-write (cons `(label . ,name) props-default))))
            (with-output-to-file f-script
              (λ _ 
                (displayln
                 (string-join '("#lang racket/base\n"
                                "; Sample identity function:"
                                ";; string? -> (or/c string? #f)")
                              "\n"))
                (for-each pretty-write 
                          '((provide item-callback)
                            (define (item-callback str)
                              str
                              )))
                (displayln "\n;; See the manual in the Script/Help menu for more information.")
                ))
            
            (reload-scripts-menu)
            
            (edit-script f-prop)
            (edit-script f-script)
            ))
        
        ;; file: path?
        (define (edit-script file)
          (when file
            ; For frame:text% :
            ;(send (get-the-text-editor) load-file file)
            ; For DrRacket:
            (send this open-in-new-tab file)))
        
        (define (open-script)
          (define file (get-file "Open a script" frame (script-dir) #f #f '() 
                                 '(("Racket" "*.rkt"))))
          (edit-script file))
        
        (define (open-script-properties)
          (define file (get-file "Open a script properties" frame (script-dir) #f #f '() 
                                 '(("Property file" "*.rktd"))))
          (edit-script file))
        
        ;; Ask the user for a script to import from the bundled script directory 
        ;; (or any other directory for that matter).
        ;; Useful when new scripts have been added due to an update.
        (define (import-bundled-script)
          (define src-file (get-file "Open a script" frame examples-path #f #f '() 
                                     '(("Racket" "*.rkt"))))
          (when src-file
            (define src-dir     (path-only src-file))
            (define filename    (path->string (file-name-from-path src-file)))
            (define filenamed   (string-append filename "d"))
            (define src-filed   (build-path src-dir filenamed))
            (define dest-file   (build-path (script-dir) filename))
            (define dest-filed  (build-path (script-dir) filenamed))
            
            (define overwrite? (or (not (file-exists? dest-file))
                                   (eq? 'ok
                                        (message-box 
                                         "Overwrite?" 
                                         (string-append
                                          "The script " filename 
                                          " already exists in your script directory.\n"
                                          "Do you want to overwrite it?")
                                         frame
                                         '(caution ok-cancel)))))
            (when overwrite?
              (if (file-exists? src-filed)
                  (begin (copy-file src-file  dest-file  #t)
                         (copy-file src-filed dest-filed #t))
                  (message-box "Not a script"
                               "This is not a script file (no associated .rktd file found)"
                               frame '(caution ok))))))

        ;; dict for persistent scripts:
        ;; the module is instaciated only once, and made available for future calls.
        (define namespace-dict (make-hash))
        
        (define (unload-persistent-scripts)
          (set! namespace-dict (make-hash)))
        
        ;; f: path?
        (define (run-script fun file output-to persistent?)
          ; For frame:text% :
          ;(define text (send frame get-editor))
          ; For DrRacket:
          (define text (get-the-text-editor))
          (define str (send text get-text 
                            (send text get-start-position) 
                            (send text get-end-position)))
          ; Create a namespace for the script:
          (define (make-script-namespace)
            (define ns (make-base-empty-namespace))
            (for ([mod '(racket/class racket/gui/base)])
              (namespace-attach-module (namespace-anchor->empty-namespace a)
                                       mod ns))
            ns)
          ; if the script is persistent, we try to load an existing namespace, or we create one.
          ; if not, we always create a new namespace.
          (define ns 
            (if persistent?
                (dict-ref! namespace-dict file make-script-namespace)
                (make-script-namespace)))

          (define file-str (path->string file))
          (define ed-file (send (get-definitions-text) get-filename))
          (define str-out
            (with-handlers ([exn:fail? (λ(e)(error-message-box 
                                             (path->string (file-name-from-path file))
                                             e)
                                         #f)])
              ; See HelpDesk for "Manipulating namespaces"
              (parameterize ([current-namespace ns])
                (let ([f (dynamic-require file fun)]
                      [kw-dict `((#:definitions   . ,(get-definitions-text))
                                 (#:interactions  . ,(get-interactions-text))
                                 (#:editor        . ,text)
                                 (#:file          . ,ed-file)
                                 (#:frame         . ,this))])
                  (let-values ([(_ kws) (procedure-keywords f)])
                    (let ([k-v (sort (map (λ(k)(assoc k kw-dict)) kws)
                                     keyword<? #:key car)])
                      (keyword-apply f (map car k-v) (map cdr k-v) str '())
                      ))))))
          (define (insert-to-text text)
            ; Inserts the text, possibly overwriting the selection:
            (send text begin-edit-sequence)
            (send text insert str-out)
            (send text end-edit-sequence))
          ; DrRacket specific:
          (when (or (string? str-out) (is-a? str-out snip%)) ; do not modify the file if no output
            (case output-to
              [(new-tab)
               (create-new-tab)
               (insert-to-text (get-the-text-editor))] ; get the newly created text
              [(selection)
               (insert-to-text text)]
              [(message-box)
               (message-box "Ouput" str-out this)]
              )))
        
        (define (open-help)
          (send-main-page #:sub "script-plugin/index.html"))
        
        (define (bug-report)
          (send-url "https://github.com/Metaxal/script-plugin/issues"))
        
        (define menu-bar (send this get-menu-bar))
        
        (define menu-reload-count 0)
        
        (define scripts-menu 
          (new menu% [parent menu-bar] [label "&Scripts"]))
        (define (reload-scripts-menu)
          (define secs (current-milliseconds))
          (set! menu-reload-count (add1 menu-reload-count))
          (log-script-plugin-info "Script menu rebuild #~a..." menu-reload-count)
          ;; remove all scripts items, after the persistent ones:
          (for ([item (list-tail (send scripts-menu get-items) 2)])
            (log-script-plugin-info "Deleting menu item ~a... " (send item get-label))
            (send item delete))
          ;; add script items:
          ; the menu-hash holds the submenus, to avoid creating them more than once
          (define menu-hash (make-hash))
          ;for all scripts in the script directory:
          (for ([f (directory-list (script-dir))])
            (let ([f-prop (build-path (script-dir) (string-append (path->string f) "d"))])
              ; catch problems and display them in a message-box
              (with-handlers ([exn:fail? (λ(e)(error-message-box 
                                               (path->string (file-name-from-path f-prop))
                                               e))])
                ; the script file must have an associated rktd file
                (when (and (member (filename-extension f) '(#"rkt"))
                           (file-exists? f-prop))
                  ; read from the property file
                  (with-input-from-file f-prop 
                    (λ _
                      ; for all dictionaries in the file:
                      (let loop ([props (read)]) 
                        (when (and (dict? props)      (prop-dict-ref  props 'active))
                          (let*([label                (dict-ref       props 'label (path->string f))]
                                [functions            (prop-dict-ref  props 'functions)]
                                [shortcut             (prop-dict-ref  props 'shortcut)]
                                [shortcut-prefix (or  (prop-dict-ref  props 'shortcut-prefix)
                                                      (get-default-shortcut-prefix))]
                                [help-string          (prop-dict-ref  props 'help-string)]
                                [output-to            (prop-dict-ref  props 'output-to)]
                                [persistent           (prop-dict-ref  props 'persistent)]
                                [parent-menu (if (list? functions)
                                                 (hash-ref! menu-hash label
                                                            ; create a sub-menu if necessary:
                                                            (λ _ 
                                                              (new menu% [parent scripts-menu]
                                                                   [label label])))
                                                 scripts-menu)]
                                [label-functions (if (list? functions)
                                                     functions
                                                     (list (list functions label)))]
                                )
                            ; for all functions in the dictionary:
                            (for ([fun   (map first  label-functions)]
                                  [label (map second label-functions)])
                              (if (eq? label 'separator)
                                  (new separator-menu-item% [parent parent-menu])
                                  ; create an item for this function:
                                  (new menu-item% [parent parent-menu] 
                                       [label            label]
                                       [shortcut         shortcut]
                                       [shortcut-prefix  shortcut-prefix]
                                       [help-string      help-string]
                                       [callback         (λ(it ev)
                                                           (run-script fun
                                                                       (build-path (script-dir) f)
                                                                       output-to
                                                                       persistent))]))))
                          ; next dict:
                          (loop (read))))))))))
          (log-script-plugin-info "Ok. Took ~ams" (- (current-milliseconds) secs)))
        
        (define manage-menu (new menu% [parent scripts-menu] [label "Manage scripts"]))
        (for ([(lbl cbk) (in-dict `(("New script..."              . ,new-script)
                                    ("Open script..."             . ,open-script)
                                    ("Open script properties..."  . ,open-script-properties)
                                    ("Import bundled script..."   . ,import-bundled-script)
                                    (separator                    . #f)
                                    ("Reload scripts menu"        . ,reload-scripts-menu)
                                    ("Unload persistent scripts"  . ,unload-persistent-scripts)
                                    (separator                    . #f)
                                    ("Help"                       . ,open-help)
                                    ("Feedback/Bug report..."     . ,bug-report)
                                    ))])
          (if (eq? lbl 'separator)
              (new separator-menu-item% [parent manage-menu])
              (new menu-item% [parent manage-menu] [label lbl]
                   [callback (λ _ (cbk))])))
        (new separator-menu-item% [parent scripts-menu])
 
        (reload-scripts-menu)
        ))

    (define (phase1) (void))
    (define (phase2) (void))
 
    (drracket:get/extend:extend-unit-frame script-menu-mixin)
    
    ))
