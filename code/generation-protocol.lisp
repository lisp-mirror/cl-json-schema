
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

(defgeneric direct-slots<-schema (schema option)
  (:documentation "The will return a list of both direct-slots
for this schema definition.")

  (:method ((schema schema) (option mop-option))
    (with-hash-keys (("properties")) (object schema)
      (loop :for key :being :the :hash-key :using
           (hash-value property) :of properties :collect
           (slot<-property key property schema option)))))

(defgeneric class<-object (schema option)
  (:documentation "Produce a class from a json-schema object.")

  (:method ((schema schema) (option mop-option))
    (multiple-value-bind (parents more-slots) (resolve-references schema option)
      `(progn
         ,(when (not (null parents)) ; avoid style-warning for unused option.
            `(let ((option ,option))
               ,@(mapcar (lambda (schema) `(ensure-schema-class ,schema option))
                         parents)))
         (defclass ,(internal-name schema option)
             ,(mapcar (lambda (schema)
                        (internal-name schema option))
                      parents)
           ,(append (direct-slots<-schema schema option)
                    more-slots)
           ,@ (class-options<-schema schema option))
         ;; this is because our constructors need the c-p-l before make-instance.
         (c2mop:finalize-inheritance (find-class ',(internal-name schema option)))))))

(defgeneric slot<-property (name property parent-schema option)
  (:documentation "produce a slot definition for the property")

  (:method (name property parent-schema (option mop-option))
    (with-hash-keys (("type")) property
      (let ((target-package (target-package option (name parent-schema))))
        `(,(symbol<-key name target-package) :initarg ,(keyword<-key name)
           :accessor ,(symbol<-key name target-package)
           :type ,(cl-type<-json-schema-type type)
           :json-key ,name)))))

(defgeneric class-options<-schema (schema option)
  (:documentation "a list of the class options for the class definition.")
  (:method (schema (option mop-option))
    (declare (ignore schema option))
    '((:metaclass json-schema:json-serializable-class))))

(defgeneric resolve-references (schema option)
  (:documentation "Resolve the references in the schema

returns (values parents more-slots) as determined by the overrides
specified in the schema")

  (:method (schema (option mop-option))
    (let ((parents '())
          (more-slots '()))
      
      (flet ((add-slots (slots)
               (setf more-slots (append more-slots slots)))
             
             (add-parents (new-parents)
               (setf parents (append parents new-parents))))
        
        (with-hash-keys (("allOf")) (object schema)
          (loop :for item :in all-of :do
               (let ((ref (gethash "$ref" item)))
                 (when (not (null ref))
                   (let ((referenced-schema (find-schema (relative-schema ref schema))))
                     (cond
                       ((inherit-schema-p (name referenced-schema) option)
                        (push referenced-schema parents))
                       (t 
                        (add-slots
                         (direct-slots<-schema referenced-schema option))
                        (multiple-value-bind (next-parents next-slots)
                            (resolve-references referenced-schema option)
                          (add-parents next-parents)
                          (add-slots next-slots))))))))))
      (values 
       parents
       more-slots))))


(defgeneric ensure-schema-class (schema option)
  (:method (schema (option mop-option))
    (let ((class-name (internal-name schema option)))
      (or (find-class class-name nil)
          (progn (eval (produce-schema schema option))
                 (find-class class-name))))))
