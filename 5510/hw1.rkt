#lang plai

;; HOMEWORK 1
;; ALEX CLEMMER
;; u0458675


(define-type Tree
  [leaf (val number?)]
  [node (val number?)
        (left Tree?)
        (right Tree?)])

;; sum : Tree -> num
(define (sum t)
  (type-case Tree t
    [leaf (n) n]
    [node (n l r) (+ n (+ (sum l) (sum r)))]))

(test (sum (leaf 3)) 3)
(test (sum (node 3 (leaf 3) (leaf 3))) 9)
(test (sum (leaf 0)) 0)
(test (sum (leaf -1)) -1)
(test (sum (node -1 (leaf 2) (leaf 4))) 5)
(test (sum (node -1 (leaf 2) (node 4 (leaf 1) (node 2 (leaf 1) (leaf 2))))) 11)


;; negate : Tree -> Tree
(define (negate t)
  (type-case Tree t
    [leaf (n) (leaf (- 0 n))]
    [node (n l r) (node (- 0 n) (negate l) (negate r))]))
(test (negate (leaf 0)) (leaf 0))
(test (negate (node 1 (leaf 2) (leaf 3))) (node -1 (leaf -2) (leaf -3)))


;; contains? : Tree -> number -> boolean
(define (contains? t num)
  (type-case Tree t
    [leaf (n) (if (= n num) #t #f)]
    [node (n l r) (if (= n num) #t (or (contains? l num) (contains? r num)))]))
(test (contains? (leaf 0) 0) #t)
(test (contains? (leaf 0) 1) #f)
(test (contains? (node 0 (leaf 1) (leaf 2)) 1) #t)
(test (contains? (node 0 (leaf 1) (leaf 2)) 3) #f)


;; big-leaves? : Tree -> boolean
; NOTE: if there is exactly one node, then we assume that the total of all
; previous nodes is 0. Thus, if the tree has 1 node and that node is smaller
; than 1, we return #f.
(define (big-leaves? t)
  (define (foldleaves t c)
    (type-case Tree t
      [leaf (n) (if (> n c) #t #f)]
      [node (n l r) (and (foldleaves l (+ c n)) (foldleaves r (+ c n)))]))
  (foldleaves t 0))
(test (big-leaves? (leaf 0)) #f)
(test (big-leaves? (leaf -1)) #f)
(test (big-leaves? (node -1 (leaf 0) (leaf 0))) #t)
(test (big-leaves? (node 0 (leaf 0) (leaf 0))) #f)
(test (big-leaves? (node 1 (leaf 2) (leaf 2))) #t)
(test (big-leaves? (node 1 (leaf 1) (leaf 2))) #f)


;; sorted? : Tree -> boolean
(define (sorted? t)
  (define (foldl t c)
    (type-case Tree t
      [leaf (n) (>= n c)]
      [node (n l r) (and (>= n c) (and (foldl l (+ n c)) (foldl r (+ n c))))]))
  (type-case Tree t
    [leaf (n) #t]
    [node (n l r) (foldl t n)]))
(test (sorted? (leaf 0)) #t)
(test (sorted? (node 0 (leaf 1) (leaf 2))) #t)
(test (sorted? (node 1 (leaf 0) (leaf 2))) #f)