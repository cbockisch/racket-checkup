(require "Test-Harness.rkt")

(define (within/aa actual expected delta)
  (< (- expected delta) actual (+ expected delta)))

(assert/true (within/aa (rotationProErdtage "merkur" 1) 58.81 0.01) "Rotationen für merkur an einem Erdtag (erwartet 58.85 +/- 0.01)")
(assert/true (within/aa (rotationProErdtage "venus" 1) 243.69 0.01) "Rotationen für venus an einem Erdtag (erwartet 243.69 +/- 0.01)")
(assert/true (= (rotationProErdtage "erde" 1) 1) "Rotationen für erde an einem Erdtag (erwartet 1)")
(assert/true (within/aa (rotationProErdtage "mars" 1) 1.07 0.01) "Rotationen für mars an einem Erdtag (erwartet 1.07 +/- 0.01)")

(tear-down)