;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname Assignment1-4) (read-case-sensitive #t) (teachpacks ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #t #t none #f ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp")) #f)))
; Number -> Number
; Addiert die Zahlen von 1 bis n auf
(define (sum n)
  (/ (* n (+ n 1)) 2))

(define (sum/rek n)
  (if (= n 0)
      0
      (+ n (sum/rek (- n 1)))))
      


(define (sum2 a b)
  ;interference
  5)


(sum 10)