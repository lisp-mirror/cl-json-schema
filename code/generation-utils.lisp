#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema)

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

(declaim (inline %symbol<-key symbol<-key keyword<-key))
(defun %symbol<-key (key)
  (string-upcase (cl-change-case:param-case key)))

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
                   `(,(symbol<-key key)
                      (gethash ,key ,table ,default)))))
     ,@body))

(defmacro do-referenced-schemas (referenced-schema schema &body body)
  "provides an iterator for referenced schema from a schema 
REFERENCED-SCHEMA is the symbol to bind the refernced schema to.
SCHEMA is a schema.
"
  (alexandria:with-gensyms (item all-of ref)
    `(let ((,all-of (gethash "allOf" (object ,schema))))
      (loop :for ,item :in ,all-of :do
           (let ((,ref (gethash "$ref" ,item)))
             (unless (null ,ref)
               (let ((,referenced-schema (find-schema (relative-schema ,ref schema))))
                 ,@body)))))))
