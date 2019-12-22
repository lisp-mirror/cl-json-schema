;;;; package.lisp

(defpackage #:json-schema
  (:use #:cl)
  (:export
   #:json-serializable-class
   #:make-instance-from-json-using-serial
   #:make-instance-from-json

   ;; utils
   #:with-hash-keys
   #:symbol<-key
   #:do-referenced-schemas
   

   ;; mop option
   #:mop-option
   #:package-prefix
   #:target-package
   #:whitelist
   #:ref-overrides
   
   ;; generation
   #:produce-schema
   #:class<-object
   #:slot<-property
   #:ensure-schema-class
   #:class-options<-schema


   ;; schema
   #:find-schema
   #:schema
   #:schema-name<-uri
   #:name
   #:find-schema-from-file
   #:object
   #:uri
   ))
