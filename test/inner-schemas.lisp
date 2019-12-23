#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.test.generation)

(parachute:define-test test-inner-schema
  :parent (:json-schema.test json-schema.test)

  (let* ((schema-option (make-instance 'mop-option
                                       :whitelist '("state_event" "m.room.create")
                                       :package-designator (string-upcase "json-schema.test.inner-schema")))

         (schema
         (find-schema
          (asdf:system-relative-pathname :json-schema.test
                                         "test/schemas/m.room.create.yaml")))
         (produced-schema (produce-schema schema schema-option)))
    (v:debug :test-inner-schema "~w" produced-schema)
    (parachute:finish (eval produced-schema))))
