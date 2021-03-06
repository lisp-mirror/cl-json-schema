#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(defpackage #:json-schema.test.generation
  (:use #:cl #:json-schema #:json-schema.schema))

;;; because the package has not been created in this compilation unit
;;; we will have to use target-package::sym so the reader doesn't explode
;;; after immediatly ensuring the package at the top of the file.
;;; maybe we put thses tests in their own package and in the package file
;;; with a fresh compilation unit, ensure the target packages and exports.
(defpackage+-1:ensure-package :json-schema.test.generated)
(defpackage+-1:ensure-package :json-schema.test.inner-schema)
(defpackage+-1:ensure-export '(:msgtype :body :m.room.message-content :m.room.message)
                             (find-package :json-schema.test.inner-schema))

(defpackage+-1:ensure-package :json-schema.test.anon-schemas)
