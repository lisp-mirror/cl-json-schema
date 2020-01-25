#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.test.generation)

(parachute:define-test test-schema-resolvation
  :parent (:json-schema.test json-schema.test)

  (let* ((schema (find-schema (asdf:system-relative-pathname :json-schema.test
                                                             "test/schemas/event.yaml")))
         (produced-schema (produce-schema schema *schema-option*)))
    (v:debug :test-schema-resolvation "~w" produced-schema)
    (parachute:finish (eval produced-schema)))


  (let* ((schema (find-schema (asdf:system-relative-pathname
                               :json-schema.test
                               "test/schemas/sync_room_event.yaml")))

         (produced-schema (produce-schema schema *schema-option*)))
    (v:debug :test-schema-resolvation "~w" produced-schema)
    (parachute:finish (eval produced-schema)))

  (let* ((sample-sync-room-event-jsown
          '(:obj ("type" . "m.room.message")))
         (inherited-event
          (make-instance-from-json 'json-schema.test.generated::sync-room-event
                                   (jonathan:to-json sample-sync-room-event-jsown
                                                     :from :jsown))))
    (verbose:debug :test-schema-resolvation (jonathan:to-json inherited-event))
    (parachute:is #'equal sample-sync-room-event-jsown
                  (jonathan:parse (jonathan:to-json inherited-event) :as :jsown))))

(parachute:define-test test-ref-overrides
  :parent test-schema-resolvation

  (let* ((schema-option
         (make-instance 'mop-option
                        :package-designator (string-upcase "json-schema.test.room-event")
                        :ref-overrides '("sync_room_event")))

         (room-event-schema
          (find-schema (asdf:system-relative-pathname :json-schema.test
                                                      "test/schemas/room_event.yaml")))

         (produced-schema (produce-schema room-event-schema schema-option)))
    (v:debug :test-ref-overrides "~w" produced-schema)
    (parachute:finish (ensure-schema-class room-event-schema schema-option))))
