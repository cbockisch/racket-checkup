;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname AllForms) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp") (lib "batch-io.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp") (lib "batch-io.rkt" "teachpack" "2htdp")) #f)))
;comment CONSTANT
(define CONSTANT 2)
; comment function
(define (function x y) x)
; comment struct
(define-struct STRUCT (f1 f2))
; comment literal
1
; comment simple exression
(+ 2 3)
; comment complex expression
(* (+ 4 5) (+ 6 7))
; comment lambda
(lambda (u v) u)
; comment lambda2
(λ (w z) z)
; cond expression
(cond [true 8] [false 9] [else 10])