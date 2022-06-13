(module Test-Harness racket
  (provide (all-defined-out))

  (require racket/format)

  (define test-results-file "test-out.txt")
  
  (define out (open-output-file test-results-file #:mode 'binary #:exists 'replace))

  (define (fprintln text)
    (fprintf out (string-append text "\n")))
  
  (define (assert/true predicate message)
    (if (not predicate)
        (fprintln message)
        void
        ))

  (define (assert/equal expected actual message)
    (if (not (equal? expected actual))
        (fprintln (string-append message " Erwartet: " (~a expected) " Tatsächlicher Wert: " (~a actual)))
        void
        ))

  (define (tear-down) (close-output-port out))
  )