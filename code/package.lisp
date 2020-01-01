;;;; package.lisp

(defpackage #:json-schema
  (:use #:cl #:json-schema.schema)
  (:export
   #:json-serializable-class
   #:json-serializable
   #:make-instance-from-json-using-serial
   #:make-instance-from-json

   ;; mop option
   #:mop-option
   #:package-designator
   #:target-package
   #:whitelist
   #:ref-overrides
   #:json-key-name
   
   ;; generation
   #:produce-schema
   #:class<-object
   #:slot<-property
   #:ensure-schema-class
   #:class-options<-schema
   #:generate-utility-methods
   ))
