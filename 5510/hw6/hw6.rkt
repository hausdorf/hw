#lang plai

;; Alex Clemmer u0458675
;; Assignment 6
(require "server.rkt")


;; PART 1 -- BIG HELLO
(define (j-handler base args)
  `(font ((size "+2")) "Hello"))

(add-handler "j" j-handler)


;; PART 2 -- MAD LIBS 1

;; NOTE: The do-m from part2; replaced by (do-3-part-madlib) for part 3
;; Provided here simply for you to look at.
(define (do-m cont)
  (define template-string "The ~a ~a ~a added some rockstar ninja SEO optimized AJAX to its 5510 webpage.")
  (web-read/k "Give me a noun!"
              (lambda (v1)
                (web-read/k "Give me an adjective!"
                            (lambda (v2)
                              (web-read/k "Give me an adverb!"
                                          (lambda (v3)
                                            (cont (format template-string v2 v1 v3)))))))))

;; Handles /m page.
(define (m-handler base args)
  (define template-string "The ~a added some ~a rockstar ninja SEO optimized AJAX to its 5510 webpage ~a.")
  ;(do-3-part-madlib identity template-string '(Noun Adjective Adverb))) ; Implementation for part 3
  (do-madlib identity template-string '(Noun Adjective Adverb) '()))

(add-handler "m" m-handler)


;; PART 3 -- MAD LIBS 2

;; NOTE: The "shared" implementation that handles both m and n servlets for part 3. Replaced with
;; (do-madlib) for part 4!
(define (do-3-part-madlib cont template-string pos-list)
  (web-read/k (format "~a! Go!" (first pos-list))
              (lambda (v1)
                (web-read/k (format "~a! You can do it!" (second pos-list))
                            (lambda (v2)
                              (web-read/k (format "~a! Just this last one!" (third pos-list))
                                          (lambda (v3)
                                            (cont (format template-string v1 v2 v3)))))))))

;; Handles /n page.
(define (n-handler base args)
  (define template-string (string-append "Customers think that your ~a AJAX skills and penchant for ~a "
                                         "completing your work are ~a."))
  ;(do-3-part-madlib identity template-string '(Adjective Adverb Adjective))) ; Implementation for part 3
  (do-madlib identity template-string '(Adjective Adverb Adjective) '()))

(add-handler "n" n-handler)


;; PART 4 -- MAD LIBS 3

;; NOTE: This is the "final" generalized version of the madlibs function. This is the one that is currently
;; implemented.
(define (do-madlib cont template-string pos-list res-list)
  (print res-list)
  (cond
    [(cons? pos-list) (web-read/k (format "~a! Go!" (first pos-list))
                                  (lambda (v1)
                                    (do-madlib cont
                                               template-string
                                               (rest pos-list)
                                               (append res-list (list v1)))))]
    [(empty? pos-list) (cont (apply format template-string res-list))]))

;; Handles /p page.
(define (p-handler base args)
  (define template-string (string-append "The ~a Flash animation of the ~a frontpage of the 5510"
                                         "assignment caused users to ~a their ~a."))
  (do-madlib identity template-string '(Adjective Adjective Verb Noun) '()))

(add-handler "p" p-handler)

;; ;;;;;;;;;;;;;
;; (serve) call must be at the bottom!
(serve 8001)