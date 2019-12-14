#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.test.generation)

(parachute:define-test test-schema-resolvation

    (let* ((schema (find-schema (asdf:system-relative-pathname :json-schema.test
                                                               "test/schemas/event.yaml")))
           (produced-schema (produce-schema schema *schema-option*)))
    (v:debug :test-schema-resolvation "~w" produced-schema)
    (parachute:finish (eval produced-schema))))
