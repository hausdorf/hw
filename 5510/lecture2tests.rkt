#lang plai

(define-type WAE
  [num (n number?)]
  [add (lhs WAE?)
       (rhs WAE?)]
  [sub (lhs WAE?)
       (rhs WAE?)]
  [with (name symbol?)
        (named-expr WAE?)
        (body WAE?)]
  [id (name symbol?)])

(define (subst a-wae sub-id val)
  (type-case WAE a-wae
    [num (n) a-wae]
    [add (l r) (add (subst l sub-id val)
                    (subst r sub-id val))]
    [sub (l r) (sub (subst l sub-id val)
                    (subst r sub-id val))]
    [with (bound-id named-expr body-expr) ]
    [id (name) (if (symbol=? name sub-id)
                   (num val)
                   a-wae)]))
(test (subst (add (num 1) (id 'x)) 'x 10) (add (num 1) (num 10)))
(test (subst (id 'x) 'x 10) (num 10))
(test (subst (id 'y) 'x 10) (id 'y))
(test (subst (sub (id 'x) (num 1)) 'y 10) (sub (is 'x) (num 1)))

(define (interp a-wae)
  (type-case WAE a-wae
    [num (n) n]
    [add (l r) (+ (interp l) (interp r))]
    [sub (l r) (- (interp l) (interp r))]
    [with (bound-id named-expr body-expr)
          (interp (substr body-expr
                          bound-id
                          (interp named-expr)))]
    [id (name) (error 'interp "free variable")]))