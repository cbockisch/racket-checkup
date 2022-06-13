(require "Test-Harness.rkt")

(assert/equal (list 7 5 3) (list-reverse (list 3 5 7)) "Umdrehen der Liste (list 3 5 7)")
(assert/equal (list 5 3) (list-reverse (list 3 5)) "Umdrehen der Liste (list 3 5)")
(assert/equal (list 3) (list-reverse (list 3)) "Umdrehen der Liste (list 3)")
(assert/equal '() (list-reverse '()) "Umdrehen der leeren Liste ")
(assert/equal (list false true) (list-reverse (list true false)) "Umdrehen der Liste (list true false)")

(tear-down)