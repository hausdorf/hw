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
  [if0 (test-expr FAE?)
       (then-expr FAE?)
       (else-expr FAE?)])

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

;; ----------------------------------------

(define mk-rec-fun
    '{fun {body-proc}
          {with {fX {fun {fX}
                         {with {f {fun {x}
                                       {{fX fX} x}}}
                               {body-proc f}}}}
                {fX fX}}})

;; parse : S-expr -> FAE
(define (parse sexp)
  (cond
    [(number? sexp) (num sexp)]
    [(symbol? sexp) (id sexp)]
    [(cons? sexp)
     (case (first sexp)
       [(+) (add (parse (second sexp)) (parse (third sexp)))]
       [(-) (sub (parse (second sexp)) (parse (third sexp)))]
       [(with) (app (fun (first (second sexp)) (parse (third sexp)))
                    (parse (second (second sexp))))]
       [(fun) (fun (first (second sexp)) (parse (third sexp)))]
       [(rec) (define comp (parse mk-rec-fun))
              (app (fun (first (second sexp)) (parse (third sexp)))
                   (app comp (parse (second (second sexp)))))]
       [(if0) (if0 (parse (second sexp))
                   (parse (third sexp))
                   (parse (fourth sexp)))]
       [else (app (parse (first sexp)) (parse (second sexp)))])]))

(test (parse 3) (num 3))
(test (parse 'x) (id 'x))
(test (parse '{+ 1 2}) (add (num 1) (num 2)))
(test (parse '{- 1 2}) (sub (num 1) (num 2)))
(test (parse '{fun {x} x}) (fun 'x (id 'x)))
(test (parse '{with {x 1} x}) (app (fun 'x (id 'x)) (num 1)))
;; +++++++++++++
;; TODO: PUT MORE TESTS OF WITH HERE!
;; +++++++++++++
(test (interp (parse '{rec {f {fun {n}
                                     {if0 n
                                          0
                                          {- {f {- n 1}} 1}}}}
                          {f 10}})
                 (mtSub))
          (numV -10))
(test (parse '{if0 x y z}) (if0 (id 'x) (id 'y) (id 'z)))
(test (parse '{1 2}) (app (num 1) (num 2)))

;; ----------------------------------------

;; interp : FAE DefrdSub -> FAE-Value
(define (interp a-fae ds)
  (type-case FAE a-fae
    [num (n) (numV n)]
    [add (l r) (num+ (interp l ds) (interp r ds))]
    [sub (l r) (num- (interp l ds) (interp r ds))]
    [id (name) (lookup name ds)]
    [fun (param body-expr)
         (closureV param body-expr ds)]
    [app (fun-expr arg-expr)
         (local [(define fun-val
                   (interp fun-expr ds))
                 (define arg-val
                   (interp arg-expr ds))]
           (interp (closureV-body fun-val)
                   (aSub (closureV-param fun-val)
                         arg-val
                         (closureV-ds fun-val))))]
    [if0 (test then else)
         (if (num-zero? (interp test ds))
             (interp then ds)
             (interp else ds))]))

;; num-op : (number number -> number) -> (FAE-Value FAE-Value -> FAE-Value)
(define (num-op op op-name x y)
  (numV (op (numV-n x) (numV-n y))))

(define (num+ x y) (num-op + '+ x y))
(define (num- x y) (num-op - '- x y))

(define (num-zero? n)
  (zero? (numV-n n)))

(define (lookup name ds)
  (type-case DefrdSub ds
    [mtSub () (error 'lookup "free variable")]
    [aSub (sub-name num rest-ds)
          (if (symbol=? sub-name name)
              num
              (lookup name rest-ds))]))


(test (interp (parse 10)
              (mtSub))
      (numV 10))
(test (interp (parse '{+ 10 17})
              (mtSub))
      (numV 27))
(test (interp (parse '{- 10 7})
              (mtSub))
      (numV 3))
(test (interp (parse '{{fun {x} {+ x 12}}
                       {+ 1 17}})
              (mtSub))
      (numV 30))
(test (interp (parse 'x)
              (aSub 'x (numV 10) (mtSub)))
      (numV 10))

(test (interp (parse '{{fun {x}
                            {{fun {f}
                                  {+ {f 1}
                                     {{fun {x}
                                           {f 2}}
                                      3}}}
                             {fun {y} {+ x y}}}}
                       0})
              (mtSub))
      (numV 3))

(test (interp (parse '{if0 0 1 2})
              (mtSub))
      (numV 1))
(test (interp (parse '{if0 7 1 2})
              (mtSub))
      (numV 2))

(test/exn (interp (parse 'x) (mtSub))
          "free variable")
