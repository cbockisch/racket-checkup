(require "Test-Harness.rkt")

(define V00/aa (make-posn 0 0))
(define V11/aa (make-posn 1 1))
(define V22/aa (make-posn 2 2))
(define V01/aa (make-posn 0 1))
(define V10/aa (make-posn 1 0))

(assert/equal V00/aa (vec-skal-mult  V00/aa 0) "Skalarmultiplikation von (0, 0) mit 0")
(assert/equal V00/aa (vec-skal-mult  V00/aa 1) "Skalarmultiplikation von (0, 0) mit 1")
(assert/equal V00/aa (vec-skal-mult  V11/aa 0) "Skalarmultiplikation von (1, 1) mit 0")
(assert/equal V22/aa (vec-skal-mult  V11/aa 2) "Skalarmultiplikation von (1, 1) mit 2")

(tear-down)