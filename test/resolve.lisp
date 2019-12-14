#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.test)

(define-test test-schema-resolvation

  (multiple-value-bind (schema name)
      (find-schema
       (asdf:system-relative-pathname :json-schema.test "test/schemas/event.yaml"))
    (let ((produced-schema (produce-schema name schema :mop)))
      (v:debug :test-schema-resolvation "~w" produced-schema)
      (finish (eval produced-schema)))))
