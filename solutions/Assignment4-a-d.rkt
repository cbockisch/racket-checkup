;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname Assignment4-a-d) (read-case-sensitive #t) (teachpacks ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp")) #f)))
; ein Vektor ist eine struktur: (  make-posn      Number Number)
; interp. der Vektor vom Ursprung zu der angegebenen Position.

(define V00 (make-posn 0 0 ))
(define V01 (make-posn 0 1 ))
(define V10 (make-posn 1 0 ))
(define V11 (make-posn 1 1 ))

; Vektor Vektor -> Vektor
; Berechnet einen neuen Vektor durch
; komponentenweise Addition von v1 und v2

(check-expect (vec-add V00 V00) V00)

(define (vec-add v1 v2)
  (make-posn (+ (posn-x v1) (posn-x v2))
             (+ (posn-y v1) (posn-y v2))))

; Vektor Vektor -> Vektor
; Berechnet einen neuen Vektor durch
; komponentenweise Subtraktion von v1 und v2

(check-expect (vec-sub V00 V00) V00)

(define (vec-sub v1 v2)
  (make-posn (- (posn-x v1) (posn-x v2))
             (- (posn-y v1) (posn-y v2))))
; Vektor Number -> Vektor
; Berechnet einen neuen Vektor durch
; komponentenweise Skalarmultiplikation von v und s

(check-expect (vec-skal-mult V00 1) V00)

(define (vec-skal-mult v s)
  (make-posn (* (posn-x v) s)
             (* (posn-y v) s)))

; Vektor -> Vektor
; Berechnet den normierten Vektor für v

(check-expect (vec-norm V01) V01)

(define (vec-norm v)
  (make-posn 
   (/ (posn-x v) (sqrt (+ (sqr (posn-x v)) (sqr (posn-y v)))))
   (/ (posn-y v) (sqrt (+ (sqr (posn-x v)) (sqr (posn-y v)))))))