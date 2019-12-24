#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(defpackage #:json-schema.test
  (:use #:cl #:json-schema #:json-schema.schema)
  (:export
   #:json-schema.test
   #:run
   #:ci-run))

(in-package #:json-schema.test)

(parachute:define-test json-schema.test:json-schema.test)
