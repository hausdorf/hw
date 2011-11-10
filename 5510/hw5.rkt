#lang plai

(define-type Rcrd-Data
  [data (name id?)
        (expr RCFAE?)])

(define-type RCFAE
  [num (n number?)]
  [add (lhs RCFAE?)
       (rhs RCFAE?)]
  [sub (lhs RCFAE?)
       (rhs RCFAE?)]
  [id (name symbol?)]
  [fun (param symbol?)
       (body RCFAE?)]
  [app (fun-expr RCFAE?)
       (arg-expr RCFAE?)]
  [newbox (val-expr RCFAE?)]
  [setbox (box-expr RCFAE?)
          (val-expr RCFAE?)]
  [openbox (box-expr RCFAE?)]
  [seqn (first-expr (listof RCFAE?))]
  [record (rcrds (listof data?))]
  [get (expr RCFAE?)
       (name id?)])

(define-type RCFAE-Value
  [numV (n number?)]
  [closureV (param symbol?)
            (body RCFAE?)
            (ds DefrdSub?)]
  [boxV (address integer?)])

(define-type DefrdSub
  [mtSub]
  [aSub (name symbol?)
        (value RCFAE-Value?)
        (rest DefrdSub?)])

(define-type Store
  [mtSto]
  [aSto (address integer?)
        (value RCFAE-Value?)
        (rest Store?)])

(define-type Value*Store
  [v*s (value RCFAE-Value?)
       (store Store?)])

;; ----------------------------------------

;; parse : S-expr -> RCFAE
(define (parse sexp)
  (cond
    [(number? sexp) (num sexp)]
    [(symbol? sexp) (id sexp)]
    [(pair? sexp)
     (case (car sexp)
       [(+) (add (parse (second sexp)) (parse (third sexp)))]
       [(-) (sub (parse (second sexp)) (parse (third sexp)))]
       [(fun) (fun (first (second sexp)) (parse (third sexp)))]
       [(newbox) (newbox (parse (second sexp)))]
       [(setbox) (setbox (parse (second sexp)) (parse (third sexp)))]
       [(openbox) (openbox (parse (second sexp)))]
       [(seqn) (seqn (map parse (rest sexp)))]
       [(record) (record (map parse-record (rest sexp)))]
       [(get) (get (parse (second sexp)) (parse (third sexp)))]
       [else (app (parse (first sexp)) (parse (second sexp)))])]))

(define (parse-record sexp)
  (data (parse (first sexp)) (parse (second sexp))))

(test (parse 3) (num 3))
(test (parse 'x) (id 'x))
(test (parse '{+ 1 2}) (add (num 1) (num 2)))
(test (parse '{- 1 2}) (sub (num 1) (num 2)))
(test (parse '{fun {x} x}) (fun 'x (id 'x)))
(test (parse '{1 2}) (app (num 1) (num 2)))
(test (parse '{newbox 1}) (newbox (num 1)))
(test (parse '{setbox 1 2}) (setbox (num 1) (num 2)))
(test (parse '{openbox 1}) (openbox (num 1)))
(test (parse '{seqn 1 2}) (seqn (num 1) (num 2)))
(test (parse '{record}) (record (list)))

;; ----------------------------------------

;; interp : RCFAE DefrdSub Store -> Value*Store
(define (interp a-fae ds st)
  (type-case RCFAE a-fae
    [num (n) (v*s (numV n) st)]
    [add (l r) (interp-sto l r ds st
                           (lambda (v1 v2 st)
                             (v*s (num+ v1 v2) st)))]
    [sub (l r) (interp-sto l r ds st
                           (lambda (v1 v2 st)
                             (v*s (num- v1 v2) st)))]
    [id (name) (v*s (lookup name ds) st)]
    [fun (param body-expr)
         (v*s (closureV param body-expr ds) st)]
    [app (fun-expr arg-expr)
         (interp-sto fun-expr arg-expr ds st
                     (lambda (fun-val arg-val st)
                       (interp (closureV-body fun-val)
                               (aSub (closureV-param fun-val)
                                     arg-val
                                     (closureV-ds fun-val))
                               st)))]
    [newbox (expr)
            (type-case Value*Store (interp expr ds st)
              [v*s (val st)
                   (local [(define a (malloc st))]
                     (v*s (boxV a)
                          (aSto a val st)))])]
    [setbox (bx-expr val-expr)
            (interp-sto bx-expr val-expr ds st
                        (lambda (bx-val val st3)
                          (v*s val
                               (sto-repl val (boxV-address bx-val) st3))))]
    [openbox (bx-expr)
             (type-case Value*Store (interp bx-expr ds st)
               [v*s (bx-val st)
                    (v*s (store-lookup (boxV-address bx-val)
                                       st)
                         st)])]
    [seqn (a) (interp-seqn a ds st
                            (lambda (v1 v2 st)
                              (v*s v2 st)))]
    [record (rcrds) (record rcrds)]
    [get (expr name) (if (record? expr)
                         (get-record name (record-rcrds expr))
                         (interp expr ds st))]))

(define (get-record name datal)
  (define nm (data-name (first datal)))
  (if (symbol=? (id-name name) (id-name nm))
      (data-expr (first datal))
      (if (empty? (rest datal))
          (error "no such field")
          (get-record name (rest datal)))))
  

(define (interp-seqn expr ds st handle)
  (define pe (interp (first expr) ds st))
  (if (empty? (rest expr))
      pe
      (interp-seqn (rest expr) ds (v*s-store pe) handle)))

;;interp-sto : RCFAE RCFAE DefrdSub Store
;;                  (Value Value Store -> Value*Store)
;;             -> Value*Store
(define (interp-sto expr1 expr2 ds st handle)
  (type-case Value*Store (interp expr1 ds st)
    [v*s (val1 st2)
         (type-case Value*Store (interp expr2 ds st2)
           [v*s (val2 st3)
                (handle val1 val2 st3)])]))

(define (interp-expr rcrd)
  ;(printf "\n\nHDKSDJHFK\n")
  ;(print rcrd)
  ;(printf "\nSLD\n")
  (define res (interp rcrd (mtSub) (mtSto)))
  ;(print res)
  (cond
    [(record? res) 'record]
    [(app? res) 'function]))

;;sto-repl : RCFAE natural-number store -> store
;;
;; Looks at the entire store, replaces the value in store at address. NOTE: will replace all numbers with
;; given address!
(define (sto-repl val addr st)
  (type-case Store st
    [mtSto () (mtSto)]
    [aSto (sto-addr val2 rest-st)
          (if (= addr sto-addr)
              (aSto sto-addr val (sto-repl val addr rest-st))
              (aSto sto-addr val2 (sto-repl val addr rest-st)))]))

(test (sto-repl (numV 1) 1 (aSto 1 (numV 2) (aSto 1 (numV 1) (mtSto)))) (aSto 1 (numV 1) (aSto 1 (numV 1) (mtSto))))

;; num-op : (number number -> number) -> (RCFAE-Value RCFAE-Value -> RCFAE-Value)
(define (num-op op op-name x y)
  (numV (op (numV-n x) (numV-n y))))

(define (num+ x y) (num-op + '+ x y))
(define (num- x y) (num-op - '- x y))

;; malloc : Store -> integer
(define (malloc st)
  (+ 1 (max-address st)))

;; max-address : Store -> integer
(define (max-address st)
  (type-case Store st
    [mtSto () 0]
    [aSto (n v st)
          (max n (max-address st))]))

;; lookup : symbol DefrdSub -> RCFAE-Value
(define (lookup name ds)
  (type-case DefrdSub ds
    [mtSub () (error 'lookup "free variable")]
    [aSub (sub-name val rest-ds)
          (if (symbol=? sub-name name)
              val
              (lookup name rest-ds))]))

;; store-lookup : number Store -> RCFAE-Value
(define (store-lookup addr st)
  (type-case Store st
    [mtSto () (error 'store-lookup "unallocated")]
    [aSto (sto-addr val rest-st)
          (if (= addr sto-addr)
              val
              (store-lookup addr rest-st))]))

;; ----------------------------------------
;; Old, functional tests:

(test (interp (parse 10)
              (mtSub)
              (mtSto))
      (v*s (numV 10) (mtSto)))
(test (interp (parse '{+ 10 17})
              (mtSub)
              (mtSto))
      (v*s (numV 27) (mtSto)))
(test (interp (parse '{- 10 7})
              (mtSub)
              (mtSto))
      (v*s (numV 3) (mtSto)))
(test (interp (parse '{{fun {x} {+ x 12}}
                       {+ 1 17}})
              (mtSub) 
              (mtSto))
      (v*s (numV 30) (mtSto)))
(test (interp (parse 'x)
              (aSub 'x (numV 10) (mtSub))
              (mtSto))
      (v*s (numV 10) (mtSto)))

(test (interp (parse '{{fun {x}
                            {{fun {f}
                                  {+ {f 1}
                                     {{fun {x}
                                           {f 2}}
                                      3}}}
                             {fun {y} {+ x y}}}}
                       0})
              (mtSub)
              (mtSto))
      (v*s (numV 3) (mtSto)))

(test/exn (interp (parse 'x) (mtSub) (mtSto))
          "free variable")

;; ----------------------------------------
;; Store tests:

(test (interp (parse '{seqn 1 2})
              (mtSub)
              (mtSto))
      (v*s (numV 2) (mtSto)))

(test (interp (parse '{{fun {b} {openbox b}}
                       {newbox 10}})
              (mtSub)
              (mtSto))
      (v*s (numV 10) 
           (aSto 1 (numV 10) (mtSto))))

(test (interp (parse '{{fun {b} {openbox b}}
                       {seqn
                        {newbox 9}
                        {newbox 10}}})
              (mtSub)
              (mtSto))
      (v*s (numV 10) 
           (aSto 2 (numV 10) 
                 (aSto 1 (numV 9) (mtSto)))))

(test (interp (parse '{{{fun {b} 
                             {fun {a}
                                  {openbox b}}}
                        {newbox 9}}
                       {newbox 10}})
              (mtSub)
              (mtSto))
      (v*s (numV 9) 
           (aSto 2 (numV 10) 
                 (aSto 1 (numV 9) (mtSto)))))

(test (interp (parse '{{fun {b} {seqn
                                 {setbox b 12}
                                 {openbox b}}}
                       {newbox 10}})
              (mtSub)
              (mtSto))
      (v*s (numV 12) 
           (aSto 1
                 (numV 12)
                 (mtSto))))

(test/exn (interp (parse '{openbox x})
                  (aSub 'x (boxV 1) (mtSub))
                  (mtSto))
          "unallocated")

(test (interp (parse '{{fun {b}
                          {seqn
                           {setbox b 2}
                           {openbox b}}}
                         {newbox 1}})
                (mtSub)
                (mtSto))
        (v*s (numV 2)
             (aSto 1 (numV 2) (mtSto))))

(test (interp (parse '{{fun {b}
                          {seqn
                           {setbox b {+ 2 (openbox b)}}
                           {setbox b {+ 3 (openbox b)}}
                           {setbox b {+ 4 (openbox b)}}
                           {openbox b}}}
                         {newbox 1}})
                (mtSub)
                (mtSto))
        (v*s (numV 10)
             (aSto 1 (numV 10) (mtSto))))

(test (interp-expr (parse '{record {a 10} {b {+ 1 2}}}))
      'record)
(test (interp-expr (parse '{get {record {a 10} {b {+ 1 2}}} b}))
      3)
(test/exn (interp-expr (parse '{get {record {a 10}} b})) "no such field")
(test (interp-expr (parse '{get {record {r {record {z 0}}}} r}))
      'record)
(test (interp-expr (parse '{get {get {record {r {record {z 0}}}} r} z}))
      0)

