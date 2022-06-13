;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname Assignment3-a-1) (read-case-sensitive #t) (teachpacks ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp")) #f)))
; InnererPlanet ist eins von
; - "merkur"
; - "venus"
; - "erde"
; - "mars"
; interp. einer der inneren Planeten unseres Sonnensystems

; InnererPlanet Number -> Number
; Compute the number of rotations that planet performs during d earth days

(check-within (rotationProErdtage "merkur" 1) 58.81 0.01)
(check-within (rotationProErdtage "venus" 1) 243.69 0.01)
(check-expect (rotationProErdtage "erde" 1) 1)
(check-within (rotationProErdtage "mars" 1) 1.07 0.01)

(define (rotationProErdtage planet d)
  (cond
    [(string=? planet "merkur") (* (/ 84456 1440) d)]
    [(string=? planet "venus") (* (/ 349947 1440) d)]
    [(string=? planet "erde") (* (/ 1436 1440) d)]
    [(string=? planet "mars") (* (/ 1537 1440) d)]))

(require racket/include) (include "Test.rkt")