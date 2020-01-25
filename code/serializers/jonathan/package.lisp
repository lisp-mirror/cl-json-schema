#|
    Copyright (C) 2020 Gnuxie <Gnuxie@protonmail.com>
|#

(defpackage #:json-schema.jonathan
  (:use #:cl #:json-schema)
  (:export
   ;; macros
   #:within-object
   #:with-object
   ;; protocol
   #:serialize-slot
   #:create-encoder
   #:create-serializer
   ;; jonathan
   #:key-normalizer
   ))
(in-package #:json-schema.jonathan)
