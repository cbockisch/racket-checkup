;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname Assignment6-a-1) (read-case-sensitive #t) (teachpacks ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp")) #f)))
(define L1 (list 3 5 7))
(define (helper x) x)

; [ X ] X ( list-of  X ) -> ( list-of X )
; Gibt eine List zurück, die l ohne e entspricht
(check-expect (list-remove 5 (list 3 5 7)) (list 3 7))
(check-expect (list-remove 3 (list 3 5 7)) (list 5 7))
(check-expect (list-remove 7 (list 3 5 7)) (list 3 5))
(check-expect (list-remove 0 (list 3 5 7)) (list 3 5 7))
(check-expect (list-remove 0 '()) '())

(define (list-remove e l)
  (cond [(empty? l) empty]
        [else (if (equal? (first l) e)
                  (list-remove e (rest l))
                  (cons (first l) (list-remove e (rest l))))]))

