#lang plai
(define-type FunDef
  [fundef (fun-name symbol?)
          (arg-name symbol?)
          (body F1WAE?)])

(define-type F1WAE
  [num (n number?)]
  [add (lhs F1WAE?)
       (rhs F1WAE?)]
  [app (fun-name symbol?)
       (arg F1WAE?)])

(define (lookup-fundef name fundefs)
  (cond
    [(empty? fundefs)
     (error 'interp "unknown function")]
    [else
     (if (symbol=? name (fundef-fun-name
                         (first fundefs)))
         (first fundefs)
         (lookup-fundef name (rest fundefs)))]))

(define (interp a-wae fundefs)
  (type-case F1WAE a-wae
    [num (n) n]
    [add (l r) (+ (interp l fundefs)
                  (interp r fundefs))]
    ...
    [app (name arg-expr)
         (local [(define a-fundef
                   (lookup-fundef name fundefs))]
           (interp (subst (fundef-body a-fundef)
                          (fundef-arg-name a-fundef)
                          (interp arg-expr fundefs))
                   fundefs))]))

(test (interp (app 'f (num 10))
              (list
               (fundef 'f 'x
                       (sub (num 20)
                            (app 'twice (id 'x))))
               (fundef 'twice 'y
                       (add (id 'y) (id 'y))))
              0))