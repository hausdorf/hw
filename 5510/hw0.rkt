#lang plai

; ALEX CLEMMER
; u0458675


; Part 1: Implement 42nd-power
; 42-power :: num -> num
(define (42nd-power num)
  (expt num 42))
(test (42nd-power 0) 0)
(test (42nd-power 1) 1)
(test (42nd-power 2) 4398046511104)
(test (42nd-power -1) 1)
(test (42nd-power -2) 4398046511104)
(test (42nd-power 1.2) 2116.471057875481)

; Part 2: Implement string+
; string+ :: string or number -> string or number -> string
(define (string+ ar1 ar2)
  (define res1 (if (number? ar1) (number->string ar1) ar1))
  (define res2 (if (number? ar2) (number->string ar2) ar2))
  (string-append res1 res2))
(test (string+ 3 3) "33")
(test (string+ 10 "cow") "10cow")
(test (string+ "country" 14) "country14")
(test (string+ "72" "64") "7264")
(test (string+ "" "") "")
(test (string+ "" 3) "3")
(test (string+ "stuff" -3) "stuff-3")
(test (string+ "empty" 2.65) "empty2.65")

; Part 3: Implement energy-usage
; bulb :: positive number -> symbol -> Light
; candle :: positive number -> Light
(define-type Light
  [bulb (watts number?)
        (technology symbol?)]
  [candle (inches number?)])

; energy-usage :: Light -> Light
(define (energy-usage light)
  (define (kw-per-day watts)
    (/ (* 24 watts) 1000))
  (type-case Light light
    [bulb (w t) (kw-per-day w)]
    [candle (n) 0.0]))
(test (energy-usage (candle 100.0)) 0.0)
(test (energy-usage (candle 0.0)) 0.0)
(test (energy-usage (bulb 100.0 'halogen)) 2.4)
(test (energy-usage (bulb 0.0 'incandescent)) 0.0)


; Part 4: Implement use-for-one-hour
; use-for-one-hour :: Light -> Light
(define (use-for-one-hour light)
  (define (burn-candle i)
    (define pre (- i 1))
    (if (< pre 0.0) 0.0 pre))
  (type-case Light light
    [bulb (w t) light]
    [candle (i) (candle (burn-candle i))]))
(test (use-for-one-hour (bulb 100.0 'halogen)) (bulb 100.0 'halogen))
(test (use-for-one-hour (bulb 0.0 'incandescent)) (bulb 0.0 'incandescent))
(test (use-for-one-hour (candle 10.0)) (candle 9.0))
(test (use-for-one-hour (candle 129.23092)) (candle 128.23092))
(test (use-for-one-hour (candle 0.0)) (candle 0.0))