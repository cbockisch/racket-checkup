(require "Test-Harness.rkt")

(assert/equal 5 (max3 1 3 5) "Maximium von 1, 3, 5")
(assert/equal 5 (max3 1 5 3) "Maximium von 1, 5, 3")
(assert/equal 5 (max3 3 1 5) "Maximium von 3, 1, 5")
(assert/equal 5 (max3 3 5 1) "Maximium von 3, 5, 1")
(assert/equal 5 (max3 5 1 3) "Maximium von 5, 1, 3")
(assert/equal 5 (max3 5 3 1) "Maximium von 5, 3, 1")
(assert/equal 0 (max3 0 0 0) "Maximium von 0, 0, 0")

(tear-down)