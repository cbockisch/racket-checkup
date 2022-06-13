(require "Test-Harness.rkt")

(assert/equal (list 1 2 3 4 5) (list-flat (list (list 1) 2 (list (list 3 4) 5) (list (list empty)))) "Flachklopfen der Liste (list (list 1) 2 (list (list 3 4) 5) (list (list empty)))")
(assert/equal (list true false) (list-flat (list true false)) "Flachklopfen der Liste (list true false)")
(assert/equal '() (list-flat '()) "Flachklopfen der leeren Liste")

(tear-down)