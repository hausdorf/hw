#lang plai-typed

(define-type FAE
  [num (n : number)]
  [add (lhs : FAE)
       (rhs : FAE)]
  [sub (lhs : FAE)
       (rhs : FAE)]
  [id (name : symbol)]
  [fun (param : symbol)
       (argty : TE)
       (body : FAE)]
  [app (fun-expr : FAE)
       (arg-expr : FAE)]
  [if0 (test-expr : FAE)
       (then-expr : FAE)
       (else-expr : FAE)]
  [mt]
  [cns (f : FAE)
       (s : FAE)]
  [fst (c : FAE)]
  [rst (c : FAE)])

(define-type TE
  [numTE]
  [boolTE]
  [arrowTE (arg : TE)
           (result : TE)]
  [guessTE]
  [listofTE (arg : TE)])

(define-type FAE-Value
  [numV (n : number)]
  [closureV (param : symbol)
            (body : FAE)
            (ds : DefrdSub)]
  [mtV]
  [cnsV (f : FAE-Value)
        (s : FAE-Value)])

(define-type DefrdSub
  [mtSub]
  [aSub (name : symbol)
        (value : FAE-Value)
        (rest : DefrdSub)])

(define-type Type
  [numT]
  [boolT]
  [arrowT (arg : Type)
          (result : Type)]
  [varT (is : (boxof (Option Type)))]
  [listofT (f : Type)])

(define-type (Option 'alpha)
  [none]
  [some (v : 'alpha)])

(define-type TypeEnv
  [mtEnv]
  [aBind (name : symbol)
         (type : Type)
         (rest : TypeEnv)])

;; ----------------------------------------

;; interp : FAE DefrdSub -> FAE-Value
(define (interp a-fae ds)
  (type-case FAE a-fae
    [num (n) (numV n)]
    [add (l r) (num+ (interp l ds) (interp r ds))]
    [sub (l r) (num- (interp l ds) (interp r ds))]
    [id (name) (lookup name ds)]
    [fun (param arg-te body-expr)
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
    [if0 (test-expr then-expr else-expr)
         (if (numzero? (interp test-expr ds))
             (interp then-expr ds)
             (interp else-expr ds))]

    [mt () (mtV)]
    [cns (f s) (cnsV (interp f ds)
                     (interp s ds))]
    [fst (c) (interp (cns-f c) ds)]
    [rst (c) (interp (cns-s c) ds)]))


;; num-op : (number number -> number) -> (FAE-Value FAE-Value -> FAE-Value)
(define (num-op op op-name x y)
  (numV (op (numV-n x) (numV-n y))))

(define (num+ x y) (num-op + '+ x y))
(define (num- x y) (num-op - '- x y))

(define (numzero? x) (= 0 (numV-n x)))

(define (lookup name ds)
  (type-case DefrdSub ds
    [mtSub () (error 'lookup "free variable")]
    [aSub (sub-name val rest-ds)
          (if (symbol=? sub-name name)
              val
              (lookup name rest-ds))]))


;; ----------------------------------------

(define (get-type name-to-find env)
  (type-case TypeEnv env
    [mtEnv () (error 'get-type "free variable, so no type")]
    [aBind (name ty rest)
           (if (symbol=? name-to-find name)
               ty
               (get-type name-to-find rest))]))

;; ----------------------------------------

(define (parse-type te)
  (type-case TE te
    [numTE () (numT)]
    [boolTE () (boolT)]
    [arrowTE (a b) (arrowT (parse-type a)
                           (parse-type b))]
    [guessTE () (varT (box (none)))]
    [listofTE (arg) (listofT (parse-type arg))]))

(define (resolve t)
  (type-case Type t
    [varT (is)
          (type-case (Option Type) (unbox is)
            [none () t]
            [some (t2) (resolve t2)])]
    [else t]))

(define (occurs? r t)
  (type-case Type t
    [numT () false]
    [boolT () false]
    [arrowT (a b)
            (or (occurs? r a)
                (occurs? r b))]
    [varT (is) (or (eq? r t)
                   (type-case (Option Type) (unbox is)
                     [none () false]
                     [some (t2) (occurs? r t2)]))]
    ; new
    [listofT (f) (occurs? r f)]))

(define (type-error fae t1 t2)
  (error 'typecheck (string-append
                     "no type: "
                     (string-append
                      (to-string fae)
                      (string-append
                       " type "
                       (string-append
                        (to-string t1)
                        (string-append
                         " vs. "
                         (to-string t2))))))))

(define (unify! t1 t2 expr)
  (type-case Type t1
    [varT (is1)
          (type-case (Option Type) (unbox is1)
            [some (t3) (unify! t3 t2 expr)]
            [none ()
                  (local [(define t3 (resolve t2))]
                    (if (eq? t1 t3)
                        (values)
                        (if (occurs? t1 t3)
                            (type-error expr t1 t3)
                            (begin
                              (set-box! is1 (some t3))
                              (values)))))])]
    [else
     (type-case Type t2
       [varT (is2) (unify! t2 t1 expr)]
       [numT () (type-case Type t1
                  [numT () (values)]
                  [else (type-error expr t1 t2)])]
       [boolT () (type-case Type t1
                   [boolT () (values)]
                   [else (type-error expr t1 t2)])]
       [arrowT (a2 b2) (type-case Type t1
                         [arrowT (a1 b1)
                                 (begin
                                   (unify! a1 a2 expr)
                                   (unify! b1 b2 expr))]
                         [else (type-error expr t1 t2)])]
       ; new
       [listofT (t) (unify! t1 t expr)])]))

(define typecheck : (FAE TypeEnv -> Type)
  (lambda (fae env)
    (type-case FAE fae
      [num (n) (numT)]
      [add (l r) (begin
                   (unify! (typecheck l env) (numT) l)
                   (unify! (typecheck r env) (numT) r)
                   (numT))]
      [sub (l r) (begin
                   (unify! (typecheck l env) (numT) l)
                   (unify! (typecheck r env) (numT) r)
                   (numT))]
      [id (name) (get-type name env)]
      [fun (name te body)
           (local [(define arg-type (parse-type te))]
             (arrowT arg-type
                     (typecheck body (aBind name
                                            arg-type
                                            env))))]
      [app (fn arg)
           (local [(define result-type (varT (box (none))))]
             (begin
               (unify! (arrowT (typecheck arg env)
                               result-type)
                       (typecheck fn env)
                       fn)
               result-type))]
      [if0 (test-expr then-expr else-expr)
           (begin
             (unify! (typecheck test-expr env) (numT) test-expr)
             (local [(define test-ty (typecheck then-expr env))]
               (begin 
                 (unify! test-ty (typecheck else-expr env) else-expr)
                 test-ty)))]
      ; new
      [mt () (numT)]
      [cns (f s)
           (local [(define ftype (typecheck f env))]
             (begin
               (unify! ftype (typecheck s env) f)
               ftype))]
      [fst (c) (typecheck (cns-f c) env)]
      [rst (c) (typecheck c env)])))


;; ----------------------------------------

(test (interp (num 10)
              (mtSub))
      (numV 10))
(test (interp (add (num 10) (num 17))
              (mtSub))
      (numV 27))
(test (interp (sub (num 10) (num 7))
              (mtSub))
      (numV 3))
(test (interp (app (fun 'x (numTE) (add (id 'x) (num 12)))
                   (add (num 1) (num 17)))
              (mtSub))
      (numV 30))
(test (interp (id 'x)
              (aSub 'x (numV 10) (mtSub)))
      (numV 10))

(test (interp (app (fun 'x (numTE)
                        (app (fun 'f (arrowTE (numTE) (numTE))
                                  (add (app (id 'f) (num 1))
                                       (app (fun 'x (numTE)
                                                 (app (id 'f)
                                                      (num 2)))
                                            (num 3))))
                             (fun 'y (numTE)
                                  (add (id 'x) (id 'y)))))
                   (num 0))
              (mtSub))
      (numV 3))

(test (interp (if0 (num 0) (num 1) (num 2))
              (mtSub))
      (numV 1))
(test (interp (if0 (num 1) (num 1) (num 2))
              (mtSub))
      (numV 2))


(test/exn (interp (id 'x) (mtSub))
          "free variable")

(test (unify! (typecheck (num 10) (mtEnv))
              (numT)
              (num -1))
      (values))

(test (unify! (typecheck (add (num 10) (num 17)) (mtEnv))
              (numT)
              (num -1))
      (values))
(test (unify! (typecheck (sub (num 10) (num 7)) (mtEnv))
              (numT)
              (num -1))
      (values))

(test (unify! (typecheck (fun 'x (numTE) (add (id 'x) (num 12))) (mtEnv))
              (arrowT (numT) (numT))
              (num -1))
      (values))

(test (unify! (typecheck (fun 'x (numTE) (fun 'y (boolTE) (id 'x))) (mtEnv))
              (arrowT (numT) (arrowT (boolT)  (numT)))
              (num -1))
      (values))

(test (unify! (typecheck (app (fun 'x (numTE) (add (id 'x) (num 12)))
                              (add (num 1) (num 17)))
                         (mtEnv))
              (numT)
              (num -1))
      (values))

(test (unify! (typecheck (app (fun 'x (guessTE) (add (id 'x) (num 12)))
                              (add (num 1) (num 17)))
                         (mtEnv))
              (numT)
              (num -1))
      (values))

(test (unify! (typecheck (fun 'x (guessTE) (add (id 'x) (num 12)))
                         (mtEnv))
              (arrowT (numT) (numT))
              (num -1))
      (values))

(test (unify! (typecheck (fun 'x (guessTE) (if0 (num 0) (id 'x) (id 'x)))
                         (mtEnv))
              (arrowT (numT) (numT))
              (num -1))
      (values))

(test (unify! (typecheck (app (fun 'x (numTE)
                                   (app (fun 'f (arrowTE (numTE) (numTE))
                                             (add (app (id 'f) (num 1))
                                                  (app (fun 'x (numTE) (app (id 'f) (num 2)))
                                                       (num 3))))
                                        (fun 'y (numTE)
                                             (add (id 'x)
                                                  (id' y)))))
                              (num 0))
                         (mtEnv))
              (numT)
              (num -1))
      (values))

(test (unify! (typecheck (if0 (num 0) (num 1) (num 2))
                         (mtEnv))
              (numT)
              (num -1))
      (values))
(test (unify! (typecheck (if0 (num 0) 
                              (fun 'x (numTE) (id 'x))
                              (fun 'y (numTE) (num 3)))
                         (mtEnv))
              (arrowT (numT) (numT))
              (num -1))
      (values))


(test/exn (typecheck (app (num 1) (num 2)) (mtEnv))
          "no type")

(test/exn (typecheck (add (fun 'x (numTE) (num 12))
                          (num 2))
                     (mtEnv))
          "no type")
(test/exn (typecheck (if0 (num 0) 
                          (num 7)
                          (fun 'y (numTE) (num 3)))
                     (mtEnv))
          "no type")

(test/exn (unify! (typecheck (fun 'x (guessTE) (add (id 'x) (num 12)))
                             (mtEnv))
                  (arrowT (boolT) (numT))
                  (num -1))
          "no type")

(test/exn (typecheck (fun 'x (guessTE) (app (id 'x) (id 'x)))
                     (mtEnv))
          "no type")

; new
(test (unify! (typecheck (fun 'x (guessTE)
                              (cns (num 10) (rst (id 'x))))
                         (mtEnv))
              (arrowT (listofT (numT)) (listofT (numT)))
              (num -1))
      (values))

(test (unify! (typecheck (app (fst (cns (fun 'x (guessTE) (id 'x)) 
                                        (mt)))
                              (fun 'y (numTE) (id 'y)))
                         (mtEnv))
              (arrowT (numT) (numT))
              (num -1))
      (values))

(test (unify! (typecheck (fun 'x (guessTE)
                              (cns (num 10) (rst (id 'x))))
                         (mtEnv))
              (arrowT (listofT (numT)) (listofT (numT)))
              (num -1))
      (values))

(test (unify! (typecheck (app (fst (cns (fun 'x (guessTE) (id 'x)) 
                                        (mt)))
                              (fun 'y (numTE) (id 'y)))
                         (mtEnv))
              (arrowT (numT) (numT))
              (num -1))
      (values))

(test/exn (typecheck (cns (fun 'x (guessTE) (id 'x)) 
                          (cns (num 5)
                               (mt)))
                     (mtEnv))
          "no type")