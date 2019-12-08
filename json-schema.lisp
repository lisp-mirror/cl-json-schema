#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

;;;; json-schema.lisp

(in-package #:json-schema)

(defgeneric top (name schema)
  (:method (name schema)
    `(progn ,(class<-object name schema)
            ,(json-writer<-object name schema)))
  (:documentation "idfk what to call the top level thing yet but ok"))

(defgeneric class<-schema (schema)
  (:documentation "convert the jsonschema to a class."))


(defgeneric slot<-property (name property parent-object)
  (:documentation "convert a property into a defclass slot specifier"))

(defun cl-type<-json-schema-type (type)
  "json schema types are way more complicated than this

TODO: Do it properly."
  (alexandria:switch (type :test #'string=)
    ("string" 'string)
    ("integer" 'integer)
    ("number" 'number)
    ("object" t) ; if we do get an object then fuck we need to find out what it is.
    ("array" 'list)
    ("boolean" 'boolean)
    ("null" 'null)))

(defmethod slot<-property (name property parent-object)
  (with-hash-keys (("type")) property
    `(,(symbol<-key name) :initarg ,(keyword<-key name)
       :accessor ,(symbol<-key name)
       :type ,(cl-type<-json-schema-type type)
       )))

(defgeneric json-writer<-property (name property parent-object)
  (:documentation "create the json writer for the property"))

(defgeneric json-writer<-object (class-name object))

(defmethod json-writer<-object (class-name object)
  (with-hash-keys (("properties")) object
    `(defmethod jsown:to-json ((object ,class-name))
       (jsown:to-json
        (list :obj
          ,@ (loop :for key :in (alexandria:hash-table-keys properties) :collect
                  `(cons ,key ,`(,(symbol<-key key) object))))))))


(defmethod class<-object (name object)
  (with-hash-keys (("properties")) object
    `(defclass ,name ()
       (,@ (loop :for key :being :the :hash-keys :of properties
              :for property :being :the :hash-values :of properties :collect
                (slot<-property key property object))))))
