#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

;;; bleh you're gonna have to check that postmodern is connected to a db or something.

(defpackage #:json-schema.test.postgres
  (:use #:cl #:json-schema #:json-schema.postgres))

(in-package #:json-schema.test.postgres)
