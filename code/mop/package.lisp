#|
    Copyright (C) 2020 Gnuxie <Gnuxie@protonmail.com>
|#

(defpackage #:json-schema.mop
  (:use #:cl)
  (:export
   ;; protocol
   #:compute-slot-precedence-list
   #:slot-precedence-list
   #:json-key-name
   #:make-instance-from-json
   ;; metaclass
   #:json-serializable
   #:json-serializable-class
   #:json-serializable-slot
   #:json-type
   
))
