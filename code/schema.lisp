#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema)

(defclass schema ()
  ((object :initarg :object
           :accessor object
           :type hash-table
           :documentation "The parsed json schema object")

   (uri :initarg :uri
        :accessor uri
        :documentation "The name uri for this schema."))
  (:documentation "Holds the object and meta about a schema,

like where it came from so that relative uri's can be resolved."))

(defmethod make-load-form ((schema schema) &optional env)
  (declare (ignore env))
  `(make-instance 'schema
                  :object
                  (alexandria:alist-hash-table
                   ',(alexandria:hash-table-alist (object schema))
                   :test 'equal)
                  :uri ,(uri schema)))


(defgeneric find-schema (uri)
  (:documentation "retruns a schema instance")
  
  (:method ((uri pathname))
    (find-schema-from-file uri)))

(defgeneric schema-name<-uri (path)
  (:method ((path pathname))
    (pathname-name path)))

(defgeneric name (schema)
  (:documentation "Return the name of the schema as it appears in it's path.")
  (:method ((schema schema))
    (schema-name<-uri (uri schema))))

(defgeneric internal-name (schema option)
  (:documentation "Return the name of the schema as a transformed class-name")
  (:method ((schema schema) (option mop-option))
    (let ((target-package (target-package option (name schema))))
      (symbol<-key (name schema) target-package))))

(defun find-schema-from-file (path)
  (make-instance 'schema
                 :object (yaml:parse path)
                 :uri path))

(defun relative-schema (uri schema)
  (merge-pathnames uri (uri schema)))
