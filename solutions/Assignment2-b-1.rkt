;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname Assignment2-b-1) (read-case-sensitive #t) (teachpacks ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "abstraction.rkt" "teachpack" "2htdp")) #f)))
; Number -> String
; compute the roman numeral for the given num
(check-expect (rome 1) "I")
(check-expect (rome 2) "II")
(check-expect (rome 3) "III")
(check-expect (rome 4) "IV")
(check-expect (rome 5) "V")
(check-expect (rome 6) "VI")
(check-expect (rome 7) "VII")
(check-expect (rome 8) "VIII")
(check-expect (rome 9) "IX")
(define (rome num)
     (cond
       [(< num 1) "Nicht implementiert"]
       [(<= num 3) (replicate num "I")]
       [(= num 4) "IV"]
       [(<= num 8) (string-append "V" (replicate (- num 5) "I"))]
       [(= num 9) "IX"]
       [else "Nicht implementiert"]))