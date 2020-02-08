#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(defpackage #:json-schema.cl-mongo
  (:use #:cl)
  (:export
   #:json/collection-slot
   #:json/collection-class
   #:json/bson-serializable
))

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
    (loop :for ((effective-slotd top-slot)) :on (json-schema.mop:slot-precedence-list (class-of object)) :do
         (cl-mongo::bson-encode-container top-slot :array array :object object))
    (cl-mongo::normalize-array array)))

(defmethod cl-mongo::bson-encode-container ((slot json-schema:json-serializable-slot) &key array object)
  (assert (not (null array)))
  (assert (not (null object)))
  (let ((slot-name (c2mop:slot-definition-name slot)))
    (when (slot-boundp object slot-name)
      (cl-mongo::add-octets
       (cl-mongo::bson-encode (json-schema:json-key-name slot)
                              (slot-value object slot-name))
       array
       :start 4 :from-end 1)))
  array)

(defmethod cl-mongo::bson-encode ((key string) (value json-schema:json-serializable) &key)
  (cl-mongo::bson-encode key (cl-mongo::bson-encode-container value)))

(defmethod cl-mongo-meta:collection-name ((collection json-schema:json-serializable))
  (prin1-to-string (class-name (class-of collection))))

(defmethod cl-mongo-meta:db.insert ((collection json-schema:json-serializable) &key)
  (cl-mongo:db.insert (cl-mongo-meta:collection-name collection) collection))

;;; allow the cl-mongo class to inherit the json-serializable one
;;; json-serializer methods for the cl-mongo-meta slots
;;; possibility of mixed fields, e.g. a field that is a ghost in the json
;;; but is not a ghost in the store.

(defclass json/collection-slot (cl-mongo-meta:collection-slot
                                json-schema:json-serializable-slot)
  ((%json-ghost :initarg :json-ghost
                :reader ghostp
                :initform nil
                :type boolean
                :documentation "Whether to serialize this slot to json.")))

(defclass json/collection-class (cl-mongo-meta:collection-class
                                 json-schema:json-serializable-class)
  ())

(defclass json/bson-serializable (json-schema:json-serializable
                                  cl-mongo-meta:bson-serializable)
  ())

;;; remember to introduct json-ghostp
(defmethod json-schema.jonathan:serialize-slot ((slot json/collection-slot)
                                                effective-slotd class instance)
  (json-schema.jonathan:within-object
    (when (and (not (ghostp slot))
               (c2mop:slot-boundp-using-class class instance effective-slotd))
      (jonathan:write-key-value
       (json-schema:json-key-name slot)
       (c2mop:slot-value-using-class class instance effective-slotd)))))

(defmethod json-schema.jonathan:slot-serializer ((slot json/collection-slot)
                                                 effective-slotd class instance-var)
  (declare (ignore effective-slotd class))
  (let ((slot-name (c2mop:slot-definition-name slot)))
    `(when (and (not ghostp slot)
                (slot-boundp ,instance-var ',slot-name))
       (jonathan:write-key-value
        ,(json-schema:json-key-name slot)
        (slot-value object ',slot-name)))))

(defmethod c2mop:direct-slot-definition-class ((class json/collection-class)
                                               &rest initargs)
  (declare (ignore initargs))
  (find-class 'json/collection-slot))

(defmethod c2mop:class-direct-superclasses ((class json/collection-class))
  (let* ((class-names-to-remove '(standard-object cl-mongo-meta:bson-serializable
                                  json-schema:json-serializable
                                  json/bson-serializable))
         (classes-to-remove (mapcar #'find-class class-names-to-remove)))
    (append (remove-if (lambda (c-p-l-class)
                         (member c-p-l-class classes-to-remove))
                       (call-next-method))
            (list (find-class 'json/bson-serializable)
                  (find-class 'json-schema:json-serializable)
                  (find-class 'cl-mongo-meta:bson-serializable)
                  (find-class 'standard-object)))))

(defmethod c2mop:validate-superclass ((class json/collection-class)
                                      (super c2mop:standard-class))
  t)

(defmethod c2mop:validate-superclass ((class c2mop:standard-class)
                                      (super json/collection-class))
  t)

(defmethod c2mop:validate-superclass ((class json/collection-class)
                                      (super cl-mongo-meta:collection-class))
  t)

(defmethod c2mop:validate-superclass ((class cl-mongo-meta:collection-class)
                                      (super json/collection-class))
  t)

(defmethod c2mop:validate-superclass ((class json/collection-class)
                                      (super json-schema:json-serializable-class))
  t)

(defmethod c2mop:validate-superclass ((class json-schema:json-serializable-class)
                                      (super json/collection-class))
  t)
