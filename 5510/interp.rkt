#lang plai


(define-type EXPR
  [num (n number?)]
  [add (l EXPR?)
       (r EXPR?)]
  [sub (l EXPR?)
       (r EXPR?)]
  [id (i symbol?)]
  ;[fun (name id?)
  ;     (arg EXPR?)]
  )

;; Basic tests for EXPR type
(test (num 3) (num 3))
(test (add (num 3) (num 4)) (add (num 3) (num 4)))
(test (add (add (num 3) (num 4)) (add (num 0) (num 1)))
      (add (add (num 3) (num 4)) (add (num 0) (num 1))))
(test (id 'x) (id 'x))
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
        (subst i vars)]))

;; parse : symbol -> EXPR
(define (parse_helper stuff vars)
  (cond
    ;; <id>
    [(symbol? stuff)
     (id stuff)]
    ;; <num>
    [(number? stuff) (num stuff)]
    ;; add, e.g. '{add 3 2}
    [(and (= 3 (length stuff))
          (symbol=? 'add (first stuff)))
     (add (parse_helper (second stuff) vars)
          (parse_helper (third stuff) vars))]
    ;; sub, e.g. '{sub 3 2}
    [(and (= 3 (length stuff))
          (symbol=? 'sub (first stuff)))
     (sub (parse_helper (second stuff) vars)
          (parse_helper (third stuff) vars))]
    ;; '{is w <number>}
    [(and (= 3 (length stuff))
          (symbol=? 'is (first stuff)))
     (parse_helper stuff
                   (cons '((second stuff) (third stuff)))
                   vars)]
    [else (error "PARSE ERROR")]))

;; parse : symbol -> EXPR
(define (parse stuff)
  (parse_helper stuff (list)))

(test (parse '{add 3 3}) (add (num 3) (num 3)))
(test (parse '{sub 3 3}) (sub (num 3) (num 3)))
(test (parse 3) (num 3))
(test (parse 'x) (id 'x))

;; interpret : EXPR -> number
;;
;; Driver function for interp
(define (interpret expr)
  (interp expr (list)))

(test (interpret (num 3)) 3)
(test (interpret (add (num 3) (num 3))) 6)
(test (interpret (add (sub (num 3) (num 4)) (num 5))) 4)
(test (interpret (sub (num 0) (num 1))) -1)
(test (interpret '3) (num 3))