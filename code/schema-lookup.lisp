#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema)

(defgeneric find-schema (uri)
  (:documentation "(values yaml-table schema-name)")
  
  (:method ((uri pathname))
    (find-schema-from-file uri)))


(defun schema-name<-path (path)
  (pathname-name path))

(defun find-schema-from-file (path)
  (values (yaml:parse path)
          (schema-name<-path path)))
