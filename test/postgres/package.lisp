#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(defpackage #:json-schema.test.postgres
  (:use #:cl #:json-schema #:json-schema.schema #:json-schema.postgres)
  (:export #:run
           #:ci-run
           #:test-postgres))

(in-package #:json-schema.test.postgres)
(defpackage+-1:ensure-package
 (string-upcase "json-schema.test.postgres.generated"))
(defpackage+-1:ensure-export '("ROOM-EVENT")
                             (find-package :json-schema.test.postgres.generated))

(parachute:define-test test-postgres)
