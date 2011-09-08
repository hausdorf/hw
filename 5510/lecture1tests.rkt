#lang plai
(define-type Posn
  [posn (x number?)
        (y number?)])

(define (flip p)
  (type-case Posn p
    [posn (x y) (posn y x)]))
(test (flip (posn 1 17)) (posn 17 1))
(test (flip (posn -3 4)) (posn 4 -3))

(define-type Ant
  [ant (location Posn?)
       (weight number?)])

(define (ant-at-home? a)
  (define (is-home? p)
    (type-case Posn p
      [posn (x y) (if (and (= 0 x) (= 0 y))
            #t
            #f)]))
  (type-case Ant a
    [ant (l w) (is-home? l)]))
(test (ant-at-home? (ant (posn 0 0) 0.0001)) #t)
(test (ant-at-home? (ant (posn 5 10) 0.0001)) #f)

(define-type Animal
  [snake (name symbol?)
         (weight number?)
         (food symbol?)]
  [tiger (name symbol?)
         (stripe-count number?)])

(define (heavy-animal? a)
  (define (heavy? w) (if (>= w 10) #t #f))
  (type-case Animal a
    [snake (n w f) (heavy? w)]
    [tiger (n sc) #t]))
(test (heavy-animal? (snake 'Slinky 10 'rats)) #t)
(test (heavy-animal? (snake 'Slimey 8 'cake)) #f)
(test (heavy-animal? (tiger 'Tony 14)) #t)

(define (eat-cookie n)
  (if (> n 0)
      (- n 1)
      0))
(test (eat-cookie 10) 9)
(test (eat-cookie 0) 0)

(define (feed-fish l)
  (cond
    [(empty? l) '()]
    [(cons? l) (map add1 l)]))
(test (feed-fish '()) '())
(test (feed-fish '(1 2 3)) '(2 3 4))

(define (feed-fishb l)
  (cond
    [(empty? l) '()]
    [(cons? l)
     (cons (+ (first l) 1)
           (feed-fish (rest l)))]))
(test (feed-fishb '()) '())
(test (feed-fishb '(1 2 3)) '(2 3 4))

(define-type GUI
  [label (text string?)]
  [button (text string?)
          (enabled? boolean?)]
  [choice (items (listof string?))
          (selected integer?)])

(define (read-screen g)
  (type-case GUI g
    [label (t) (list t)]
    [button (t e?) (list t)]
    [choice (i s) i]))
(test (read-screen (label "Hi")) '("Hi"))
(test (read-screen (button "Ok" true)) '("Ok"))
(test (read-screen (choice '("Apple" "Banana") 0)) '("Apple" "Banana"))