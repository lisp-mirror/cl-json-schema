#|
    Copyright (C) 2020 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.mop)

(defgeneric compute-slot-precedence-list (finalized-class)
    (:documentation "Return a list of slots in ascending order for a finalized class
class => (list (list standard-effective-slot-definition topmost-direct-slot) ...)

Where 'topmost' is the first class in each list for a slot from step 2 of compute-slots
http://metamodular.com/CLOS-MOP/compute-slots.html

And standard-effective-slot-definition is the effective-slot-definition for this slot
as returned by c2mop:class-slots.

This is done so that an encoder-generator can use this list to create a writer
for each slot, or a default encoder can be created for the class which uses this list
to serialize an instance.
"))

(defgeneric slot-precedence-list (finalized-class)
  (:documentation "The slot-precedence-list for the class.

See compute-slot-precedence-list"))

(defgeneric json-key-name (serializable-slot)
  (:documentation "The json-key-name for the slot."))

(defgeneric make-instance-from-json (class json)
  (:documentation "Create an instance of class from the json.")
  (:method (class json)
    (etypecase class
      (symbol (make-instance-from-json (find-class class) json))
      (standard-class (make-instance-from-json (class-of class) json)))))


