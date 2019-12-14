#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema)

(defgeneric make-instance-from-json (class json)
  (:documentation "create an instance of class from the json

This should also validate the json provided against the schema?")

  (:method ((class symbol) json)
    (make-instance-from-json-using-serial (find-class class) json)))

;;; can be imporoved.
(defmethod make-instance-from-json-using-serial (given-class (json list))
  (apply #'make-instance given-class
         (loop :for class :in (c2mop:class-precedence-list given-class) :appending
              (loop
                 :for slot :in (c2mop:class-direct-slots class)
                 :if (typep slot 'json-serializable-slot) :append
                   (multiple-value-bind (value providedp)
                       (jsown:val-safe json (json-key-name slot))
                     (when providedp
                       (list (car (c2mop:slot-definition-initargs slot))
                             value)))))))
