#|
    Copyright (C) 2020 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.test.generation)

(parachute:define-test test-anon-schemas
  :parent (:json-schema.test json-schema.test)

  (let* ((schema-option
          (make-instance 'mop-option
                         :package-designator (symbol-name :json-schema.test.anon-schemas)))

         (open-api-schema
          (find-schema (asdf:system-relative-pathname :json-schema.test
                                                      "test/schemas/create_room.yaml")))
         
         (anon-schema
          (make-instance 'json-schema.schema:named-schema :name "body"
                         :object
                         (gethash "schema"
                                  (car
                                   (json-schema.schema:hash-filter
                                    (json-schema.schema:object open-api-schema)
                                    "paths"
                                    "/createRoom"
                                    "post"
                                    "parameters")))))

         (produced-schema (produce-schema anon-schema schema-option)))
    (v:debug :anon-schema "~w" produced-schema)
    (parachute:finish (ensure-schema-class anon-schema schema-option)))

  (let* ((schema-option
          (make-instance 'mop-option
                         :package-designator (symbol-name :json-schema.test.anon-schemas)))

         (inner-anon-schema
          (find-schema (asdf:system-relative-pathname :json-schema.test
                                                      "test/schemas/unsigned_pdu.yaml")))

         (produced-schema (produce-schema inner-anon-schema schema-option)))
    (v:debug :anon-schema "~w" produced-schema)
    (parachute:finish (ensure-schema-class inner-anon-schema schema-option))
    (parachute:true (< 0 (length (c2mop:class-direct-slots
                                   (find-class 'json-schema.test.anon-schemas::unsigned-pdu))))
                  "Should be some direct slots from the yaml schema.")))
