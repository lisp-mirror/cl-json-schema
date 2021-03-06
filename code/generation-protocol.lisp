#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema)

(defun cl-type<-json-schema-type (type)
  (etypecase type
    (null 'null)
    (list
     `(or ,@ (mapcar #'cl-type<-json-schema-type type)))
    (string
     (alexandria:switch (type :test #'string=)
       ("string" 'string)
       ("integer" 'integer)
       ("number" 'number)
       ("object" '(or json-schema:json-serializable string))
       ("array" 'list)
       ("boolean" 'boolean)
       ("null" 'null)))))

(defgeneric produce-schema (schema option)
  (:documentation "This is the top generic you all to get everything

A class for the schema named by name. The method impls needed to use json-schema.
The option is used to determine whether to use the mop impl or something else,
like generating specific methods for this class.")

  (:method (schema (option mop-option))
    (let ((output `(progn ,(class<-object schema option)
                          ,(find-inner-classes schema option))))
      (v:debug :produce-schema "~%~%~w" output)
      output)))

(defgeneric direct-slots<-schema (schema option)
  (:documentation "The will return a list of both direct-slots
for this schema definition.")

  (:method ((schema schema) (option mop-option))
    (with-hash-keys (("properties")) (object schema)
      (when properties
        (loop :for key :being :the :hash-key :using
             (hash-value property) :of properties :collect
             (slot<-property key property schema option))))))

(defun find-inner-classes (schema option)
  (with-hash-keys (("properties")) (object schema)
    `(progn
       ,@ (when properties
            (loop :for key :being :the :hash-key :using
                 (hash-value property) :of properties :collect
                 (let* ((inner-properties (gethash "properties" property))
                        (inner-schema
                         (and inner-properties
                              (make-instance 'inner-schema
                                             :name (format nil "~a-~a"
                                                           (internal-name schema option)
                                                           key)
                                             :parent-key key
                                             :parent schema))))
                   (unless (null inner-schema)
                     (produce-schema inner-schema option))))))))

(defgeneric class<-object (schema option)
  (:documentation "Produce a class from a json-schema object.")

  (:method ((schema schema) (option mop-option))
    (multiple-value-bind (parents slots inner-schemas)
        (resolve-references schema option)
      `(progn
         ,(unless (null parents) ; avoid style-warning for unused option.
            `(let ((option ,option))
               ,@(mapcar (lambda (schema) `(ensure-schema-class ,schema option))
                         parents)))
         (defclass ,(internal-name schema option)
             ,(mapcar (lambda (schema)
                        (internal-name schema option))
                      parents)
           ,slots
           ,@ (class-options<-schema schema option))
         ;; this is because our constructors need the c-p-l before make-instance.
         (c2mop:finalize-inheritance (find-class ',(internal-name schema option)))
         ,inner-schemas))))

(defgeneric slot<-property (name property parent-schema option)
  (:documentation "produce a slot definition for the property")

  (:method (name property parent-schema (option mop-option))
    (with-hash-keys (("type")) property
      (let ((target-package (target-package option)))
        `(,(symbol<-key name target-package) :initarg ,(keyword<-key name)
           :accessor ,(symbol<-key name target-package)
           :type ,(cl-type<-json-schema-type type)
           :json-key ,name)))))

(defgeneric class-options<-schema (schema option)
  (:documentation "a list of the class options for the class definition.")
  (:method (schema (option mop-option))
    (declare (ignore schema option))
    '((:metaclass json-schema:json-serializable-class))))

(defun ensure-inherit (symbol target-package)
  "ensure that the symbol is imported into the target-package
and also exported from the target package."
  (defpackage+-1:inherit-from (symbol-package symbol)
                              (list (symbol-name symbol))
                              target-package))

(defgeneric resolve-references (schema option)
  (:documentation "Resolve the references in the schema

returns (values parents slots) as determined by the overrides
specified in the schema")

  (:method (schema (option mop-option))
    (let ((parents '())
          (slots (direct-slots<-schema schema option))
          (inner-schemas '(progn)))
      
      (labels ((update-slot (slot)
                 (let ((association
                        (assoc (car slot) slots :test #'string-equal)))
                   (if association
                       (loop :for (key value) :on (rest slot):by #'cddr :do
                            (let ((existing-option (getf (rest association) key)))
                              (unless existing-option
                                (setf (getf existing-option key) value))))
                       (push slot slots))))

               (add-slots (more-slots)
                 (mapc #'update-slot more-slots))
             
               (add-parents (new-parents)
                 (setf parents (append parents new-parents)))

               (add-inner-schemas (next-inner-schemas)
                 (setf inner-schemas
                       (append inner-schemas
                               (list next-inner-schemas)))))
        
        (do-referenced-schemas referenced-schema schema
          (cond
            ((inherit-schema-p referenced-schema option)
             (push referenced-schema parents))
            (t
             (add-inner-schemas
              (find-inner-classes referenced-schema option))
             (multiple-value-bind (next-parents next-slots next-inner-schemas)
                 (resolve-references referenced-schema option)
               (add-parents next-parents)
               (add-slots next-slots)
               (add-inner-schemas next-inner-schemas)
               (mapc (lambda (slot-option)
                       (ensure-inherit (car slot-option)
                                       (target-package option)))
                     next-slots))))))
      (values 
       parents
       slots
       inner-schemas))))


(defgeneric ensure-schema-class (schema option)
  (:method (schema (option mop-option))
    (let ((class-name (internal-name schema option)))
      (or (find-class class-name nil)
          (progn (eval (produce-schema schema option))
                 (find-class class-name))))))
