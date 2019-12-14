#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema)

(defgeneric produce-schema (name schema option)
  (:documentation "This is the top generic you all to get everything

A class for the schema named by name. The method impls needed to use json-schema.
The option is used to determine whether to use the mop impl or something else,
like generating specific methods for this class.")

  (:method (name schema (option mop-option))
    `(progn ,(class<-object name schema option))))

(defgeneric class<-object (name schema option)
  (:documentation "Produce a class from a json-schema object.")

  (:method (name object (option mop-option))
    (with-hash-keys (("properties")) object
      (let ((class-symbol (symbol<-key name
                                       (target-package option (%symbol<-key name)))))
        `(progn (defclass ,class-symbol ()
                    ( ,@ (loop :for key :being :the :hash-key :using
                              (hash-value property) :of properties :collect
                              (slot<-property key name property object option)))
                  (:metaclass json-schema:json-serializable-class))
                ;; this is because our constructors need the c-p-l before make-instance.
                (c2mop:finalize-inheritance (find-class ',class-symbol)))))))

(defgeneric slot<-property (name schema-name property parent-object option)
  (:documentation "produce a slot definition for the property")

  (:method (name schema-name property parent-object (option mop-option))
    (with-hash-keys (("type")) property
      (let ((target-package (target-package option schema-name)))
        `(,(symbol<-key name target-package) :initarg ,(keyword<-key name)
           :accessor ,(symbol<-key name target-package)
           :type ,(cl-type<-json-schema-type type)
           :json-key ,name)))))
