;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname Untitled) (read-case-sensitive #t) (teachpacks ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp")) #f)))
(check-expect (first
               (farbe->grau "Lachsrosa" 250 128 114))
              "Lachsrosa")
(check-expect (second
               (farbe->grau "Lachsrosa" 250 128 114))
              "-")
(check-expect (third
               (farbe->grau "Lachsrosa" 250 128 114))
              "162")

(define (farbe->grau name r g b)
`(,name
  "-" 
  ,(number->string (floor(+(* 0.299 r) (* 0.587 g) (* 0.114 b))))))