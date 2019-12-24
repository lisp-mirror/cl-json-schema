#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(defpackage #:json-schema.schema
  (:use #:cl)
  (:export
   ;; utils.lisp
   #:%symbol<-key
   #:symbol<-key
   #:keyword<-key
   #:with-hash-keys
   #:do-referenced-schemas
   ;; schema.lisp
   #:schema
   #:object
   #:uri-schema
   #:uri
   #:name
   #:named-schema
   #:make-load-form
   #:find-schema
   #:schema-name<-uri
   #:internal-name
   #:relative-schema
   ))

(in-package #:json-schema.schema)