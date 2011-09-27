#lang plai

;; ALEX CLEMMER
;; u0458675
;; CS 5510 -- Fall 2011
;; Homework 3

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
       (arg F1WAE?)]
  ;; ---------------------
  ;; NEW CODE
  ;; ++ Definition of if0
  ;; ---------------------
  [if0 (condi F1WAE?)
       (if-true F1WAE?)
       (if-false F1WAE?)])

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
    ;; '{if0 <F1WAE> <F1WAE> <F1WAE>}
    ;; ------------------------------
    ;; NEW CODE
    ;; ++ Parsing if0
    ;; ------------------------------
    [(and (= 4 (length input))
          (symbol? (first input)))
     (if0 (parse (second input))
          (parse (third input))
          (parse (fourth input)))]
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
                         (mtSub))))]
    ;; ------------------
    ;; NEW CODE
    ;; ++ Interpreting if0
    ;; ------------------
    [if0 (condi if-true if-false)
         (if (= 0 (interp condi fundefs ds))
             (interp if-true fundefs ds)
             (interp if-false fundefs ds))]))


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

;; ---------------
;; REMOVED
;; Useless; assignment dictates we destroy this
;; ---------------
;;(define-type CFunDef
;;  [cfundef (fun-name symbol?)
;;           (body CF1WAE?)])

(define-type CF1WAE
  [cnum (n number?)]
  [cadd (lhs CF1WAE?)
       (rhs CF1WAE?)]
  [csub (lhs CF1WAE?)
       (rhs CF1WAE?)]
  [cwith (named-expr CF1WAE?)
         (body CF1WAE?)]
  [cat (pos number?)]
  ;; ---------------
  ;; CHANGED CODE
  ;; ++ Uses function index rather than function name
  ;; ---------------
  [capp (fun-index number?)
        (arg CF1WAE?)]
  ;; ---------------
  ;; NEW CODE
  ;; ++ Compiled if0
  ;; ---------------
  [cif0 (condi CF1WAE?)
        (if-true CF1WAE?)
        (if-false CF1WAE?)])

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
(define (compile a-wae cs funcs)
  (type-case F1WAE a-wae
    [num (n) (cnum n)]
    [add (l r) (cadd (compile l cs funcs) (compile r cs funcs))]
    [sub (l r) (csub (compile l cs funcs) (compile r cs funcs))]
    [with (bound-id named-expr body-expr)
      (cwith (compile named-expr cs funcs)
             (compile body-expr
                      (aCSub bound-id cs)
                      funcs))]
    [id (name) (cat (locate name cs))]
    ;; -----------------
    ;; CHANGED CODE
    ;; ++ Change fun name to index
    ;; -----------------
    [app (fun-name arg) 
         (capp (length funcs)
               (compile arg cs funcs))]
    ;; -----------------
    ;; NEW CODE
    ;; ++ Defs for compiling F1WAEs
    ;; -----------------
    [if0 (condi if-true if-false)
         (cif0 (compile condi cs funcs)
               (compile if-true cs funcs)
               (compile if-false cs funcs))]))

(test (compile (num 10) (mtCSub) (list)) (cnum 10))
(test (compile (add (num 4) (num 10)) (mtCSub) (list)) (cadd (cnum 4) (cnum 10)))
(test (compile (sub (num 4) (num 10)) (mtCSub) (list)) (csub (cnum 4) (cnum 10)))
(test (compile (with 'x (num 4) (id 'x)) (mtCSub) (list)) (cwith (cnum 4) (cat 0)))
(test (compile (with 'y (num 8) (with 'x (num 4) (id 'y))) (mtCSub) (list)) 
      (cwith (cnum 8) (cwith (cnum 4) (cat 1))))
(test (compile (id 'x) (aCSub 'x (mtCSub)) (list)) (cat 0))
(test/exn (compile (id 'y) (aCSub 'x (mtCSub)) (list)) "free variable")
(test (compile (app 'f (num 10)) (mtCSub) (list)) (capp 0 (cnum 10)))

;; --------------------------------------------------
;; Interpreter of compiled expressions

;; cinterp : F1WAE list-of-CFunDef list-of-num -> num
(define (cinterp a-cwae funlist s)
  (type-case CF1WAE a-cwae
    [cnum (n) n]
    [cadd (l r) (+ (cinterp l funlist s) (cinterp r funlist s))]
    [csub (l r) (- (cinterp l funlist s) (cinterp r funlist s))]
    [cwith (named-expr body-expr)
           (cinterp body-expr
                    funlist
                    (cons (cinterp named-expr funlist s)
                          s))]
    [cat (pos) (list-ref s pos)]
    ;; ---------------------
    ;; CODE CHANGE
    ;; Changes names to offsets
    ;; ---------------------
    [capp (fun-index arg) 
          (local [(define fun (lookup-cfundef fun-index funlist))
                  (define arg-val (cinterp arg funlist s))]
           (cinterp fun
                    funlist
                    (cons arg-val empty)))]
    ;; ---------------------
    ;; NEW CODE
    ;; ++ Defs for interpreting compiled code
    ;; ---------------------
    [cif0 (condi if-true if-false)
          (if (= 0 (cinterp condi funlist s))
              (cinterp if-true funlist s)
              (cinterp if-false funlist s))]))

;; lookup-cfundef : symbol list-of-CFunDef -> CFunDef
;; ------------
;; OVERHAULED CODE
;; ++ Changed, doesn't make senes to look for names
;; ------------
(define (lookup-cfundef index cfundefs)
  (define (lookup-index index cfundefs curr)
    (cond
      [(empty? cfundefs) (error 'cinterp "cannot find function: ~e" index)]
      [(cons? cfundefs)
       (if (= curr index)
           (first cfundefs)
           (lookup-index index (rest cfundefs) (+ curr 1)))]))
  (lookup-index index cfundefs 0))

(test/exn (lookup-cfundef 'f (list)) "cannot find")
(test (lookup-cfundef 0 (list '('f (cat 0))))
      '('f (cat 0)))
(test (lookup-cfundef 1 (list '('g (cat 0))
                               '('f (cat 0))))
      '('f (cat 0)))
                     
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

(test (cinterp (capp 0 (cadd (cnum 5) (cnum 5)))
              (list (cadd (cat 0) (cat 0)))
              empty)
      20)

;; --------------------------------------------------
;; Interpreter that uses the compiler

;; interp* : F1WAE list-of-FunDef -> num
;; -------------
;; OVERHAULED CODE
;; Changed this to accomodate no use of the cfundefs
;; -------------
(define (interp* a-wae funs)
  (cinterp (compile a-wae (mtCSub) (list))
           (map (lambda (fd)
                  (compile (fundef-body fd)
                           (aCSub (fundef-arg-name fd) (mtCSub))
                           funs))
                funs)
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



;; ---------------
;; NEW CODE
;; ++ Testing for parse/interpret of if0
;; ---------------
(test (interp (parse '{if0 0 1 2})
              (list)
              (mtSub))
      1)
(test (interp (parse '{if0 1 1 2})
              (list)
              (mtSub))
      2)
(test (interp (parse '{if0 {f 5} 1 2})
              (list (parse-defn '{deffun {f x} {- x 5}}))
              (mtSub))
      1)
(test (interp (parse '{if0 0 {f 3} 2})
              (list (parse-defn '{deffun {f x} {- x 5}}))
              (mtSub))
      -2)
;; NOTE: unbound variable x should never get caught!
(test (interp (parse '{if0 1 {f x} 2})
              (list (parse-defn '{deffun {f x} {- x 5}}))
              (mtSub))
      2)
(test (interp (parse '{if0 0 1 {f 3}})
              (list (parse-defn '{deffun {f x} {- x 5}}))
              (mtSub))
      1)
(test (interp (parse '{if0 1 1 {f 2}})
              (list (parse-defn '{deffun {f x} {- x 5}}))
              (mtSub))
      -3)
;; NOTE: unbound variable x should never get caught!
(test (interp (parse '{if0 0 1 {f x}})
              (list (parse-defn '{deffun {f x} {- x 5}}))
              (mtSub))
      1)
;; ---------------------------
;; Testing compiling and interpreting of if0
;; ---------------------------
(test (interp* (parse '{if0 {f 5} 1 2})
               (list (parse-defn '{deffun {f x} {- x 5}})))
      1)
(test (interp* (parse '{if0 0 1 2})
              (list))
      1)
(test (interp* (parse '{if0 1 1 2})
              (list))
      2)
(test (interp* (parse '{if0 {f 5} 1 2})
              (list (parse-defn '{deffun {f x} {- x 5}})))
      1)
(test (interp* (parse '{if0 0 {f 3} 2})
              (list (parse-defn '{deffun {f x} {- x 5}})))
      -2)
(test (interp* (parse '{if0 0 1 {f 3}})
              (list (parse-defn '{deffun {f x} {- x 5}})))
      1)
(test (interp* (parse '{if0 1 1 {f 2}})
              (list (parse-defn '{deffun {f x} {- x 5}})))
      -3)






