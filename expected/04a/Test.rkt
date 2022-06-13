(require "Test-Harness.rkt")

(define V00/aa (make-posn 0 0))
(define V11/aa (make-posn 1 1))
(define V22/aa (make-posn 2 2))
(define V01/aa (make-posn 0 1))
(define V10/aa (make-posn 1 0))

(assert/equal V00/aa (vec-add V00/aa V00/aa) "Addition von (0, 0) und (0, 0)")
(assert/equal V22/aa (vec-add V11/aa V11/aa) "Addition von (1, 1) und (1, 1)")
(assert/equal V11/aa (vec-add V10/aa V01/aa) "Addition von (1, 0) und (0, 1)")

(tear-down)