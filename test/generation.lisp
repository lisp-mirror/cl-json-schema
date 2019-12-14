#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.test.generation)

(defvar *schema-option*
  (make-instance 'mop-option :package-prefix "json-schema.test."))

(define-test test-produce-class

  (let* ((sample-schema-jsown
         '(:OBJ ("type" . "object")
           ("properties" :OBJ ("house_number" :OBJ ("type" . "number"))
            ("street_name" :OBJ ("type" . "string"))
            ("street_type" :OBJ ("type" . "string")
             ("enum" "Street" "Avenue" "Boulevard")))
           ("additionalProperties")))
         (sample-schema-json (jsown:to-json sample-schema-jsown))
         (sample-schema (yaml:parse sample-schema-json))
         (produced-schema (produce-schema "address" sample-schema *schema-option*)))
    (verbose:debug :test-produce-class "~w" produced-schema)
    (finish (eval produced-schema)))

  (let* ((address-jsown '(:obj ("house_number" . 13)
                          ("street_name" . "long road")
                          ("street_type" . "Street")))
         (an-address (make-instance-from-json 'json-schema.test.address::address
                                              address-jsown)))
    (of-type string (jsown:to-json an-address))
    (verbose:debug :test-produce-class (jsown:to-json an-address))
    (let ((an-address-jsown (jsown:parse (jsown:to-json an-address))))
      (equal address-jsown an-address-jsown))))
