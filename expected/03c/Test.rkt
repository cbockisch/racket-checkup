(require "Test-Harness.rkt")

(assert/equal "20" (romeOrNumber->String 20) "String für die arabische Zahl 20")
(assert/equal "I" (romeOrNumber->String "I") "String für die römische Zahl I")

(tear-down)