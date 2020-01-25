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
         (sample-schema-json (jonathan:to-json sample-schema-jsown :from :jsown))
         (sample-schema (make-instance 'uri-schema :uri #P"address" :object (yaml:parse sample-schema-json)))
         (produced-schema (produce-schema sample-schema *schema-option*)))
    (verbose:debug :test-produce-class "~w" produced-schema)
    (parachute:finish (eval produced-schema)))

  (let* ((address-alist '(("house_number" . 13)
                          ("street_name" . "long road")
                          ("street_type" . "Street")))
         (an-address (make-instance-from-json 'json-schema.test.generated::address
                                              (jonathan:to-json address-alist
                                                                :from :alist))))
    (parachute:of-type string (jonathan:to-json an-address))
    (verbose:debug :test-produce-class (jonathan:to-json an-address))
    (let ((an-address-alist (jonathan:parse (jonathan:to-json an-address) :as :alist)))
      (parachute:is #'equal (sort (copy-alist address-alist) #'string> :key #'car)
                    an-address-alist))))
