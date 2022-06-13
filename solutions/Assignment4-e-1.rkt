;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname Assignment4-a-1) (read-case-sensitive #t) (teachpacks ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp")) #f)))
; ein Vektor ist eine struktur: (make-posn Number Number)
; interp. der Vektor vom Ursprung zu der angegebenen Position.

;BEISPIELE
(define V00 (make-posn 0 0 ))
(define V01 (make-posn 0 1 ))
(define V10 (make-posn 1 0 ))
(define V11 (make-posn 1 1 ))

; Posn Posn -> Posn
; Berechnet einen neuen Vektor durch
; komponentenweise Addition von v1 und v2

(check-expect (vec-add V00 V00) Voo)

; VERWENDUNG der Beispiele

(define (vec-add v1 v2)
  (make-posn (+ (posn-x v1) (posn-x v2))
             (+ (posn-y v1) (posn-y v2))))

; SCHABLONE: posn-x für v1, v2 ... für alle Selektoren