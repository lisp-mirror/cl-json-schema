#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.schema)

(defclass schema ()
  ((object :initarg :object
           :accessor object
           :type hash-table
           :documentation "The parsed json schema object"))
  (:documentation "Holds the object and meta about a schema"))

(defclass uri-schema (schema)
  ((uri :initarg :uri
        :accessor uri
        :documentation "The name uri for this schema.")))

(defgeneric name (schema)
  (:documentation "Return the name of the schema as it appears in it's path.")
  (:method ((schema uri-schema))
    (schema-name<-uri (uri schema))))

(defclass named-schema (schema)
  ((name :initarg :name
          :accessor name
          :documentation "The name as it appears as a property on the parent-schema."))
  (:documentation "Represents a property in a schema that is an object with properties.

Really don't know if this should be inherting schema but we'll stick to it.
Way to fix is to just say not every schema will have a uri.
I guess this is a sort of anon schema."))

;;; might be an argument to add a parent uri later on.
(defclass inner-schema (named-schema)
  ((%parent :initarg :parent
            :reader parent
            :documentation "The parent schema to this inner schema.")

   (%parent-key :initarg :parent-key
                :reader parent-key
                :type string
                :documentation "The key on the parent that this schema came from.")))

(defmethod make-load-form ((schema schema) &optional env)
  (make-load-form-saving-slots schema :environment env))

(defgeneric find-schema (uri)
  (:documentation "retruns a schema instance")
  
  (:method ((uri pathname))
    (make-instance 'uri-schema
                 :object (yaml:parse uri)
                 :uri uri)))

(defgeneric schema-name<-uri (path)
  (:method ((path pathname))
    (alexandria:switch ((pathname-type path) :test #'string=)
      ("yaml" (pathname-name path))
      ("json" (pathname-name path))
      (t (file-namestring path)))))

(defgeneric internal-name (schema package)
  (:documentation "Return the name of the schema as a transformed class-name")
  (:method ((schema schema) package)
    (symbol<-key (name schema) package)))

(defun relative-schema (uri schema)
  (merge-pathnames uri (uri schema)))
