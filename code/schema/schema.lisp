#|
    Copyright (C) 2019-2020 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.schema)

(defclass schema ()
  ())

(defclass object-schema (schema)
  ((object :initarg :object
           :accessor object
           :type hash-table
           :documentation "The parsed json schema object"))
    (:documentation "Holds the object and meta about a schema"))

(defclass uri-schema (object-schema)
  ((uri :initarg :uri
        :accessor uri
        :documentation "The name uri for this schema.")))

(defgeneric name (schema)
  (:documentation "Return the name of the schema as it appears in it's path.")
  (:method ((schema uri-schema))
    (schema-name<-uri (uri schema))))

(defclass named-schema (object-schema)
  ((name :initarg :name
          :accessor name
          :documentation "The name as it appears as a property on the parent-schema."))
  (:documentation "Represents a property in a schema that is an object with properties.

Really don't know if this should be inherting schema but we'll stick to it.
Way to fix is to just say not every schema will have a uri.
I guess this is a sort of anon schema."))

;;; might be an argument to add a parent uri later on.
(defclass inner-schema (schema)
  ((%parent :initarg :parent
            :reader parent
            :documentation "The parent schema to this inner schema.")

   (%name :initarg :name
          :accessor name
          :documentation "The name, can't really inherit named-schema")

   (%parent-key :initarg :parent-key
                :reader parent-key
                :type string
                :documentation "The key on the parent that this schema came from.")))

(defmethod object ((schema inner-schema))
  (let ((object
         (funcall #'hash-filter (object (parent schema))
                  "properties" (parent-key schema))))
    (or object (make-hash-table :test #'equal))))


(defgeneric find-referenced-schemas (schema)
  (:documentation "returns a list of schemas that are referenced."))

(defun unknown-item (item)
  (let ((reference-list-item
         (typecase item
           (hash-table (alexandria:hash-table-alist item))
           (t item))))
    (warn "not sure how to resolve reference:~%~w~%skipping..."
          reference-list-item))
  nil)

(defmethod find-referenced-schemas ((schema schema))
  "returns schemas that are in the immediate allOf."
  (let ((all-of (gethash "allOf" (object schema))))
    (when all-of
      (loop :for reference-list-item :in all-of :append
           (let ((ref (gethash "$ref" reference-list-item))
                 (properties (gethash "properties" reference-list-item)))
             (cond (ref (list (find-schema (relative-schema ref schema))))
                   (properties
                    (list (make-instance 'json-schema.schema:object-schema
                                         :object reference-list-item)))
                   (t (unknown-item reference-list-item))))))))

(defmethod find-referenced-schemas ((schema inner-schema))
  (append
   (call-next-method)
   (let ((all-of (gethash "allOf" (object (parent schema)))))
     (loop :for reference-list-item :in all-of :append
          (let ((ref (gethash "$ref" reference-list-item))
                (properties (gethash "properties" reference-list-item)))
            (cond (ref
                   (let ((new-parent-schema
                          (find-schema (relative-schema ref (parent schema)))))
                     (list
                      (make-instance 'json-schema.schema:inner-schema
                                     :parent new-parent-schema
                                     :parent-key (parent-key schema)
                                     :name
                                     (format nil "~a-~a"
                                             (%symbol<-key (name new-parent-schema))
                                             (parent-key schema))))))
                  (properties
                   (let ((new-inner (gethash (parent-key schema) properties)))
                     (when new-inner
                       (list (make-instance 'json-schema.schema:object-schema
                                            :object new-inner)))))
                  (t (unknown-item reference-list-item))))))))

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
