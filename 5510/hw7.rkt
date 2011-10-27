#lang plai

;; ---------------------
;; ALEX CLEMMER u0458675
;; CS 5510 Fall 2011
;; HOMEWORK 7
;; ---------------------

(define-type FAE
  [num (n number?)]
  [add (lhs FAE?)
       (rhs FAE?)]
  [sub (lhs FAE?)
       (rhs FAE?)]
  [id (name symbol?)]
  ;; --------- NEW CODE
  [fun (param (listof symbol?))
       (body FAE?)]
  ;; --------- END NEW CODE
  [app (fun-expr FAE?)
       (arg-expr (listof FAE?))]
  [if0 (test FAE?)
       (then FAE?)
       (else FAE?)]
  ;; --------- NEW CODE
  [neg (expr FAE?)]
  [avg (v1 FAE?)
       (v2 FAE?)
       (v3 FAE?)]
  [withcc (name id?)
          (arg FAE?)])
;; --------- END NEW CODE

(define-type FAE-Value
  [numV (n number?)]
  [closureV (param (listof symbol?))
            (body FAE?)
            (ds DefrdSub?)]
  ;; --------- NEW CODE
  [contV (k FAE-Cont?)])
;; --------- END NEW CODE

(define-type DefrdSub
  [mtSub]
  [aSub (name symbol?)
        (value FAE-Value?)
        (rest DefrdSub?)])

(define-type FAE-Cont
  [mtK]
  [addSecondK (r FAE?)
              (ds DefrdSub?)
              (k FAE-Cont?)]
  [doAddK (v1 FAE-Value?)
          (k FAE-Cont?)]
  [subSecondK (r FAE?)
              (ds DefrdSub?)
              (k FAE-Cont?)]
  [doSubK (v1 FAE-Value?)
          (k FAE-Cont?)]
  [appArgK (arg-expr (listof FAE?))
           (ds DefrdSub?)
           (k FAE-Cont?)]
  [doAppK (fun-val FAE-Value?)
          (k FAE-Cont?)]
  [doIfK (then-expr FAE?)
         (else-expr FAE?)
         (ds DefrdSub?)
         (k FAE-Cont?)]
  ;; --------- NEW CODE
  [doNeg (ds DefrdSub?)
         (k FAE-Cont?)])
;; --------- END NEW CODE

;; ----------------------------------------

;; parse : S-expr -> FAE
(define (parse sexp)
  (cond
    [(number? sexp) (num sexp)]
    [(symbol? sexp) (id sexp)]
    [(pair? sexp)
     (case (first sexp)
       [(+) (add (parse (second sexp)) (parse (third sexp)))]
       [(-) (sub (parse (second sexp)) (parse (third sexp)))]
       [(fun) (fun (second sexp) (parse (third sexp)))]
       [(if0) (if0 (parse (second sexp))
                   (parse (third sexp))
                   (parse (fourth sexp)))]
       ;; --------- NEW CODE
       [(neg) (neg (parse (second sexp)))]
       [(avg) (avg (parse (second sexp))
                   (parse (third sexp))
                   (parse (fourth sexp)))]
       [(withcc) (withcc (parse (second sexp))
                         (parse (third sexp)))]
       [else (app (parse (first sexp)) (map parse (rest sexp)))])]))
;; --------- END NEW CODE

(test (parse 3) (num 3))
(test (parse 'x) (id 'x))
(test (parse '{+ 1 2}) (add (num 1) (num 2)))
(test (parse '{- 1 2}) (sub (num 1) (num 2)))
(test (parse '{fun {x} x}) (fun 'x (id 'x)))
(test (parse '{1 2}) (app (num 1) (num 2)))
(test (parse '{if0 0 1 2}) (if0 (num 0) (num 1) (num 2)))

;; ----------------------------------------

;; interp : FAE DefrdSub FAE-Cont -> FAE-Value
(define (interp a-fae ds k)
  (type-case FAE a-fae
    [num (n) (continue k (numV n))]
    [add (l r) (interp l ds (addSecondK r ds k))]
    [sub (l r) (interp l ds (subSecondK r ds k))]
    [id (name) (continue k (lookup name ds))]
    [fun (param body-expr)
         (continue k (closureV param body-expr ds))]
    [app (fun-expr arg-expr)
         (interp fun-expr ds (appArgK arg-expr ds k))]
    [if0 (test-expr then-expr else-expr)
         (interp test-expr ds (doIfK then-expr else-expr ds k))]
    ;; --------- NEW CODE
    [neg (expr) (interp expr ds (doNeg ds k))]
    [avg (v1 v2 v3) (continue k 
                              (num/ (interp v1 ds (addSecondK v2 ds (addSecondK v3 ds k)))
                                    (numV 3)))]
    [withcc (name arg)
            (interp arg
                    (aSub (id-name name)
                          (contV k)
                          ds)
                    k)]))
;; --------- END NEW CODE

;; --------- NEW CODE
(define (interp-expr a-fae)
  (define result (interp a-fae (mtSub) init-k))
  (print result)
  (cond
    [(numV? result) (numV-n result)]
    [(FAE-Value? result) 'function]
    [else (error "BAD INPUT FOR interp-expr")]))
;; --------- END NEW CODE

(define (rec-aSub nl vl ds)
  (cond
    [(empty? nl) ds]
    [(cons? nl) (aSub (first nl)
                      (first vl)
                      (rec-aSub (rest nl)
                                (rest vl)
                                ds))]))

(define (interp-args args ds c)
  (cond
    [(equal? args '()) '()]
    [(empty? (rest args)) (list (interp (first args) ds c))]
    [(cons? (rest args)) (cons (interp (first args) ds c) (interp-args (rest args) ds c))]))

;; continue : FAE-Cont FAE-Value -> FAE-Value
(define (continue k v)
  (type-case FAE-Cont k
    [mtK () (if (list? v)
                (if (FAE? (first v))
                    (interp (first v) (mtSub) k)
                    (first v))
                (if (FAE? v)
                    (interp v (mtSub) k)
                    v))]
    [addSecondK (r ds k)
                (interp r ds (doAddK v k))]
    [doAddK (v1 k)
            (continue k (num+ v1 v))]
    [subSecondK (r ds k)
                (interp r ds (doSubK v k))]
    [doSubK (v1 k)
            (continue k (num- v1 v))]
    [appArgK (arg-expr ds k)
             (continue (doAppK v k) arg-expr)]
    [doAppK (fun-val k)
            (type-case FAE-Value fun-val
              [closureV (param body-expr ds)
                        (interp (closureV-body fun-val)
                                (rec-aSub (closureV-param fun-val)
                                          v
                                          (closureV-ds fun-val))
                                k)]
              [contV (k)
                     (continue k v)]
              [else fun-val])]
    [doIfK (then-expr else-expr ds k)
           (if (numzero? v)
               (interp then-expr ds k)
               (interp else-expr ds k))]
    ;; --------- NEW CODE
    [doNeg (ds k) (continue k (num* v (numV -1)))]))
;; --------- END NEW CODE

;; num-op : (number number -> number) -> (FAE-Value FAE-Value -> FAE-Value)
(define (num-op op op-name)
  (lambda (x y)
    (numV (op (numV-n x) (numV-n y)))))

(define num+ (num-op + '+))
(define num- (num-op - '-))
;; --------- NEW CODE
(define num* (num-op * '*))
(define num/ (num-op / '/))
;; --------- END NEW CODE

;; numzero? : FAE-Value -> boolean
(define (numzero? x)
  (zero? (numV-n x)))

(define (lookup name ds)
  (type-case DefrdSub ds
    [mtSub () (error 'lookup "free variable")]
    [aSub (sub-name num rest-ds)
          (if (symbol=? sub-name name)
              num
              (lookup name rest-ds))]))

(define init-k (mtK))

(test (interp (num 10)
              (mtSub)
              init-k)
      (numV 10))
(test (interp (add (num 10) (num 7))
              (mtSub)
              init-k)
      (numV 17))
(test (interp (sub (num 10) (num 7))
              (mtSub)
              init-k)
      (numV 3))
(test (interp (app (fun 'x (add (id 'x) (num 12)))
                   (add (num 1) (num 17)))
              (mtSub)
              init-k)
      (numV 30))
(test (interp (id 'x)
              (aSub 'x (numV 10) (mtSub))
              init-k)
      (numV 10))

(test (interp (app (fun 'x (add (id 'x) (num 12)))
                   (add (num 1) (num 17)))
              (mtSub)
              init-k)
      (numV 30))

(test (interp (app (fun 'x
                         (app (fun 'f
                                   (add (app (id 'f) (num 1))
                                        (app (fun 'x
                                                  (app (id 'f) (num 2)))
                                             (num 3))))
                              (fun 'y (add (id 'x) (id 'y)))))
                    (num 0))
               (mtSub)
               init-k)
      (numV 3))

(test (interp (if0 (num 0)
                   (num 1)
                   (num 2))
               (mtSub)
               init-k)
      (numV 1))
(test (interp (if0 (num 1)
                   (num 0)
                   (num 2))
               (mtSub)
               init-k)
      (numV 2))

(test (interp (parse 
               '{{fun {mkrec}
                      {{fun {fib}
                            ;; Call fib on 4:
                            {fib 4}}
                       ;; Create recursive fib:
                       {mkrec
                        {fun {fib}
                             ;; Fib:
                             {fun {n}
                                  {if0 n
                                       1
                                       {if0 {- n 1}
                                            1
                                            {+ {fib {- n 1}}
                                               {fib {- n 2}}}}}}}}}}
                 ;; mkrec:
                 {fun {body-proc}
                      {{fun {fX}
                            {fX fX}}
                       {fun {fX}
                            {body-proc {fun {x} {{fX fX} x}}}}}}})
              (mtSub)
              init-k)
      (numV 5))

(test/exn (interp (id 'x) (mtSub) init-k)
          "free variable")


;; --------- NEW CODE
; neg
(test (interp-expr (parse '{neg 2}))
        -2)
(test (interp-expr (parse '{neg {neg 2}}))
        2)
(test (interp-expr (parse '{neg {+ 2 2}}))
        -4)

; parse
(test (interp-expr (parse '{avg 0 6 6}))
        4)
(test (interp-expr (parse '{avg 6 6 6}))
        6)
(test (interp-expr (parse '{avg {+ 3 2} 4 6}))
        5)

; withcc
(test (interp-expr (parse '{withcc k 7}))
        7)
(test (interp-expr (parse '{withcc k k}))
        'function)
(test (interp-expr (parse '{withcc k {+ 1 {k 2}}})) 2)
(test (interp-expr (parse '{withcc k {neg {k 3}}}))
        3)
;(test (interp-expr (parse '{{fun {x y} {- y x}} 10 12}))
;        2)
;(test (interp-expr (parse '{fun {} 12}))
;      'function)
;(test (interp-expr (parse '{fun {x} {fun {} x}}))
;      'function)
;(test (interp-expr (parse '{{{fun {x} {fun {} x}} 13}}))
;      13)

(test (interp-expr (parse '{withcc esc {{fun {x y} x} 1 {esc 3}}}))
      3)
(test (interp-expr (parse '{{withcc esc {{fun {x y} {fun {z} {+ z y}}} 1 {withcc k {esc k}}}} 10}))
      20)
;; --------- END NEW CODE