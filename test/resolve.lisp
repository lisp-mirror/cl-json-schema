#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.test.generation)

(define-test test-schema-resolvation

  (multiple-value-bind (schema name)
      (find-schema
       (asdf:system-relative-pathname :json-schema.test "test/schemas/event.yaml"))
    (let ((produced-schema (produce-schema name schema *schema-option*)))
      (v:debug :test-schema-resolvation "~w" produced-schema)
      (finish (eval produced-schema)))))
