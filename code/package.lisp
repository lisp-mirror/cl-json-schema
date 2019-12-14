;;;; package.lisp

(defpackage #:json-schema
  (:use #:cl)
  (:export
   #:json-serializable-class
   #:make-instance-from-json-using-serial
   #:make-instance-from-json

   ;; mop option
   #:mop-option
   #:package-prefix
   #:target-package
   
   ;; generation
   #:produce-schema
   #:class<-object
   #:slot<-property


   ;; resolving
   #:find-schema
   
   ))
