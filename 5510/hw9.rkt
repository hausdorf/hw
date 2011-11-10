#lang plai-typed

(define-type FAE
  [num (n : number)]
  [bool (b : boolean)]
  [add (lhs : FAE)
       (rhs : FAE)]
  [sub (lhs : FAE)
       (rhs : FAE)]
  [id (name : symbol)]
  [fun (param : symbol)
       (argty : TE)
       (body : FAE)]
  [Fun (param : (listof symbol))
       (argty : (listof TE))
       (body : FAE)]
  [app (fun-expr : FAE)
       (arg-expr : FAE)]
  [App (Fun-expr : FAE)
       (arg-expr : (listof FAE))]
  [eq (lhs : FAE)
      (rhs : FAE)]
  [ifthenelse (exp : FAE)
              (thenexp : FAE)
              (elseexp : FAE)]
  [pair (f : FAE)
        (s : FAE)]
  [fst (p : FAE)]
  [snd (p : FAE)])

(define-type TE
  [numTE]
  [boolTE]
  [arrowTE (arg : TE)
           (result : TE)]
  [ArrowTE (arg : (listof TE))
           (result : TE)]
  [crossTE (f : TE)
           (s : TE)])

(define-type FAE-Value
  [numV (n : number)]
  [closureV (param : symbol)
            (body : FAE)
            (ds : DefrdSub)]
  [ClosureV (param : (listof symbol))
            (body : FAE)
            (ds : DefrdSub)]
  [boolV (b : boolean)]
  [pairV (f : FAE-Value)
         (s : FAE-Value)])

(define-type DefrdSub
  [mtSub]
  [aSub (name : symbol)
        (value : FAE-Value)
        (rest : DefrdSub)])

(define-type Type
  [idT]
  [numT]
  [boolT]
  [arrowT (arg : Type)
          (result : Type)]
  [ArrowT (arg : (listof Type))
          (result : Type)]
  [crossT (f : Type)
          (s : Type)])

(define-type TypeEnv
  [mtEnv]
  [aBind (name : symbol)
         (type : Type)
         (rest : TypeEnv)])

;; ----------------------------------------

(define (rec-sub p a ds)
  (if (empty? (rest a))
      (aSub (first p)
            (first a)
            ds)
      (aSub (first p)
            (first a)
            (rec-sub (rest p) (rest a) ds))))

(define (rec-bind n a env)
  (if (empty? (rest n))
      (aBind (first n)
             (first a)
             env)
      (aBind (first n)
             (first a)
             (rec-bind (rest n) (rest a) env))))

(define (rec-interp a ds)
  (if (empty? (rest a))
      (list (interp (first a) ds))
      (cons (interp (first a) ds)
            (rec-interp (rest a) ds))))

;; interp : FAE DefrdSub -> FAE-Value
(define (interp a-fae ds)
  (type-case FAE a-fae
    [num (n) (numV n)]
    [bool (b) (boolV b)]
    [add (l r) (num+ (interp l ds) (interp r ds))]
    [sub (l r) (num- (interp l ds) (interp r ds))]
    [id (name) (lookup name ds)]
    [fun (param arg-te body-expr)
         (closureV param body-expr ds)]
    [Fun (param arg-te body-expr)
         (ClosureV param body-expr ds)]
    [app (fun-expr arg-expr)
         (local [(define fun-val
                   (interp fun-expr ds))
                 (define arg-val
                   (interp arg-expr ds))]
           (interp (closureV-body fun-val)
                   (aSub (closureV-param fun-val)
                         arg-val
                         (closureV-ds fun-val))))]
    [App (Fun-expr arg-expr)
         (local [(define Fun-val
                   (interp Fun-expr ds))
                 (define arg-val
                   (rec-interp arg-expr ds))]
           (interp (ClosureV-body Fun-val)
                   (rec-sub (ClosureV-param Fun-val)
                            arg-val
                            (ClosureV-ds Fun-val))))]
    [eq (l r)
        (local [(define l-val (interp l ds))
                (define r-val (interp r ds))]
          (boolV (equal? l-val r-val)))]
    [ifthenelse (exp thenexp elseexp)
                (local [(define exp-val (interp exp ds))
                        (define thenexp-val (interp thenexp ds))
                        (define elseexp-val (interp elseexp ds))]
                  (if (boolV-b exp-val)
                      thenexp-val
                      elseexp-val))]
    [pair (f s) (pairV (interp f ds)
                      (interp s ds))]
    [fst (p) (pairV-f (interp p ds))]
    [snd (p) (pairV-s (interp p ds))]))

;; num-op : (number number -> number) -> (FAE-Value FAE-Value -> FAE-Value)
(define (num-op op op-name x y)
  (numV (op (numV-n x) (numV-n y))))

(define (num+ x y) (num-op + '+ x y))
(define (num- x y) (num-op - '- x y))

(define (lookup name ds)
  (type-case DefrdSub ds
    [mtSub () (error 'lookup "free variable")]
    [aSub (sub-name num rest-ds)
          (if (symbol=? sub-name name)
              num
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
    [ArrowTE (a b) (ArrowT (rec-parse-type a)
                           (parse-type b))]
    [crossTE (f s) (crossT (parse-type f)
                            (parse-type s))]))

(define (rec-parse-type te)
  (if (empty? (rest te))
      (list (parse-type (first te)))
      (cons (parse-type (first te))
            (rec-parse-type (rest te)))))

(define (type-error fae msg)
  (error 'typecheck (string-append
                     "no type: "
                     (string-append
                      (to-string fae)
                      (string-append " not "
                                     msg)))))

(define (map-typecheck a env)
  (cond
    [(empty? (rest a)) (list (typecheck (first a) env))]
    [else (cons (typecheck (first a) env)
                (map-typecheck (rest a) env))]))

(define typecheck : (FAE TypeEnv -> Type)
  (lambda (fae env)
    (type-case FAE fae
      [num (n) (numT)]
      [bool (b) (boolT)]
      [add (l r) (type-case Type (typecheck l env)
                   [numT ()
                         (type-case Type (typecheck r env)
                           [numT () (numT)]
                           [else (type-error r "num")])]
                   [else (type-error l "num")])]
      [sub (l r) (type-case Type (typecheck l env)
                   [numT ()
                         (type-case Type (typecheck r env)
                           [numT () (numT)]
                           [else (type-error r "num")])]
                   [else (type-error l "num")])]
      [id (name) (get-type name env)]
      [fun (name te body)
           (local [(define arg-type (parse-type te))]
             (arrowT arg-type
                     (typecheck body (aBind name
                                            arg-type
                                            env))))]
      [Fun (name te body)
           (local [(define arg-type (rec-parse-type te))]
             (ArrowT arg-type
                     (typecheck body (rec-bind name
                                               arg-type
                                               env))))]
      [app (fn arg)
           (type-case Type (typecheck fn env)
             [arrowT (arg-type result-type)
                     (if (equal? arg-type
                                 (typecheck arg env))
                         result-type
                         (type-error arg
                                     (to-string arg-type)))]
             [else (type-error fn "function")])]
      [App (fn arg)
           (type-case Type (typecheck fn env)
             [ArrowT (arg-type result-type)
                     (if (equal? arg-type
                                 (map-typecheck arg env))
                         result-type
                         (type-error arg
                                     (to-string arg-type)))]
             [else (type-error fn "function")])]
      ; TODO: FIX THIS
      [eq (l r)
          (type-case Type (typecheck l env)
            [numT ()
                   (type-case Type (typecheck r env)
                     [numT () (boolT)]
                     [else (type-error r "numT")])]
            [else (type-error l "numT")])]
      [ifthenelse (i t e)
                  (type-case Type (typecheck i env)
                    [boolT ()
                           (type-case Type (typecheck t env)
                             [numT ()
                                   (type-case Type (typecheck e env)
                                     [numT () (numT)]
                                     [else (type-error e "numT")])]
                             [else (type-error t "numT")])]
                    [else (type-error i "boolT")])]
      [pair (f s)
            (local [(define f-type (typecheck f env))
                    (define s-type (typecheck s env))]
              (crossT (type-case Type f-type
                        [numT () (numT)]
                        [boolT () (boolT)]
                        [else (type-error f "num")])
                      (type-case Type s-type
                        [numT () (numT)]
                        [boolT () (boolT)]
                        [else (type-error s "num")])))]
      [fst (p)
           (type-case FAE p
             [id (name) (crossT-f (get-type name env))]
             [pair (f s)
                   (type-case Type (typecheck f env)
                     [numT () (numT)]
                     [else (type-error f "numT")])]
             [else (type-error p "pair")])]
      [snd (p)
           (type-case FAE p
             [id (name) (crossT-s (get-type name env))]
             [pair (f s)
                   (type-case Type (typecheck s env)
                     [numT () (numT)]
                     [else (type-error s "numT")])]
             [else (type-error p "pair")])])))

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

(test/exn (interp (id 'x) (mtSub))
          "free variable")

(test (typecheck (num 10) (mtEnv))
      (numT))

(test (typecheck (add (num 10) (num 17)) (mtEnv))
      (numT))
(test (typecheck (sub (num 10) (num 7)) (mtEnv))
      (numT))

(test (typecheck (fun 'x (numTE) (add (id 'x) (num 12))) (mtEnv))
      (arrowT (numT) (numT)))

(test (typecheck (fun 'x (numTE) (fun 'y (boolTE) (id 'x))) (mtEnv))
      (arrowT (numT) (arrowT (boolT)  (numT))))

(test (typecheck (app (fun 'x (numTE) (add (id 'x) (num 12)))
                      (add (num 1) (num 17)))
                 (mtEnv))
      (numT))

(test (typecheck (app (fun 'x (numTE)
                           (app (fun 'f (arrowTE (numTE) (numTE))
                                     (add (app (id 'f) (num 1))
                                          (app (fun 'x (numTE) (app (id 'f) (num 2)))
                                               (num 3))))
                                (fun 'y (numTE)
                                     (add (id 'x)
                                          (id' y)))))
                      (num 0))
                 (mtEnv))
      (numT))

(test/exn (typecheck (app (num 1) (num 2)) (mtEnv))
          "no type")

(test/exn (typecheck (add (fun 'x (numTE) (num 12))
                          (num 2))
                     (mtEnv))
          "no type")

(test (typecheck (bool false) (mtEnv))
      (boolT))

(test (interp (eq (num 13) (num 13))
                (mtSub))
         (boolV true))

(test (interp (eq (num 12) (num 13))
                (mtSub))
         (boolV false))

(test (interp (eq (num 13)
                    (ifthenelse (eq (num 1) (add (num -1) (num 2)))
                                (num 12)
                                (num 13)))
                (mtSub))
         (boolV false))

(test (typecheck (eq (num 13)
                       (ifthenelse (eq (num 1) (add (num -1) (num 2)))
                                   (num 12)
                                   (num 13)))
                   (mtEnv))
         (boolT))

(test/exn (typecheck (add (num 1)
                            (ifthenelse (bool true)
                                        (bool true)
                                        (bool false)))
                       (mtEnv))
            "no type")

(test (interp (fst (pair (num 10) (num 8)))
                (mtSub))
        (numV 10))

(test (interp (snd (pair (num 10) (num 8)))
                (mtSub))
        (numV 8))

(test (typecheck (pair (num 10) (num 8))
                   (mtEnv))
        (crossT (numT) (numT)))

(test (typecheck (add (num 1) (snd (pair (num 10) (num 8))))
                   (mtEnv))
        (numT))

(test (typecheck (fun 'x (crossTE (numTE) (boolTE))
                    (ifthenelse (snd (id 'x)) (num 0) (fst (id 'x))))
                   (mtEnv))
       (arrowT (crossT (numT) (boolT)) (numT)))

(test/exn (typecheck (fst (num 10)) (mtEnv))
            "no type")

(test/exn (typecheck (add (num 1) (fst (pair (bool false) (num 8))))
                       (mtEnv))
            "no type")

(test/exn (typecheck (fun 'x (crossTE (numTE) (boolTE))
                             (ifthenelse (fst (id 'x)) (num 0) (fst (id 'x))))
                       (mtEnv))
            "no type")
