#lang plai

;; --------------------------------------------------
;; DefrdSub

(define-type DefrdSub
  [mtSub]
  [aSub (name symbol?)
        (val number?)
        (rest DefrdSub?)])

;; Example DefrdSubs:
;;  (mtSub)
;;  (aSub 'x 5 (mtSub))
;;  (aSub 'x 6 (aSub 'x 5 (mtSub)))

;; lookup : sym DefrdSub -> num
(define (lookup name ds)
  (type-case DefrdSub ds
    [mtSub () (error 'lookup "free variable: ~e" name)]
    [aSub (bound-name val rest)
          (if (symbol=? name bound-name)
              val
              (lookup name rest))]))

(test/exn (lookup 'x (mtSub)) "free variable")
(test (lookup 'x (aSub 'x 5 (mtSub))) 5)
(test (lookup 'x (aSub 'x 5 (aSub 'y 10 (mtSub)))) 5)
(test (lookup 'y (aSub 'x 5 (aSub 'y 10 (mtSub)))) 10)
(test (lookup 'x (aSub 'x 5 (aSub 'x 10 (mtSub)))) 5)

;; --------------------------------------------------
;; FunDef and F1WAE

(define-type FunDef
  [fundef (fun-name symbol?)
          (arg-name symbol?)
          (body F1WAE?)])

(define-type F1WAE
  [num (n number?)]
  [add (lhs F1WAE?)
       (rhs F1WAE?)]
  [sub (lhs F1WAE?)
       (rhs F1WAE?)]
  [with (name symbol?)
    (named-expr F1WAE?)
    (body F1WAE?)]
  [id (name symbol?)]
  [app (fun-name symbol?)
       (arg F1WAE?)])

;; --------------------------------------------------
;; Parser

;; parse : s-expr -> F1WAE
(define (parse input)
  (cond
    ;; <number>
    [(number? input) (num input)]
    ;; '<id>
    [(symbol? input) (id input)]
    ;; '{+ <f1wae> <f1wae>}
    [(and (= 3 (length input))
          (eq? (first input) '+))
     (add (parse (second input))
          (parse (third input)))]
    ;; '{- <f1wae> <f1wae>}
    [(and (= 3 (length input))
          (eq? (first input) '-))
     (sub (parse (second input))
          (parse (third input)))]
    ;; '{with {<id> <f1wae>} <f1wae>}
    [(and (= 3 (length input))
          (eq? (first input) 'with))
     (with (first (second input))
       (parse (second (second input)))
       (parse (third input)))]     
    ;; '{<id> <f1wae>}
    [(and (= 2 (length input))
          (symbol? (first input)))
     (app (first input)
          (parse (second input)))]
    [else (error 'parse "bad syntax: ~a" input)]))

;; parse-defn : s-expr -> FunDef
(define (parse-defn input)
  ;; '{deffun {<id> <id>} <f1wae>}
  (fundef (first (second input))
    (second (second input))
    (parse (third input))))

(test (parse-defn '{deffun {x y} y})
      (fundef 'x 'y (id 'y)))

(test (parse '1) (num 1))
(test (parse '{+ 1 2}) (add (num 1) (num 2)))
(test (parse '{+ {- 5 2} {+ 2 1}}) (add (sub (num 5) (num 2))
                                        (add (num 2) (num 1))))
(test (parse 'x) (id 'x))
(test (parse '{with {x {+ 1 2}} {- x 8}})
      (with 'x (add (num 1) (num 2))
        (sub (id 'x) (num 8))))

;; --------------------------------------------------
;; Interpreter

;; interp : F1WAE list-of-FunDef DefrdSub -> num
(define (interp a-wae fundefs ds)
  (type-case F1WAE a-wae
    [num (n) n]
    [add (l r) (+ (interp l fundefs ds) (interp r fundefs ds))]
    [sub (l r) (- (interp l fundefs ds) (interp r fundefs ds))]
    [with (bound-id named-expr body-expr)
      (interp body-expr
              fundefs
              (aSub bound-id
                    (interp named-expr fundefs ds)
                    ds))]
    [id (name) (lookup name ds)]
    [app (fun-name arg) 
         (local [(define fun (lookup-fundef fun-name fundefs))
                 (define arg-val (interp arg fundefs ds))]
           (interp (fundef-body fun)
                   fundefs
                   (aSub (fundef-arg-name fun)
                         arg-val
                         (mtSub))))]))

;; lookup-fundef : symbol list-of-FunDef -> FunDef
(define (lookup-fundef name fundefs)
  (cond
    [(empty? fundefs) (error 'interp "cannot find function: ~e" name)]
    [(cons? fundefs)
     (if (symbol=? name (fundef-fun-name (first fundefs)))
         (first fundefs)
         (lookup-fundef name (rest fundefs)))]))

(test/exn (lookup-fundef 'f (list)) "cannot find")
(test (lookup-fundef 'f (list (parse-defn '{deffun {f x} x})))
      (parse-defn '{deffun {f x} x}))
(test (lookup-fundef 'f (list (parse-defn '{deffun {g y} y})
                              (parse-defn '{deffun {f x} x})))
      (parse-defn '{deffun {f x} x}))
                     
(test (interp (num 5) (list) (mtSub))
      5)
(test (interp (add (num 8) (num 9)) (list) (mtSub))
      17)
(test (interp (sub (num 9) (num 8)) (list) (mtSub))
      1)
(test (interp (with 'x (add (num 1) (num 17))
                (add (id 'x) (num 12)))
              (list)
              (mtSub))
      30)
(test (interp (id 'x) (list) (aSub 'x 5 (mtSub))) 5)
(test/exn (interp (id 'x) (list) (mtSub)) "free variable")

(test (interp (parse '{f {+ 5 5}})
              (list (parse-defn '{deffun {f x} {+ x x}}))
              (mtSub))
      20)

(test/exn (interp (with 'y (num 8)
                    (app 'f (num 10)))
                  (list (fundef 'f 'x (add (id 'x) (id 'y))))
                  (mtSub))
          "free variable")

;; --------------------------------------------------
;; Compiler

(define-type CFunDef
  [cfundef (fun-name symbol?)
           (body CF1WAE?)])

(define-type CF1WAE
  [cnum (n number?)]
  [cadd (lhs CF1WAE?)
       (rhs CF1WAE?)]
  [csub (lhs CF1WAE?)
       (rhs CF1WAE?)]
  [cwith (named-expr CF1WAE?)
         (body CF1WAE?)]
  [cat (pos number?)]
  [capp (fun-name symbol?)
        (arg CF1WAE?)])

(define-type CSub
  [mtCSub]
  [aCSub (name symbol?)
         (rest CSub?)])

;; locate : sym CSub -> num
(define (locate name ds)
  (type-case CSub ds
    [mtCSub () (error 'locate "free variable: ~e" name)]
    [aCSub (bound-name rest)
           (if (symbol=? name bound-name)
               0
               (add1 (locate name rest)))]))

(test/exn (locate 'x (mtCSub)) "free variable")
(test (locate 'x (aCSub 'x (mtCSub))) 0)
(test (locate 'x (aCSub 'x (aCSub 'y (mtCSub)))) 0)
(test (locate 'y (aCSub 'x (aCSub 'y (mtCSub)))) 1)
(test (locate 'x (aCSub 'x (aCSub 'x (mtCSub)))) 0)

;; compile : F1WAE CSub -> CF1WAE
(define (compile a-wae cs)
  (type-case F1WAE a-wae
    [num (n) (cnum n)]
    [add (l r) (cadd (compile l cs) (compile r cs))]
    [sub (l r) (csub (compile l cs) (compile r cs))]
    [with (bound-id named-expr body-expr)
      (cwith (compile named-expr cs)
             (compile body-expr
                      (aCSub bound-id cs)))]
    [id (name) (cat (locate name cs))]
    [app (fun-name arg) 
         (capp fun-name
               (compile arg cs))]))

(test (compile (num 10) (mtCSub)) (cnum 10))
(test (compile (add (num 4) (num 10)) (mtCSub)) (cadd (cnum 4) (cnum 10)))
(test (compile (sub (num 4) (num 10)) (mtCSub)) (csub (cnum 4) (cnum 10)))
(test (compile (with 'x (num 4) (id 'x)) (mtCSub)) (cwith (cnum 4) (cat 0)))
(test (compile (with 'y (num 8) (with 'x (num 4) (id 'y))) (mtCSub)) 
      (cwith (cnum 8) (cwith (cnum 4) (cat 1))))
(test (compile (id 'x) (aCSub 'x (mtCSub))) (cat 0))
(test/exn (compile (id 'y) (aCSub 'x (mtCSub))) "free variable")
(test (compile (app 'f (num 10)) (mtCSub)) (capp 'f (cnum 10)))

;; --------------------------------------------------
;; Interpreter of compiled expressions

;; cinterp : F1WAE list-of-CFunDef list-of-num -> num
(define (cinterp a-cwae cfundefs s)
  (type-case CF1WAE a-cwae
    [cnum (n) n]
    [cadd (l r) (+ (cinterp l cfundefs s) (cinterp r cfundefs s))]
    [csub (l r) (- (cinterp l cfundefs s) (cinterp r cfundefs s))]
    [cwith (named-expr body-expr)
           (cinterp body-expr
                    cfundefs
                    (cons (cinterp named-expr cfundefs s)
                          s))]
    [cat (pos) (list-ref s pos)]
    [capp (fun-name arg) 
          (local [(define fun (lookup-cfundef fun-name cfundefs))
                  (define arg-val (cinterp arg cfundefs s))]
           (cinterp (cfundef-body fun)
                    cfundefs
                    (cons arg-val empty)))]))

;; lookup-cfundef : symbol list-of-CFunDef -> CFunDef
(define (lookup-cfundef name cfundefs)
  (cond
    [(empty? cfundefs) (error 'cinterp "cannot find function: ~e" name)]
    [(cons? cfundefs)
     (if (symbol=? name (cfundef-fun-name (first cfundefs)))
         (first cfundefs)
         (lookup-cfundef name (rest cfundefs)))]))

(test/exn (lookup-cfundef 'f (list)) "cannot find")
(test (lookup-cfundef 'f (list (cfundef 'f (cat 0))))
      (cfundef 'f (cat 0)))
(test (lookup-cfundef 'f (list (cfundef 'g (cat 0))
                               (cfundef 'f (cat 0))))
      (cfundef 'f (cat 0)))
                     
(test (cinterp (cnum 5) (list) empty)
      5)
(test (cinterp (cadd (cnum 8) (cnum 9)) (list) empty)
      17)
(test (cinterp (csub (cnum 9) (cnum 8)) (list) empty)
      1)
(test (cinterp (cwith (cadd (cnum 1) (cnum 17))
                      (cadd (cat 0) (cnum 12)))
               (list)
              (mtCSub))
      30)
(test (cinterp (cat 0) (list) (list 5)) 5)

(test (cinterp (capp 'f (cadd (cnum 5) (cnum 5)))
              (list (cfundef 'f (cadd (cat 0) (cat 0))))
              empty)
      20)

;; --------------------------------------------------
;; Interpreter that uses the compiler

;; interp* : F1WAE list-of-FunDef -> num
(define (interp* a-wae fundefs)
  (cinterp (compile a-wae (mtCSub))
           (map (lambda (fd)
                  (cfundef (fundef-fun-name fd)
                           (compile (fundef-body fd)
                                    (aCSub (fundef-arg-name fd)
                                           (mtCSub)))))
                fundefs)
           empty))


(test (interp* (num 5) (list))
      5)
(test (interp* (add (num 8) (num 9)) (list))
      17)
(test (interp* (sub (num 9) (num 8)) (list))
      1)
(test (interp* (with 'x (add (num 1) (num 17))
                     (add (id 'x) (num 12)))
               (list))
      30)
(test/exn (interp* (id 'x) (list)) "free variable")

(test (interp* (parse '{f {+ 5 5}})
               (list (parse-defn '{deffun {f x} {+ x x}})))
      20)

(test/exn (interp* (with 'y (num 8)
                         (app 'f (num 10)))
                   (list (fundef 'f 'x (add (id 'x) (id 'y)))))
          "free variable")
