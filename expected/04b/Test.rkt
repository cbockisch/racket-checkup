(require "Test-Harness.rkt")

(define V00/aa (make-posn 0 0))
(define V11/aa (make-posn 1 1))
(define V22/aa (make-posn 2 2))
(define V01/aa (make-posn 0 1))
(define V10/aa (make-posn 1 0))

(assert/equal V00/aa (vec-sub V00/aa V00/aa) "Subtraktion (0, 0) minus (0, 0)")
(assert/equal V11/aa (vec-sub V22/aa V11/aa) "Subtraktion (2, 2) minus (1, 1)")
(assert/equal V01/aa (vec-sub V11/aa V10/aa) "Subtraktion (1, 1) minus (1, 0)")

(tear-down)