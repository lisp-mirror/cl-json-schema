#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

;;; bleh you're gonna have to check that postmodern is connected to a db or something.

(defpackage #:json-schema.test.postgres
  (:use #:cl #:json-schema #:json-schema.postgres)
  (:export #:run
           #:ci-run
           #:test-postgres))

(in-package #:json-schema.test.postgres)
(defpackage+-1:ensure-package
 (string-upcase "json-schema.test.postgres.room-event"))
(defpackage+-1:ensure-export '("ROOM-EVENT")
                             (find-package :json-schema.test.postgres.room-event))

(parachute:define-test test-postgres)
