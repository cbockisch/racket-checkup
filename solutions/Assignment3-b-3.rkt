;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname Assignment3-b-3) (read-case-sensitive #t) (teachpacks ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp")) #f)))
(define KLEINKIND 120)
(define KIND 140)

; Besucher ist ein Number und fällt in eines der Intervalle
; - von 0 bis KLEINKIND
; - größer als 120 und <= KIND
; - größer als 140
; interp. ein Besucher in der Größe in cm, unterteilt in Intervalle entsprechend der Preisklassen

; Besucher -> Number
; Gib den Eintrittspreis für den Besucher b zurück

(check-expect (preis 0) 0)
(check-expect (preis (/ KLEINKIND 2)) 0)
(check-expect (preis KLEINKIND) 0)

(check-expect (preis (+ KLEINKIND 1)) 12)
(check-expect (preis (+ KLEINKIND (/ (- KIND KLEINKIND) 2))) 12)
(check-expect (preis KIND) 12)

(check-expect (preis (+ KIND 1)) 15)
(check-expect (preis 183) 15)

; Besucher ist ein Number und fällt in eines der Intervalle
; - von 0 bis KLEINKIND
; - größer als 120 und <= KIND
; - größer als 140
; interp. ein Besucher in der Größe in cm, unterteilt in Intervalle entsprechend der Preisklassen

(define (preis b)
  (cond
    [(<= 0 b KLEINKIND) 0]
    [(and (< KLEINKIND b) ( < b KIND)) 12]
    [(<= KIND b) 15]))

