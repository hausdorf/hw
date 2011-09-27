#lang plai

(define-type IR
  [num (n number?)]
  [id (i symbol?)]
  [with (i id?)
        (n IR?)]
  [fun (i id?)])

(num 3)
(id 'cow)
(with (id 'cow) (num 3))
(with (id 'cow) (id 'farmer))
(fun (id 'f))

;; Constructs IR tree based on an expression
(define (lex stuff)
  (cond
    ; number
    [(number? stuff)
     (num stuff)]
    ; id
    [(symbol? stuff)
     (id stuff)]
    ; '{with x 3}
    [(and (= 3 (length stuff))
          (symbol=? (first stuff) 'with))
     (with (id (second stuff))
           (lex (third stuff)))]
    [(and (= 2 (length stuff))
          (symbol=? (first stuff) 'fun))
     (fun (lex (second stuff)))]))

(lex '{with x 3})
(lex '{with x y})
(lex '{fun x})

;; Substitutes a variable for its value
(define (subst var all-vars)
  (if (symbol=? var (first (first all-vars)))
      (second (first all-vars))
      (subst var (rest all-vars))))

(subst 'x '((x 3)))

;; Parses IR tree
(define (parse stuff funcs vars)
  (type-case IR stuff
    [num (n) n]
    [id (i) (num (subst i vars))]
    [with (i n) i]
    [fun (i) i]))

(parse (id 'x) '() '((x 3)))