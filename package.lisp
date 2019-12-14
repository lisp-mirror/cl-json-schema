;;;; package.lisp

(defpackage #:json-schema
  (:use #:cl)
  (:export
   #:json-serializable-class
   #:make-instance-from-json-using-serial
   #:make-instance-from-json

   ;; generation
   #:produce-schema
   #:class<-object
   #:slot<-property


   ;; resolving
   #:find-schema
   
   ))
