#|
    Copyright (C) 2020 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.jonathan)

;;; to get an idea of how these are used please see jonathan.lisp
(defgeneric serialize-slot (slot effective-slotd class instance)
  (:documentation "Serialize the slot to the jonathan:*stream*
used within json-schema.jonathan:within-object by the default
jonathan:%to-json method for a json-serializable.

See within-object"))

(defgeneric create-encoder (class)
  (:documentation "create an :around method on jonathan:%to-json
that is specific to this class. This is supposed to be used to create
a faster serializer method for instances of this class (if say you know
you are going to have a lot of them)."))

(defgeneric create-serializer (slot effective-slotd class instance-var)
  (:documentation "Used by create-encoder to make an inline serializer for the slot."))
