#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.test.postgres)

(parachute:define-test schema-creation
  :parent test-postgres

  (let* ((schema-option (make-instance 'json-schema.postgres::postgres-option
                                       :package-designator
                                       (string-upcase "json-schema.test.postgres.generated")
                                       :whitelist '("room_event")))
         (schema (find-schema (asdf:system-relative-pathname
                                      :json-schema.test
                                      "test/schemas/room_event.yaml")))
         (produced-schema (produce-schema schema schema-option)))
    (v:debug :schema-creation "~w" produced-schema)
    (parachute:finish (eval produced-schema))
    (parachute:finish (postmodern:execute
                       (postmodern:dao-table-definition
                        'json-schema.test.postgres.generated:room-event)))))
