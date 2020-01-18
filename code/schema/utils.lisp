#|
    Copyright (C) 2019-2020 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.schema)

(declaim (inline %symbol<-key symbol<-key keyword<-key))
(defun %symbol<-key (key)
  (declare (type string key))
  (string-upcase (substitute #\- #\_ key)))

(defun symbol<-key (key &optional (package *package*))
  (let ((sym (intern (%symbol<-key key) package)))
    (defpackage+-1:ensure-export (list sym) package)
    sym))

(defun keyword<-key (key)
  (intern (%symbol<-key key) :keyword))

(defmacro with-hash-keys ((&rest keys) table &body body)
  (when (null keys)
    (error "give me some keys ya fool"))
  `(let (,@ (loop :for key-specifier :in keys :collect
                 (destructuring-bind (key &optional default) key-specifier
                   `(,(intern (%symbol<-key key))
                      (gethash ,key ,table ,default)))))
     ,@body))

(defmacro do-referenced-schemas (referenced-schema schema &body body)
  "provides an iterator for referenced schema from a schema 
REFERENCED-SCHEMA is the symbol to bind the refernced schema to.
SCHEMA is a schema.
"
  (alexandria:with-gensyms (item all-of)
    `(let ((,all-of (gethash "allOf" (object ,schema))))
      (loop :for ,item :in ,all-of :do
           (let ((,referenced-schema
                  (let ((ref (gethash "$ref" ,item))
                        (properties (gethash "properties" ,item)))
                    (cond (ref (find-schema (relative-schema ref ,schema)))
                          (properties
                           (make-instance 'json-schema.schema:schema
                                          :object ,item))
                          (t nil)))))
             (when ,referenced-schema
               ,@body))))))

(defun hash-filter (table &rest keys)
  (declare (optimize (speed 3) (safety 1) (debug 0)))
  (cond ((null keys)
         (values table t))
        (t
         (check-type table hash-table)
         (multiple-value-bind (val present) (gethash (first keys) table)
           (if (not present)
               (values nil nil)
               (apply #'hash-filter val (rest keys)))))))
