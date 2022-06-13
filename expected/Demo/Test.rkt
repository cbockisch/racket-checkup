(require "Test-Harness.rkt")

(assert/equal 0 (double 0) "Das Doppelte von 0")
(assert/equal 2 (double 1) "Das Doppelte von 1")
(assert/equal -2 (double -1) "Das Doppelte von -1")
(assert/equal 42 (double 21) "Das Doppelte von 42")


(tear-down)