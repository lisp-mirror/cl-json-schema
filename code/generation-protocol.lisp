
#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema)

(defgeneric produce-schema (schema option)
  (:documentation "This is the top generic you all to get everything

A class for the schema named by name. The method impls needed to use json-schema.
The option is used to determine whether to use the mop impl or something else,
like generating specific methods for this class.")

  (:method (schema (option mop-option))
    `(progn ,(class<-object schema option))))

(defgeneric class<-object (schema option)
  (:documentation "Produce a class from a json-schema object.")

  (:method ((schema schema) (option mop-option))
    (with-hash-keys (("properties")) (object schema)
      (let ((class-symbol
             (symbol<-key (name schema)
                          (target-package option (%symbol<-key (name schema))))))
        (multiple-value-bind (parents more-slots) (resolve-references schema option)
            (declare (ignore more-slots)) ; we don't care about this yet.
            `(progn (defclass ,class-symbol ,parents
                      ( ,@ (loop :for key :being :the :hash-key :using
                                (hash-value property) :of properties :collect
                                (slot<-property key property schema option)))
                      (:metaclass json-schema:json-serializable-class))
                    ;; this is because our constructors need the c-p-l before make-instance.
                    (c2mop:finalize-inheritance (find-class ',class-symbol))))))))

(defgeneric slot<-property (name property parent-schema option)
  (:documentation "produce a slot definition for the property")

  (:method (name property parent-schema (option mop-option))
    (with-hash-keys (("type")) property
      (let ((target-package (target-package option (name parent-schema))))
        `(,(symbol<-key name target-package) :initarg ,(keyword<-key name)
           :accessor ,(symbol<-key name target-package)
           :type ,(cl-type<-json-schema-type type)
           :json-key ,name)))))

(defgeneric resolve-references (schema option)
  (:documentation "Resolve the references in the schema

returns (values parents more-slots) as determined by the overrides
specified in the schema")

  (:method (schema (option mop-option))
    (let ((parents '()))
      (with-hash-keys (("allOf")) (object schema)
        (loop :for item :in all-of :do
             (let ((ref (gethash "$ref" item)))
               (when (not (null ref))
                 (push (find-schema (relative-schema ref schema)) parents)))))
      (remove-if #'null
                 (mapcar (lambda (schema)
                           (find-schema-class schema option))
                         parents)))))

(defgeneric find-schema-class (schema option)
  (:documentation "Try find if the schema has already been defined.

Don't know if we will have to have an ensure later on.")

  (:method (schema (option mop-option))
    (let ((target-package (target-package option (name schema))))
      (find-class (symbol<-key (name schema) target-package) nil))))
