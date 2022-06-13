;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname Assignment6-b-1) (read-case-sensitive #t) (teachpacks ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp")) #f)))
; [ X ] ( list-of  X ) -> ( list-of X )
; Gibt die eine Liste mit den Elementen aus l in umgekehrter Reihenfolge zurück
(check-expect (list-reverse (list 3 5 7)) (list 7 5 3))
(check-expect (list-reverse (list 3 5)) (list 5 3))
(check-expect (list-reverse (list 3)) (list 3))
(check-expect (list-reverse '()) '())

(define (list-reverse l)
  (cond [(empty? l) empty]
        [else (append (list-reverse (rest l)) (list (first l)))]))


