#lang plai-typed

(define-type CAE
  [num (n : number)]
  [str (s : string)]
  [add (lhs : CAE)
       (rhs : CAE)]
  [sub (lhs : CAE)
       (rhs : CAE)]
  [if0 (test-expr : CAE)
       (then-expr : CAE)
       (else-expr : CAE)]
  [arg]
  [this]
  [new (class : symbol)
       (args : (listof CAE))]
  [get (obj-expr : CAE)
       (field-name : symbol)]
  [dsend (obj-expr : CAE)
         (method-name : symbol)
         (arg-expr : CAE)]
  [ssend (obj-expr : CAE)
         (class-name : symbol)
         (method-name : symbol)
         (arg-expr : CAE)])

(define-type CDecl
  [class (name : symbol)
    (fields : (listof Field))
    (methods : (listof Method))])

(define-type Field
  [field (name : symbol)])

(define-type Method
  [method (name : symbol)
          (body-expr : CAE)])

(define-type CAE-Value
  [numV (n : number)]
  [strV (s : string)]
  [objV (class : CDecl)
        (field-values : (listof CAE-Value))])

;; ----------------------------------------

(define (find what name-of)
  (lambda (name vals)
    (cond
      [(empty? vals)
       (error 'find (string-append
                     (string-append
                      "cannot find "
                      what)
                     (string-append
                      " "
                      (to-string name))))]
      [else (if (equal? name (name-of (first vals)))
                (first vals)
                ((find what name-of) name (rest vals)))])))

(define find-class
  (find "class" (lambda (c)
                  (type-case CDecl c
                    [class (name fields methods) name]))))

(define find-method
  (find "method" (lambda (m)
                   (type-case Method m
                     [method (name body-expr) name]))))

(define (get-field name fields vals)
  (local [(define-values (n v)
            ((find "field"
                   (lambda (n+v)
                     (local [(define-values (n v) n+v)]
                       n)))
             name
             (map2 (lambda (f v)
                     (type-case Field f
                       [field (name) (values name v)]))
                   fields
                   vals)))]
    v))

;; ----------------------------------------

(define interp : (CAE (listof CDecl) CAE-Value CAE-Value -> CAE-Value)
  (lambda (a-cae cdecls this-val arg-val)
    (local [(define (recur expr)
              (interp expr cdecls this-val arg-val))]
      (type-case CAE a-cae
        [num (n) (numV n)]
        [str (s) (strV s)]
        [add (l r) (num+ (recur l) (recur r))]
        [sub (l r) (num- (recur l) (recur r))]
        [if0 (test-expr then-expr else-expr)
             (if (numzero? (recur test-expr))
                 (recur then-expr)
                 (recur else-expr))]
        [this () this-val]
        [arg () arg-val]
        [new (class-name field-exprs)
             (local [(define cdecl (find-class class-name cdecls))
                     (define vals (map recur field-exprs))]
               (objV cdecl vals))]
        [get (obj-expr field-name)
             (type-case CAE-Value (recur obj-expr)
               [objV (cdecl field-vals)
                     (type-case CDecl cdecl
                       [class (name fields methods)
                         (get-field field-name fields field-vals)])]
               [else (error 'interp "not an object")])]
        [dsend (obj-expr method-name arg-expr)
               (local [(define obj (recur obj-expr))
                       (define arg-val (recur arg-expr))]
                 (type-case CAE-Value obj
                   [objV (cdecl field-vals)
                         (type-case CDecl cdecl
                           [class (name fields methods)
                             (type-case Method (find-method method-name methods)
                               [method (name body-expr)
                                       (interp body-expr
                                               cdecls
                                               obj
                                               arg-val)])])]
                   [else (error 'interp "not an object")]))]
        [ssend (obj-expr class-name method-name arg-expr)
               (local [(define obj (recur obj-expr))
                       (define arg-val (recur arg-expr))]
                 (type-case CDecl (find-class class-name cdecls)
                   [class (name fields methods)
                     (type-case Method (find-method method-name methods)
                       [method (name body-expr)
                               (interp body-expr
                                       cdecls
                                       obj
                                       arg-val)])]))]))))

;; num-op : (number number -> number) -> (CAE-Value CAE-Value -> CAE-Value)
(define (num-op op op-name x y)
  (numV (op (numV-n x) (numV-n y))))

(define (num+ x y) (num-op + '+ x y))
(define (num- x y) (num-op - '- x y))
(define (numzero? x) (= 0 (numV-n x)))

;; Examples

(define posnClass
  (class 'posn
    (list (field 'x) (field 'y))
    (list (method 'mdist
                  (add (get (this) 'x) (get (this) 'y)))
          (method 'addDist
                  (add (dsend (this) 'mdist (num 0))
                       (dsend (arg) 'mdist (num 0))))
          (method 'addX
                  (add (get (this) 'x) (arg)))
          (method 'subY (sub (arg) (get (this) 'y)))
          (method 'factory01 (new 'posn (list (num 0) (num 1)))))))

(define posn3DClass
  (class 'posn3D
    (list (field 'x) (field 'y) (field 'z))
    (list (method 'mdist (add (get (this) 'z)
                              (ssend (this) 'posn 'mdist (arg))))
          (method 'addDist (ssend (this) 'posn 'addDist (arg))))))

(define mkPosn27 (new 'posn (list (num 2) (num 7))))
(define mkPosn531 (new 'posn3D (list (num 5) (num 3) (num 1))))

(define (mdist o)
  (dsend o 'mdist (num 0)))
(define (addDist o p)
  (dsend o 'addDist p))
(define (addX o y)
  (dsend o 'addX y))
(define (subY o y)
  (dsend o 'subY y))

(define (interp-posn x)
  (interp x (list posnClass posn3DClass) (numV 0) (numV 0)))

;; ----------------------------------------

(test (interp (num 10) 
              empty (numV -1) (numV -1))
      (numV 10))
(test (interp (add (num 10) (num 17))
              empty (numV -1) (numV -1))
      (numV 27))
(test (interp (sub (num 10) (num 7))
              empty (numV -1) (numV -1))
      (numV 3))

(test (interp-posn (mdist mkPosn27))
      (numV 9))

(test (interp-posn (addX mkPosn27 (num 10)))
      (numV 12))

(test (interp-posn (subY (ssend mkPosn27 'posn 'factory01 (num 0)) (num 15)))
      (numV 14))

(test (interp-posn (addDist mkPosn531 mkPosn27))
      (numV 18))

;; ======================================================================

;; Source Language with Inheritance

(define-type ICAE
  [inum (n : number)]
  [istr (s : string)]
  [iadd (lhs : ICAE)
        (rhs : ICAE)]
  [isub (lhs : ICAE)
        (rhs : ICAE)]
  [iif0 (test-expr : ICAE)
        (then-expr : ICAE)
        (else-expr : ICAE)]
  [iarg]
  [ithis]
  [inew (class : symbol)
        (args : (listof ICAE))]
  [iget (obj-expr : ICAE)
        (field-name : symbol)]
  [isend (obj-expr : ICAE)
         (method-name : symbol)
         (arg-expr : ICAE)]
  [isuper (method-name : symbol)
          (arg-expr : ICAE)]
  [instanceof (cl : ICAE)
              (target : symbol)])  ;#

(define-type IDecl
  [iclass (name : symbol)
          (super : symbol)
          (fields : (listof IField))
          (methods : (listof IMethod))])

(define-type IField
  [ifield (name : symbol)])

(define-type IMethod
  [imethod (name : symbol)
           (body-expr : ICAE)])


(define find-iclass 
  (find "class" (lambda (c)
                  (type-case IDecl c
                    [iclass (name super fields methods) name]))))

(define compile-expr : (ICAE IDecl (listof IDecl) -> CAE)
  (lambda (icae this-class all-classes)
    (local [(define (recur expr)
              (compile-expr expr this-class all-classes))]
      (type-case ICAE icae
        [inum (n) (num n)]
        [istr (s) (str s)]
        [iadd (r l) (add (recur l) (recur r))]
        [isub (r l) (sub (recur l) (recur r))]
        [iif0 (t th el) (if0 (recur t) (recur th) (recur el))]
        [iarg () (arg)]
        [ithis () (this)]
        [inew (class-name field-exprs)
              (new class-name (map recur field-exprs))]
        [iget (expr field-name)
              (get (recur expr) field-name)]
        [isend (expr method-name arg-expr)
               (dsend (recur expr)
                      method-name
                      (recur arg-expr))]
        [isuper (method-name arg-expr)
                (type-case IDecl this-class
                  [iclass (name super-name fields method)
                          (ssend (this) 
                                 super-name method-name
                                 (recur arg-expr))])]
        [instanceof (expr cl)
                    ; Process the expr argument; if it's an object, try to find out whether
                    ; it's an instance of `cl`. 
                    (type-case ICAE expr
                      [inew (class-name field-exprs) (is-instanceof? (find-iclass (inew-class expr) all-classes)
                                                                     cl
                                                                     all-classes)]
                      [else (error 'compile-expr "instanceof must take an object to work!")])]))))  ;#

(define (is-instanceof? expr target all-idecls)
  (local [(define class (find-iclass (iclass-name expr) all-idecls))]
    (cond
      [(equal? (iclass-name class) target) (num 1)]
      [(equal? (iclass-name class) 'object) (num 0)]
      [(equal? (iclass-super class) 'object) (num 0)]
      [else (is-instanceof? (find-iclass (iclass-super class) all-idecls)
                            target
                            all-idecls)])))

(define (compile-methods idecl)
  (type-case IDecl idecl
    [iclass (name super-name fields methods)
            (class name
              (map (lambda (f)
                     (type-case IField f
                       [ifield (name) (field name)]))
                   fields)
              (map (lambda (m)
                     (type-case IMethod m
                       [imethod (name body-expr) 
                                (method name 
                                        (compile-expr body-expr
                                                      idecl
                                                      empty))]))
                   methods))]))

(define (add-fields super-fields fields)
  (append super-fields fields))

(define (add/replace-methods methods new-methods)
  (cond
    [(empty? new-methods) methods]
    [else (add/replace-methods
           (add/replace-method methods (first new-methods))
           (rest new-methods))]))

(define (add/replace-method methods new-method)
  (cond
    [(empty? methods) (list new-method)]
    [else
     (if (equal? (method-name (first methods))
                 (method-name new-method))
         (cons new-method (rest methods))
         (cons (first methods) (add/replace-method
                                (rest methods)
                                new-method)))]))

(define (flatten-class cdecl idecls cdecls)
  (type-case CDecl cdecl
    [class (name fields methods)
      (type-case IDecl (find-iclass name idecls)
        [iclass (name super-name ifields imethods)
                (type-case CDecl (if (equal? super-name 'object)
                                     (class 'object empty empty)
                                     (flatten-class
                                      (find-class super-name cdecls)
                                      idecls
                                      cdecls))
                  [class (super-name super-fields super-methods)
                    (class name
                      (add-fields super-fields fields)
                      (add/replace-methods super-methods methods))])])]))

(define (iinterp idecls iexpr)
  (local [(define expr (compile-expr iexpr 
                                     (iclass 'bad 'bad empty empty)
                                     idecls))
          (define cdecls-not-flat
            (map compile-methods idecls))
          (define cdecls
            (map (lambda (cdecl)
                   (flatten-class cdecl idecls cdecls-not-flat))
                 cdecls-not-flat))]
    (interp expr  cdecls (numV 0) (numV 0))))

;; ======================================================================

;; Examples

(define sposnClass
  (iclass 'posn 'object
          (list (ifield 'x) (ifield 'y))
          (list (imethod 'mdist (iadd (iget (ithis) 'x) (iget (ithis) 'y)))
                (imethod 'addDist (iadd (isend (ithis) 'mdist (inum 0))
                                        (isend (iarg) 'mdist (inum 0)))))))

(define sposn3DClass
  (iclass 'posn3D 'posn
          (list (ifield 'z))
          (list (imethod 'mdist (iadd (iget (ithis) 'z)
                                      (isuper 'mdist (iarg)))))))

(define smkPosn27 (inew 'posn (list (inum 2) (inum 7))))
(define smkPosn531 (inew 'posn3D (list (inum 5) (inum 3) (inum 1))))

(define (smdist o)
  (isend o 'mdist (inum 0)))
(define (saddDist o p)
  (isend o 'addDist p))

(define (sinterpPosn x)
  (iinterp (list sposnClass sposn3DClass) x))

;; Test cases

(test (sinterpPosn (smdist smkPosn27))
      (numV 9))
(test (sinterpPosn (smdist smkPosn531))
      (numV 9))
(test (sinterpPosn (saddDist smkPosn531 smkPosn27))
      (numV 18))
(test (sinterpPosn (saddDist smkPosn27 smkPosn531))
      (numV 18))


;; ======================================================================

;; Source language with types --- only the declarations have to change

(define-type TDecl
  [tclass (name : symbol)
          (super-name : symbol)
          (fields : (listof TField))
          (methods : (listof TMethod))])

(define-type TField
  [tfield (name : symbol)
          (te : TE)])

(define-type TMethod
  [tmethod (name : symbol)
           (arg-te : TE)
           (result-te : TE)
           (body-expr : ICAE)])

(define-type TE
  [numTE]
  [strTE]
  [objTE (class-name : symbol)])

(define-type Type
  [numT]
  [strT]
  [objT (class-name : symbol)])

;; Type checking

(define find-tclass
  (find "class"
        (lambda (c)
          (type-case TDecl c
            [tclass (name super-name fields methods) name]))))

(define find-tfield
  (find "field"
        (lambda (f)
          (type-case TField f
            [tfield (name te) name]))))

(define find-tmethod
  (find "method"
        (lambda (m)
          (type-case TMethod m
            [tmethod (name arg-te result-te body-expr) name]))))


(define (parse-type te)
  (type-case TE te
    [numTE () (numT)]
    [strTE () (strT)]
    [objTE (name) (objT name)]))

(define (type-error fae msg)
  (error 'typecheck (string-append
                     "no type: "
                     (string-append
                      (to-string fae)
                      (string-append " not "
                                     msg)))))

(define (get-all-field-types class-name tdecls)
  (if (equal? class-name 'object)
      empty        
      (type-case TDecl (find-tclass class-name tdecls)
        [tclass (name super-name fields methods)
                (append 
                 (get-all-field-types super-name tdecls)
                 (map (lambda (f) (parse-type (tfield-te f)))
                      fields))])))

(define find-in-tree
  (lambda (find-in-list extract)
    (lambda (name tdecl tdecls)
      (local [(define items (extract tdecl))
              (define super-name 
                (tclass-super-name tdecl))]
        (if (equal? super-name 'object)
            (find-in-list name items)
            (try (find-in-list name items)
                 (lambda ()
                   ((find-in-tree find-in-list extract)
                    name 
                    (find-tclass super-name tdecls)
                    tdecls))))))))

(define find-field-in-tree
  (find-in-tree find-tfield tclass-fields))

(define find-method-in-tree
  (find-in-tree find-tmethod tclass-methods))

(define (andmap2 f l1 l2)
  (cond
    [(and (empty? l1) (empty? l2)) true]
    [(and (cons? l1) (cons? l2))
     (and (f (first l1) (first l2))
          (andmap2 f (rest l1) (rest l2)))]
    [else false]))

(define (is-subclass? name1 name2 tdecls)
  (cond
    [(equal? name1 name2) true]
    [(equal? name1 'object) false]
    [else
     (type-case TDecl (find-tclass name1 tdecls)
       [tclass (name super-name fields methods)
               (is-subclass? super-name name2 tdecls)])]))

(define (is-subtype? t1 t2 tdecls)
  (type-case Type t1
    [objT (name1)
          (type-case Type t2 
            [objT (name2)
                  (is-subclass? name1 name2 tdecls)]
            [else false])]
    [else (equal? t1 t2)]))

(define typecheck-expr : (ICAE (listof TDecl) Type TDecl -> Type)
  (lambda (expr tdecls arg-type this-class)
    (local [(define (recur expr)
              (typecheck-expr expr tdecls arg-type this-class))]
      (type-case ICAE expr
        [inum (n) (numT)]
        [istr (s) (strT)]
        [iadd (l r)
              (type-case Type (recur l)
                [numT ()
                      (type-case Type (recur r)
                        [numT () (numT)]
                        [else (type-error r "num")])]
                [else (type-error l "num")])]
        [isub (l r)
              (type-case Type (recur l)
                [numT ()
                      (type-case Type (recur r)
                        [numT () (numT)]
                        [else (type-error r "num")])]
                [else (type-error l "num")])]
        [iif0 (test-expr then-expr else-expr)
              (type-case Type (recur test-expr)
                [numT ()
                      (local [(define then-type (recur then-expr))
                              (define else-type (recur else-expr))]
                        (cond
                          [(is-subtype? then-type else-type tdecls) else-type]
                          [(is-subtype? else-type then-type tdecls) then-type]
                          [else (type-error else-expr (to-string then-type))]))]
                [else (type-error test-expr "num")])]
        [iarg () arg-type]
        [ithis () (type-case TDecl this-class
                    [tclass (name super-name fields methods)
                            (objT name)])]
        [inew (class-name exprs)
              (local [(define arg-types (map recur exprs))]
                (if (andmap2 (lambda (t1 t2) 
                               (is-subtype? t1 t2 tdecls))
                             arg-types
                             (get-all-field-types class-name tdecls))
                    (objT class-name)
                    (type-error expr "field type mismatch")))]
        [iget (obj-expr field-name)
              (type-case Type (recur obj-expr)
                [objT (class-name)
                      (type-case TField (find-field-in-tree
                                         field-name
                                         (find-tclass class-name tdecls)
                                         tdecls)
                        [tfield (name te) (parse-type te)])]
                [else (type-error obj-expr "object")])]
        [isend (obj-expr method-name arg-expr)
               (local [(define obj-type (recur obj-expr))
                       (define arg-type (recur arg-expr))]
                 (type-case Type obj-type
                   [objT (class-name)
                         (typecheck-send class-name method-name
                                         arg-expr arg-type tdecls)]
                   [else
                    (type-error obj-expr "object")]))]
        [isuper (method-name arg-expr)
                (local [(define arg-type (recur arg-expr))]
                  (typecheck-send (tclass-super-name this-class)
                                  method-name
                                  arg-expr arg-type tdecls))]
        [instanceof (expr cl) (numT)])))) ;; TODO -- IMPLEMENT ME

(define (typecheck-send class-name method-name arg-expr arg-type tdecls)
  (type-case TMethod (find-method-in-tree
                      method-name
                      (find-tclass class-name tdecls)
                      tdecls)
    [tmethod (name arg-te result-te body-expr)
             (if (is-subtype? arg-type (parse-type arg-te) tdecls)
                 (parse-type result-te)
                 (type-error arg-expr (to-string (parse-type arg-te))))]))


(define (typecheck-method method this-tdecl tdecls)
  (type-case TMethod method
    [tmethod (name arg-te result-te body-expr)
             (if (is-subtype?
                  (typecheck-expr body-expr tdecls (parse-type arg-te) this-tdecl)
                  (parse-type result-te)
                  tdecls)
                 (values)
                 (type-error body-expr (to-string (parse-type result-te))))]))

(define (check-override method this-tdecl tdecls)
  (local [(define super-name 
            (tclass-super-name this-tdecl))
          (define super-method
            (try
             ;; Look for method in superclass:
             (find-method-in-tree (tmethod-name method)
                                  (find-tclass super-name tdecls)
                                  tdecls)
             ;; no such method in superclass:
             (lambda () method)))]
    (if (and (equal? (tmethod-arg-te method)
                     (tmethod-arg-te super-method))
             (equal? (tmethod-result-te method)
                     (tmethod-result-te super-method)))
        (values)
        (error 'typecheck (string-append
                           "bad override of "
                           (to-string method-name))))))

(define (typecheck tdecls expr)
  (begin
    (map (lambda (tdecl)
           (type-case TDecl tdecl
             [tclass (name super-name fields methods)
                     (map (lambda (m)
                            (begin
                              (typecheck-method m tdecl tdecls)
                              (check-override m tdecl tdecls)))
                          methods)]))
         tdecls)
    (typecheck-expr expr tdecls (numT) (tclass 'bad 'bad empty empty))))


(define (strip-types tdecl)
  (type-case TDecl tdecl
    [tclass (name super-name fields methods)
            (iclass 
             name 
             super-name
             (map (lambda (f)
                    (type-case TField f
                      [tfield (name te) (ifield name)]))
                  fields)
             (map (lambda (m)
                    (type-case TMethod m
                      [tmethod (name arg-te result-te body-expr)
                               (imethod name body-expr)]))
                  methods))]))

(define (tinterp tdecls expr)
  (iinterp (map strip-types tdecls)
           expr))

;; ----------------------------------------

(define tposnClass
  (tclass 'posn 'object
          (list (tfield 'x (numTE)) (tfield 'y (numTE)))
          (list (tmethod 'mdist (numTE) (numTE) 
                         (iadd (iget (ithis) 'x) (iget (ithis) 'y)))
                (tmethod 'addDist (objTE 'posn) (numTE)
                         (iadd (isend (ithis) 'mdist (inum 0))
                               (isend (iarg) 'mdist (inum 0)))))))

(define tposn3DClass 
  (tclass 'posn3D 'posn
          (list (tfield'z (numTE)))
          (list (tmethod 'mdist (numTE) (numTE)
                         (iadd (iget (ithis) 'z) 
                               (isuper 'mdist (iarg)))))))

(define tsquareClass 
  (tclass 'square 'object
          (list (tfield 'topleft (objTE 'posn)))
          (list)))

(define (tinterp-posn x)
  (tinterp (list tposnClass tposn3DClass)
           x))

(define (typecheck-posn x)
  (typecheck (list tposnClass tposn3DClass tsquareClass) 
             x))

(test (tinterp-posn (smdist smkPosn27))
      (numV 9))  
(test (tinterp-posn (smdist smkPosn531))
      (numV 9))
(test (tinterp-posn (saddDist smkPosn531 smkPosn27))
      (numV 18))
(test (tinterp-posn (saddDist smkPosn27 smkPosn531))
      (numV 18))  

(test (typecheck-posn (smdist smkPosn27))
      (numT))
(test (typecheck-posn (smdist smkPosn531))
      (numT))  
(test (typecheck-posn (saddDist smkPosn531 smkPosn27))
      (numT))  
(test (typecheck-posn (saddDist smkPosn27 smkPosn531))
      (numT))

(test (typecheck-posn (inew 'square (list (inew 'posn (list (inum 0) (inum 1))))))
      (objT 'square))
(test (typecheck-posn (inew 'square (list (inew 'posn3D (list (inum 0) (inum 1) (inum 3))))))
      (objT 'square))  

(test/exn (typecheck-posn (smdist (inum 10)))
          "no type")
(test/exn (typecheck (list tposnClass 
                           (tclass 'other 'posn
                                   (list)
                                   (list (tmethod 'mdist 
                                                  (objTE 'object) (numTE)
                                                  (inum 10)))))
                     (inum 10))
          "bad override")

(test (interp (num 0)
              empty
              (numV 0)
              (numV 0))
      (numV 0))

(test (interp (new 'simple empty)
              (list (class 'simple empty empty))
              (numV 0)
              (numV 0))
      (objV (class 'simple empty empty) empty))

(test (interp (get (new 'simple (list (num 12))) 'z)
              (list (class 'simple (list (field 'z)) empty))
              (numV 0)
              (numV 0))
      (numV 12))

(test (interp (dsend (new 'simple (list (num 12))) 'add (num 17))
              (list (class 'simple 
                      (list (field 'z))
                      (list (method 'add (add (get (this) 'z) (arg))))))
              (numV 0)
              (numV 0))
      (numV 29))

(define posn
  (tclass 'posn
          'object
          (list (tfield 'x (numTE)) 
                (tfield 'y (numTE)))
          (list (tmethod 'mdist
                         (numTE)
                         (numTE)
                         (iadd (iget (ithis) 'x)
                               (iget (ithis) 'y))))))

(define posn3D
  (tclass 'posn3D
          'posn
          (list (tfield 'z (numTE)))
          (list (tmethod 'mdist
                         (numTE)
                         (numTE)
                         (iadd (iget (ithis) 'z)
                               (isuper 'mdist (inum 0)))))))

(define animal
  (tclass 'animal
          'object
          (list (tfield 'name (strTE)) 
                (tfield 'weight (numTE)) 
                (tfield 'BirthYear (numTE)) 
                (tfield 'food (strTE)) 
                (tfield 'location (objTE 'posn3D)))
          (list (tmethod 'GetWeight
                         (numTE)
                         (numTE)
                         (iget (ithis) 'weight))
                (tmethod 'GetAge
                         (numTE)
                         (numTE)
                         (isub (iarg)
                               (iget (ithis) 'BirthYear))))))

(define snake
  (tclass 'snake
          'animal
          (list (tfield 'scales (strTE)))
          (list (tmethod 'GetScales
                         (strTE)
                         (strTE)
                         (iget (ithis) 'scales)))))

(define mkPosn3D_7_8_1
  (inew 'posn3D
        (list (inum 7) 
              (inum 8) 
              (inum 1))))

(define mksnake1
  (inew 'snake
        (list (istr "Johnny")
              (inum 2) 
              (inum 2000) 
              (istr  "rats")
              mkPosn3D_7_8_1
              (istr "dull"))))

(test (typecheck (list posn posn3D snake animal)
                 mksnake1)
      (objT 'snake))

(test (tinterp (list posn posn3D animal snake) (iget mksnake1 'scales))
      (strV "dull"))
(test (typecheck (list posn posn3D animal snake) (iget mksnake1 'scales))
      (strT))