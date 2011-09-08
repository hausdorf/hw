#lang plai

(define-type FunDef
  [fundef (fun-name symbol?)
    ;(arg-name symbol?)
    (arg-name (listof symbol?))
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

;; parse : s-expr -> F1WAE
;;
;; Parses some s-expression; yields an F1WAE
(define (parse input)
  (cond
    ;; NUMBER
    ;; <number>
    [(number? input) (num input)]
    ;; IDENTIFIER
    ;; '<id>
    [(symbol? input) (id input)]
    ;; ADDITION
    ;; '{+ <f1wae> <f1wae>}
    [(and (= 3 (length input))
          (eq? (first input) '+))
     (add (parse (second input))
          (parse (third input)))]
    ;; SUBTRACTION
    ;; '{- <f1wae> <f1wae>}
    [(and (= 3 (length input))
          (eq? (first input) '-))
     (sub (parse (second input))
          (parse (third input)))]
    ;; VARIABLE INITIALIZATION
    ;; '{with {<id> <f1wae>} <f1wae>}
    [(and (= 3 (length input))
          (eq? (first input) 'with))
     (with (first (second input))
       (parse (second (second input)))
       (parse (third input)))]     
    ;; FUNCTION CALL
    ;; '{<id> <f1wae>}
    [(and (= 2 (length input))
          (symbol? (first input)))
     (app (first input)
          (parse (second input)))]
    ;; FUNCTION CALL
    ;; '{<id>}
    [(and (= 1 (length input))
          (symbol? (first input)))
     (app (first input))]
    [else (error 'parse "bad syntax: ~a" input)]))

;; parse-defn : s-expr -> FunDef
;;
;; Parses an s-expression, yields function definition
(define (parse-defn input)
  ;; '{deffun {<id> <id>} <f1wae>}
  (cond
    [(= 1 (length (second input)))
     (fundef (second input)
             '()
             (parse (third input)))]
    [else (fundef (first (second input))
                  (rest (second input))
                  (parse (third input)))]))
  ;;(fundef (first (second input))
    ;;(second (second input))
    ;;(parse (third input))))

(test (parse-defn '{deffun {x y} y})
      (fundef 'x '(y) (id 'y)))

(test (parse '1) (num 1))
(test (parse '{+ 1 2}) (add (num 1) (num 2)))
(test (parse '{+ {- 5 2} {+ 2 1}}) (add (sub (num 5) (num 2))
                                        (add (num 2) (num 1))))
(test (parse 'x) (id 'x))
(test (parse '{with {x {+ 1 2}} {- x 8}})
      (with 'x (add (num 1) (num 2))
        (sub (id 'x) (num 8))))

;; interp : F1WAE list-of-FunDef -> num
;;
;; Takes a function definition and the list of all function definitions
;; and returns the evaluated expression
(define (interp a-wae fundefs)
  (type-case F1WAE a-wae
    [num (n) n]
    [add (l r) (+ (interp l fundefs) (interp r fundefs))]
    [sub (l r) (- (interp l fundefs) (interp r fundefs))]
    [with (bound-id named-expr body-expr)
      (interp (subst body-expr
                     bound-id
                     (interp named-expr fundefs))
              fundefs)]
    [id (name) (error 'interp "free variable")]
    [app (fun-name arg) 
         (local [(define fun (lookup-fundef fun-name fundefs))
                 (define arg-val (interp arg fundefs))]
           (interp (subst (fundef-body fun)
                          (fundef-arg-name fun)
                          arg-val)
                   fundefs))]))

;; lookup-fundef : symbol list-of-FunDef -> FunDef
;;
;; Looks up a function definition in a list of function definitions
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

;; subst : F1WAE symbol number -> F1WAE
;;
;; Substitutes variables with numbers
(define (subst a-wae sub-id val)
  (type-case F1WAE a-wae
    [num (n) a-wae]
    [add (l r) (add (subst l sub-id val)
                    (subst r sub-id val))]
    [sub (l r) (sub (subst l sub-id val)
                    (subst r sub-id val))]
    [with (bound-id named-expr body-expr)
      (with bound-id 
        (subst named-expr sub-id val)
        (if (symbol=? bound-id sub-id)
            body-expr
            (subst body-expr sub-id val)))]
    [id (name) (if (symbol=? name sub-id)
                   (num val)
                   a-wae)]
    [app (fun-name arg)
         (app fun-name (subst arg sub-id val))]))

(test (subst (parse '{+ 1 {f x}}) 'x 19)
      (parse '{+ 1 {f 19}}))
(test (subst (add (num 1) (id 'x)) 'x 10)
      (add (num 1) (num 10)))
(test (subst (id 'x) 'x 10)
      (num 10))
(test (subst (id 'y) 'x 10)
      (id 'y))
(test (subst (sub (id 'x) (num 1)) 'y 10)
      (sub (id 'x) (num 1)))

(test (subst (with 'y (num 17) (id 'x)) 'x 10)
      (with 'y (num 17) (num 10)))
(test (subst (with 'y (id 'x) (id 'y)) 'x 10)
      (with 'y (num 10) (id 'y)))
(test (subst (with 'x (id 'y) (id 'x)) 'x 10)
      (with 'x (id 'y) (id 'x)))
(test (subst (parse '{with {x y} x}) 'x 10)
      (parse '{with {x y} x}))

(test (interp (num 5) (list))
      5)
(test (interp (add (num 8) (num 9)) (list))
      17)
(test (interp (sub (num 9) (num 8)) (list))
      1)
(test (interp (with 'x (add (num 1) (num 17))
                (add (id 'x) (num 12)))
              (list))
      30)
(test/exn (interp (id 'x) (list)) "free variable")
(test (interp (parse '{f {+ 5 5}})
              (list (parse-defn '{deffun {f x} {+ x x}})))
      20)

;; Step through this example:
"Tracing:"
(require racket/trace)
(trace interp subst)
(interp (with 'x (add (num 1) (num 17))
          (add (id 'x) (num 12)))
        (list))
(untrace interp)
