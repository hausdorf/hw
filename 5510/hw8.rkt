# QUESTION 1:

interp
  a-fae: (app (fun 'x (add (id 'x) (num 1))) (sub (num 3) (num 2)))
  ds: (mtSub)
  k: (mtK)
interp
  a-fae: (fun 'x (add (id 'x) (num 1)))
  ds: (mtSub)
  k: (appArgK (sub (num 3) (num 2)) (mtSub) (mtK))
continue
  k: (appArgK (sub (num 3) (num 2)) (mtSub) (mtK))
  v: (closureV 'x (add (id 'x) (num 1)) (mtSub))
interp
  a-fae: (sub (num 3) (num 2))
  ds: (mtSub)
  k: (doAppK (closureV 'x (add (id 'x) (num 1)) (mtSub)) (mtK))
interp
  a-fae: (num 3)
  ds: (mtSub)
  k: (subSecondK (num 2) (mtSub) (doAppK (closureV 'x (add (id 'x) (num 1)) (mtSub)) (mtK)))
continue
  k: (subSecondK (num 2) (mtSub) (doAppK (closureV 'x (add (id 'x) (num 1)) (mtSub)) (mtK)))
  v: (numV 3)
interp
  a-fae: (num 2)
  ds: (mtSub)
  k: (doSubK (numV 3) (doAppK (closureV 'x (add (id 'x) (num 1)) (mtSub)) (mtK)))
continue
  k: (doSubK (numV 3) (doAppK (closureV 'x (add (id 'x) (num 1)) (mtSub)) (mtK)))
  v: (numV 2)
continue
  k: (doAppK (closureV 'x (add (id 'x) (num 1)) (mtSub)) (mtK))
  v: (numV 1)
interp
  a-fae: (add (id 'x) (num 1))
  ds: (aSub 'x (numV 1) (mtSub))
  k: (mtK)
interp
  a-fae: (id 'x)
  ds: (aSub 'x (numV 1) (mtSub))
  k: (addSecondK (num 1) (aSub 'x (numV 1) (mtSub)) (mtK))
continue
  k: (addSecondK (num 1) (aSub 'x (numV 1) (mtSub)) (mtK))
  v: (numV 1)
interp
  a-fae: (num 1)
  ds: (aSub 'x (numV 1) (mtSub))
  k: (doAddK (numV 1) (mtK))
continue
  k: (doAddK (numV 1) (mtK))
  v: (numV 1)
continue
  k: (mtK)
  v: (numV 2)



# QUESITON 2

Initial values are:
     register: 6
     to-space:   1  0  9  1  3  0  2  8  0  3  1  1  3  7  7
    addresses:  00 01 02 03 04 05 06 07 08 09 10 11 12 13 14
   from-space:   2  8  3  1  0  0  0  0  0  0  0  0  0  0  0
     register: 3             ^
