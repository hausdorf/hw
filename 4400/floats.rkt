#lang plai

(define-type FLOAT
  [float32 (s number?)
           (ex number?)
           (frac number?)])

;; str-to-fl : string -> FLOAT32
(define (str-to-fl f)
  (float32 (substring f 0 1)
           (substring f 2 9)
           (substring f 10 32)))

(test (str-to-fl "001") "00000000000000000000000000000000")

;; normalized? : FLOAT32 -> bool
(define (normalized? f)
  '())

(define (normalized-to-dec f)
  '())

;; denormalized? : FLOAT32 -> bool
(define (denormalized? f)
  '())

(define (denormalized-to-dec f)
  '())

;; special? : FLOAT32 -> bool
(define (special? f)
  '())

(define (special-to-dec f)
  '())

;; fl-to-dec : string -> number
(define (fl-to-dec f)
  (define fl (str-to-fl f))
  (cond
    [(normalized? fl)
     (normalized-to-dec fl)]
    [(denormalized? fl)
     (denormalized-to-dec fl)]
    [(special? fl)
     (special-to-dec fl)]))