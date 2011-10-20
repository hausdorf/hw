#lang plai

(define-type FAE
  [num (n number?)]
  [add (lhs FAE?)
       (rhs FAE?)]
  [sub (lhs FAE?)
       (rhs FAE?)]
  [id (name symbol?)]
  [fun (param symbol?)
       (body FAE?)]
  [app (fun-expr FAE?)
       (arg-expr FAE?)]
  [if0 (test FAE?)
       (then FAE?)
       (else FAE?)]
  [neg (n FAE?)]
  [avg (n1 FAE?)
       (n2 FAE?)
       (n3 FAE?)])

(define-type FAE-Value
  [numV (n number?)]
  [closureV (param symbol?)
            (body FAE?)
            (ds DefrdSub?)])

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
  [appArgK (arg-expr FAE?)
           (ds DefrdSub?)
           (k FAE-Cont?)]
  [doAppK (fun-val FAE-Value?)
          (k FAE-Cont?)]
  [doIfK (then-expr FAE?)
         (else-expr FAE?)
         (ds DefrdSub?)
         (k FAE-Cont?)])

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
       [(fun) (fun (first (second sexp)) (parse (third sexp)))]
       [(if0) (if0 (parse (second sexp))
                   (parse (third sexp))
                   (parse (fourth sexp)))]
       [(neg) (neg (parse (second sexp)))]
       [(avg) (avg (parse (second sexp))
                   (parse (third sexp))
                   (parse (fourth sexp)))]
       [else (app (parse (first sexp)) (parse (second sexp)))])]))

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
    ;; ADDS NEG
    [neg (n) (- (num-n n))]
    [avg (n1 n2 n3) (/ (numV-n (interp (add n1 (add n2 n3)) ds k)) 3)]))

; PART 1: interp-expr
(define (interp-expr a-fae)
  (interp a-fae (mtSub) init-k))

;; continue : FAE-Cont FAE-Value -> FAE-Value
(define (continue k v)
  (type-case FAE-Cont k
    [mtK () v]
    [addSecondK (r ds k)
                (interp r ds (doAddK v k))]
    [doAddK (v1 k)
            (continue k (num+ v1 v))]
    [subSecondK (r ds k)
                (interp r ds (doSubK v k))]
    [doSubK (v1 k)
            (continue k (num- v1 v))]
    [appArgK (arg-expr ds k)
             (interp arg-expr ds (doAppK v k))]
    [doAppK (fun-val k)
            (interp (closureV-body fun-val)
                    (aSub (closureV-param fun-val)
                          v
                          (closureV-ds fun-val))
                    k)]
    [doIfK (then-expr else-expr ds k)
           (if (numzero? v)
               (interp then-expr ds k)
               (interp else-expr ds k))]))

;; num-op : (number number -> number) -> (FAE-Value FAE-Value -> FAE-Value)
(define (num-op op op-name)
  (lambda (x y)
    (numV (op (numV-n x) (numV-n y)))))

(define num+ (num-op + '+))
(define num- (num-op - '-))

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

(test (interp-expr (num 10))
      (numV 10))


;; NEW TESTS
(test (interp-expr (parse '{neg 2}))
        -2)

(test (interp-expr (parse '{avg 0 6 6}))
        4)