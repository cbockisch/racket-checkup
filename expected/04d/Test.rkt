(require "Test-Harness.rkt")

(define V01/aa (make-posn 0 1))
(define V10/aa (make-posn 1 0))
(define V34/aa (make-posn 3 4))
(define V34norm/aa (make-posn (/ 3 5) (/ 4 5)))

(assert/equal V10/aa (vec-norm V10/aa) "Normierter Vektor (1, 0)")
(assert/equal V01/aa (vec-norm V01/aa) "Normierter Vektor (0, 1)")
(assert/equal V34norm/aa (vec-norm V34/aa) "Normierter Vektor (3, 4)")


(tear-down)