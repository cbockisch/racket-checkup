;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname Assignment4-d-1) (read-case-sensitive #t) (teachpacks ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp")) #f)))
; ein Vektor ist eine struktur: (make-posn Number Number)
; interp. der Vektor vom Ursprung zu der angegebenen Position.

;BEISPIELE
(define V01 (make-posn 0 1 ))
(define V10 (make-posn 1 0 ))

; Vektor -> Vektor
; Berechnet den normierten Vektor für v

(check-expect (vec-norm V01) V01)

(define (vec-norm v)
  (make-posn 
   (/ (posn-x v) (sqrt (+ (sqr (posn-x v)) (sqr (posn-y v)))))
   (/ (posn-y v) (sqrt (+ (sqr (posn-x v)) (sqr (posn-y v)))))))