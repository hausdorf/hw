#lang plai

(require xml
         net/url
         mzlib/thread
         mzlib/etc)

;; An args is
;;  (listof (cons symbol string))

;; dispatch-table : (listof (cons string ((listof string) args -> )))
(define dispatch-table null)

;; add-handler : string ((listof string) args -> ) -> void
;;  Adds a handler to the dispatch table. The handler
;;  is called for a request that matches the given name.
(define (add-handler name handler)
  (set! dispatch-table (cons (cons name handler)
                             dispatch-table)))

;; serve:  ->
;;  Runs a web server to handle GET requests through
;;  dispatch-table
(define (serve [port-number 8080])
  ;; The `run-server' function is about 55 lines in
  ;;   plt/collects/mzlib/thread.ss
  ;; It starts a TCP listener, farms each accepted
  ;; connection to a new thread, and terminates the
  ;; thread if it runs too long.
  (run-server
   ;; Port number:
   port-number
   ;; Handler:
   (lambda (in out)
     (let ([m (regexp-match #rx"^GET (.+) HTTP/[0-9]+\\.[0-9]+\r"
                            (read-line in))])         
       (when m
         ;; Discard rest of request header (up to blank line):
         (regexp-match #rx#"(?-s:^\r$)" in)
         ;; Dispatch
         (return-page (dispatch (cadr m)) in out))))
   ;; Timeout in msec:
   60000))

;; dispatch : string -> 
;;  Handles the given path, sending a reply back through
;;  the current output port, then jumping to (current-done-k)
(define (dispatch path)
  (let* ([url (string->url path)]
         [base (map path/param-path (url-path url))]
         [h (assoc (car base) dispatch-table)])
    (if h
        ((cdr h) base (url-query url))
        `(html (head (title "Error"))
               (body
                (font ((color "red"))
                      "Unknown page: " ,path))))))

;; return-page : xexpr -> 
;;  Doesn't return; it prints the given page to the current out
;;  port, then terminates the thread
(define (return-page xexpr in out)
  ;; Send response
  (display "HTTP/1.0 200 Okay\r\n" out)
  (display "Server: k\r\nContent-Type: text/html\r\n\r\n" out)
  (display (xexpr->string xexpr) out)
  (newline out)
  ;; Close (and flush) ports
  (close-input-port in)
  (close-output-port out))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Running-total servlet using state

(define total 0)

;; a-handler : string args ->
(define (a-handler base args)
  `(html 
    (head (title "Running total"))
    (body
     (p "Current value: " ,(number->string total))
     (p (a ((href "/a2")) "+2"))
     (p (a ((href "/a3")) "+3")))))

;; a2-handler : string args ->
(define (a2-handler base args)
  (set! total (+ total 2))
  (a-handler base args))

;; a3-handler : string args ->
(define (a3-handler base args)
  (set! total (+ total 3))
  (a-handler base args))

(add-handler "a" a-handler)
(add-handler "a2" a2-handler)
(add-handler "a3" a3-handler)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Clone-friendly running-total servlet

;; b-handler : string args ->
(define (b-handler base args)
  (do-b 0))

(define (do-b total)
  `(html 
    (head (title "Running total"))
    (body
     (p "Current value: " ,(number->string total))
     (p (a ((href ,(format "/b2?val=~a" total))) "+2"))
     (p (a ((href ,(format "/b3?val=~a" total))) "+3")))))

;; b2-handler : string args ->
(define (b2-handler base args)
  (do-b (+ 2 (string->number (cdr (assoc 'val args))))))

;; b3-handler : string args ->
(define (b3-handler base args)
  (do-b (+ 3 (string->number (cdr (assoc 'val args))))))

(add-handler "b" b-handler)
(add-handler "b2" b2-handler)
(add-handler "b3" b3-handler)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  web-read/k

(define table (make-hash))

(define (remember v)
  (let ([key (symbol->string (gensym))])
    (hash-set! table key v)
    key))

(define (lookup key)
  (hash-ref table key))


(define (web-read/k prompt cont)
  (let ([key (remember cont)])
    `(html 
      (head (title "Web Read"))
      (body ,prompt
            (form ([action "/resume-k"] [method "get"])
                  (input ([type "text"] [name "value"]
                                        [value ""]))
                  (input ([type "submit"] [name "enter"] 
                                          [value "Enter"]))
                  (input ([type "hidden"] [name "key"]
                                          [value ,key])))))))

(define (resume-k-handler base args)
  ((lookup (cdr (assoc 'key args)))
   (read (open-input-string (cdr (assoc 'value args))))))

(add-handler "resume-k" resume-k-handler)

(define (web-pause/k prompt cont)
  (let ([key (remember cont)])
    `(html 
      (head (title "Web Pause"))
      (body ,prompt
            (p (a ((href ,(format "/p-resume-k?key=~a" key)))
                  "continue"))))))

(define (p-resume-k-handler base args)
  ((lookup (cdr (assoc 'key args)))))

(add-handler "p-resume-k" p-resume-k-handler)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Servlet that uses web-read/k

(define (g-handler base args)
  (do-g 0))

(define (do-g total)
  (web-read/k (format "Total is ~a" total)
              (lambda (val)
                (do-g (+ val total)))))

(add-handler "g" g-handler)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; More servlets

(define (h-handler base args)
  (do-h identity))

(define (do-h cont)
  (web-read/k "First number"
              (lambda (v1)
                (web-read/k "Second number"
                            (lambda (v2)
                              (cont (number->string (+ v1 v2))))))))

(add-handler "h" h-handler)


(define (i-handler base args)
  (do-i identity))

(define (do-i cont)
  (do-h (lambda (h-result)
          (web-pause/k h-result
                       (lambda ()
                         (do-h cont))))))

(add-handler "i" i-handler)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; To start the server (call doesn't return):
; (serve)
