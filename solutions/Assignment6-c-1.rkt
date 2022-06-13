;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname Assignment6-c-1) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
; [X] Nested-List-of X is one of:
; - X
; - (list-of (Nested-List-of X))

; [ x ] (nested-List-of  X) -> (list-of X)
; Gibt eine Liste mit den primitiven Elementen aus l zurück
(check-expect (list-flat (list (list 1) 2 (list (list 3 4) 5) (list (list empty)))) (list 1 2 3 4 5))
(check-expect (list-flat (list "a" "b")) (list "a" "b"))
(check-expect (list-flat '()) '())

(define (list-flat l)
  (cond [(empty? l) empty]
        [else (cond [(cons? (first l)) (append (list-flat (first l)) (list-flat (rest l)))]
                    [(empty? (first l)) empty]
                    [else (append (list (first l)) (list-flat (rest l)))])
              ]))
