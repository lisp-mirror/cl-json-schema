#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(defpackage #:json-schema.postgres
  (:use #:cl #:json-schema #:json-schema.schema)
  (:export #:json-store-class
           #:json-store-slot))
