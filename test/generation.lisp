#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.test.generation)

(defvar *schema-option*
  (make-instance 'mop-option :package-designator "JSON-SCHEMA.TEST.GENERATED"))

(parachute:define-test test-produce-class
  :parent (:json-schema.test json-schema.test)

  (let* ((sample-schema-jsown
         '(:OBJ ("type" . "object")
           ("properties" :OBJ ("house_number" :OBJ ("type" . "number"))
            ("street_name" :OBJ ("type" . "string"))
            ("street_type" :OBJ ("type" . "string")
             ("enum" "Street" "Avenue" "Boulevard")))
           ("additionalProperties")))
         (sample-schema-json (jsown:to-json sample-schema-jsown))
         (sample-schema (make-instance 'schema :uri #P"address" :object (yaml:parse sample-schema-json)))
         (produced-schema (produce-schema sample-schema *schema-option*)))
    (verbose:debug :test-produce-class "~w" produced-schema)
    (parachute:finish (eval produced-schema)))

  (let* ((address-jsown '(:obj ("house_number" . 13)
                          ("street_name" . "long road")
                          ("street_type" . "Street")))
         (an-address (make-instance-from-json 'json-schema.test.generated::address
                                              address-jsown)))
    (parachute:of-type string (jsown:to-json an-address))
    (verbose:debug :test-produce-class (jsown:to-json an-address))
    (let ((an-address-jsown (jsown:parse (jsown:to-json an-address))))
      (parachute:is #'equal address-jsown an-address-jsown))))
