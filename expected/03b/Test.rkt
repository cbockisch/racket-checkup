(require "Test-Harness.rkt")

(assert/equal 0 (preis 0) "Eintrittspreis für Person mit 0cm.")
(assert/equal 0 (preis 60) "Eintrittspreis für Person mit 60cm.")
(assert/equal 0 (preis 120) "Eintrittspreis für Person mit 120cm.")

(assert/equal 12 (preis 121) "Eintrittspreis für Person mit 121cm.")
(assert/equal 12 (preis 130) "Eintrittspreis für Person mit 130cm.")
(assert/equal 12 (preis 140) "Eintrittspreis für Person mit 140cm.")

(assert/equal 15 (preis 141) "Eintrittspreis für Person mit 141cm.")
(assert/equal 15 (preis 183) "Eintrittspreis für Person mit 183cm.")

(tear-down)