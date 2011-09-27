#lang plai


(define-type EXPR
  ;; A number
  [num (n number?)]
  [add (l EXPR?)
       (r EXPR?)]
  [sub (l EXPR?)
       (r EXPR?)]
  ;; An id, e.g., a variable or function name
  [id (i symbol?)]
  ;; A variable or function definition
  ;[is (i id?)
  ;    (e EXPR?)]
  [func (name id?)
        (args id?)
        (body EXPR?)]
  )

;; Basic tests for EXPR type
(test (num 3)
      (num 3))
(test (add (num 3) (num 4))
      (add (num 3) (num 4)))
(test (add (add (num 3) (num 4)) (add (num 0) (num 1)))
      (add (add (num 3) (num 4)) (add (num 0) (num 1))))
(test (id 'x)
      (id 'x))
;(test (fun (id 'x) (num 3)) (fun (id 'x) (num 3)))

;; subst : id -> list-of-var-val-tuples -> number
(define (subst ident vars)
  (cond
    [(empty? vars) (error "Free variable providedto subst")]
    [(cons? vars) (if (= ident (first (first vars)))
                      (second (first vars))
                      (subst ident (rest vars)))]))

;; interp : EXPR -> variables -> number
;;
;; Handles most of the interpretation heavywork
(define (interp expr vars)
  (type-case EXPR expr
    [num (n) n]
    [add (l r)
         (+ (interp l vars) (interp r vars))]
    [sub (l r)
         (- (interp l vars) (interp r vars))]
    [id (i)
        (subst i vars)]
    ;; TODO: Handle this properly
    ;[is (i e) '()]
    [func (name args body)
          '()]
    ))

;; parse : symbol -> EXPR
(define (parse_helper stuff funcs vars)
  (cond
    ;; <id>
    [(symbol? stuff)
     (id stuff)]
    ;; <num>
    [(number? stuff) (num stuff)]
    ;; add, e.g. '{add 3 2}
    [(and (= 3 (length stuff))
          (symbol=? 'add (first stuff)))
     (add (parse_helper (second stuff) funcs vars)
          (parse_helper (third stuff) funcs vars))]
    ;; sub, e.g. '{sub 3 2}
    [(and (= 3 (length stuff))
          (symbol=? 'sub (first stuff)))
     (sub (parse_helper (second stuff) funcs vars)
          (parse_helper (third stuff) funcs vars))]
    ;; '{is x <number>}
    ;; TODO: Handle this correctly
    ;[(and (= 3 (length stuff))
    ;      (symbol=? 'is (first stuff)))
    ; (parse_helper stuff
    ;               (cons '((second stuff) (third stuff)))
    ;               vars)]
    ;; func, e.g. '{func f x {x + 1}}
    [(and (= 4 (length stuff))
          (symbol=? 'func (first stuff)))
     (func (parse_helper (second stuff) funcs vars)
           (parse_helper (third stuff) funcs vars)
           (parse_helper (fourth stuff) funcs vars))]
    [else (error "PARSE ERROR")]))

;; parse : symbol -> EXPR
(define (parse stuff)
  (parse_helper stuff (list) (list)))

(test (parse '{add 3 3})
      (add (num 3) (num 3)))
(test (parse '{sub 3 3})
      (sub (num 3) (num 3)))
(test (parse 3)
      (num 3))
(test (parse 'x)
      (id 'x))


;; interpret : code -> number
;;
;; Driver function for interp
(define (interpret expr)
  (interp (parse expr) (list)))

(test (interpret 3)
      3)
(test (interpret '{add 3 3})
      6)
(test (interpret '{add (sub 3 4) 5})
      4)
(test (interpret '(sub 0 1))
      -1)
;(test (interpret '{func f x {add x 1}})
;      (func (id 'f) (id 'x) (add (id 'x) (num 1))))