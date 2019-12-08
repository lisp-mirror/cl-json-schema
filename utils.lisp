#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema)

(declaim (inline %symbol<-key symbol<-key keyword<-key))
(defun %symbol<-key (key)
  (string-upcase (cl-change-case:param-case key)))

(defun symbol<-key (key)
  (intern (%symbol<-key key)))

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


#|
(with-hash-keys (("properties") ("type")) *foo*
           (values properties type))
|#
