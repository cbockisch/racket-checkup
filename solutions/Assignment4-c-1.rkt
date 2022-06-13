;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname Assignment4-c-1) (read-case-sensitive #t) (teachpacks ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp")) #f)))
; ein Vektor ist eine struktur: (make-posn Number Number)
; interp. der Vektor vom Ursprung zu der angegebenen Position.

;BEISPIELE
(define V00 (make-posn 0 0 ))
(define V01 (make-posn 0 1 ))
(define V10 (make-posn 1 0 ))
(define V11 (make-posn 1 1 ))

; Vektor Number -> Vektor
; Berechnet einen neuen Vektor durch
; komponentenweise Skalarmultiplikation von v und s

(check-expect (vec-skal-mult V00 V00) V00)

(define (vec-skal-mult v s)
  (make-posn (* (posn-x v) s)
             (* (posn-y v) s)))
