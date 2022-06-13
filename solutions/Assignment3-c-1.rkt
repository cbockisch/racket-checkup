;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname Assignment3-c-1) (read-case-sensitive #t) (teachpacks ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp")) #f)))
; RomeOrArabic ist eins von
; - Number
; - String, der eine römische Zahl kodiert
; interp. eine Zahl, entweder als normale Zahl oder als römische Zahl kodiert

; RomeOrArabic -> String
; Gibt eine String repräsentation von ron zurück

(check-expect (romeOrNumber->String 20) "20")
(check-expect (romeOrNumber->String "I") "I")


(define (romeOrNumber->String ron)
  (cond
    [(number? ron) (number->string ron)]
    [(string? ron) ron]))
