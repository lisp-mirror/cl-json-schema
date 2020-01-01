#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(defpackage #:json-schema.cl-mongo
  (:use #:cl))

(in-package #:json-schema.cl-mongo)


;;; we are basically being naughty here but cl-mongo is dead so idk if bad
;;; things will happen chances are that we will have to make some contributions
;;; to cl-mongo later anwyays...
(defmethod cl-mongo::bson-encode-container ((container list)
                                            &key (array nil) (size nil))
  (let* ((size (or size 10))
         (array (or array (cl-mongo::make-octet-vector size))))
    (cl-mongo::add-octets (cl-mongo::int32-to-octet 0) array)
    (loop :for ((key . value)) :on container :do
         (cl-mongo::add-octets (cl-mongo::bson-encode key value)
                               array :start 4 :from-end 1))
    (cl-mongo::normalize-array array)))

;;; uhhhhhhh isn't this technically pushing octets into one place and
;;; having to write them ->>> up the vector or something?
;;; which would be bad.
(defmethod cl-mongo::bson-encode-container ((object json-schema:json-serializable)
                                            &key (size 32) (array nil))
  (let ((array (or array (cl-mongo::make-octet-vector size))))
    (cl-mongo::add-octets (cl-mongo::int32-to-octet 0) array)
    (loop :for class :in (c2mop:class-precedence-list (class-of object)) :do
         (loop
            :for slot :in (c2mop:class-direct-slots class) :do
              (let ((slot-name (c2mop:slot-definition-name slot)))
                (when (slot-boundp object slot-name)
                  (cl-mongo::add-octets
                   (cl-mongo::bson-encode (json-schema:json-key-name slot)
                                          (slot-value object slot-name))
                   array
                   :start 4 :from-end 1)))))
    (cl-mongo::normalize-array array)))

(defmethod cl-mongo::bson-encode ((key string) (value json-schema:json-serializable) &key)
  (cl-mongo::bson-encode key (cl-mongo::bson-encode-container value)))
