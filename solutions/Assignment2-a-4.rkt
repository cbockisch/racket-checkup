;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname Assignment2-a-4) (read-case-sensitive #t) (teachpacks ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp")) #f)))
; Number Number Number -> Number
; compute the maximum of a, b and c
(check-expect (max3 1 3 5) 5)
(check-expect (max3 1 5 3) 5)
(check-expect (max3 3 1 5) 5)
(check-expect (max3 3 5 1) 5)
(check-expect (max3 5 1 3) 5)
(check-expect (max3 5 3 1) 5)
(define (max3 a b c)
  (if (> a b)
      a
      b))