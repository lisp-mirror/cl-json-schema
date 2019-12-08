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
       (,@ (loop :for key :being :the :hash-key :using 
                (hash-value property) :of properties :collect
                (slot<-property key property object))))))

(defgeneric json-constructor<-object (name object)
  (:documentation "used to create the constructor for the"))

(defgeneric json-validator<-object (name object format)
  (:documentation "used to create the json validator for the object."))

(defun property-validator<-property (schema key property json-sym)
  "validate all aspects of the property

we could make this faster just by declaiming the type of the value tbh"
  (with-hash-keys (("type")) property
    (with-hash-keys (("required" '())) schema
      `(multiple-value-bind (value provided) (jsown:val-safe ,json-sym ,key)
         ,(if (member key required :test #'string=)
              `(and provided
                    (typep value ',(cl-type<-json-schema-type type)))
              `(or (not provided)
                   (typep value ',(cl-type<-json-schema-type type))))))))


(defmethod json-validator<-object (name object (format (eql :fast)))
  (with-hash-keys (("properties")) object
    `(defmethod validate-json ((class (eql ',name)) (json list) (format (eql :fast)))
       (and
        ,@ (loop :for key :being :the :hash-key :using
                (hash-value property) :of properties :collect
                (property-validator<-property object key property 'json))))))

(defgeneric make-instance-from-json (class json)
  (:documentation "create an instance of class from the json

This should also validate the json provided against the schema?"))

(defgeneric validate-json (class json format)
  (:documentation "Validate the json against the schema

https://json-schema.org/draft/2019-09/json-schema-core.html#rfc.section.10

I think we're going to make a :fast format which will just ignore this spec
and validate the class for the constructors.")
  (:method (class (json string) format)
    (validate-json class (jsown:parse json) format)))
