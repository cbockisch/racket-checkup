(require "Test-Harness.rkt")

(assert/equal (list 3 7) (list-remove 5 (list 3 5 7)) "Entfernen von 5 aus (list 3 5 7)")
(assert/equal (list 5 7) (list-remove 3 (list 3 5 7)) "Entfernen von 3 aus (list 3 5 7)")
(assert/equal (list 3 5) (list-remove 7 (list 3 5 7)) "Entfernen von 7 aus (list 3 5 7)")
(assert/equal (list 3 5 7) (list-remove 0 (list 3 5 7)) "Entfernen von 0 aus (list 3 5 7)")
(assert/equal '() (list-remove 0 '()) "Entfernen von 0 aus der leeren Liste")


(tear-down)