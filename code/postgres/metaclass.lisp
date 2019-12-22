#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.postgres)

(defclass json-store-class (json-schema:json-serializable-class
                            postmodern:dao-class)
  ())

(defmethod c2mop:validate-superclass ((class json-store-class)
                                      (super-class json-schema:json-serializable-class))
  t)

(defmethod c2mop:validate-superclass ((class json-store-class)
                                      (super-class postmodern:dao-class))
  t)

(defclass json-store-slot (json-schema::json-serializable-slot
                           postmodern::direct-column-slot)
  ())

(defmethod c2mop:direct-slot-definition-class ((class json-store-class)
                                               &rest initargs)
  (declare (ignore class initargs))
  (find-class 'json-store-slot))
