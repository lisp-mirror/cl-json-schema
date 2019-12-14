#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(defpackage #:json-schema.test.generation
  (:use #:cl #:json-schema))

;;; because the package has not been created in this compilation unit
;;; we will have to use target-package::sym so the reader doesn't explode
;;; after immediatly ensuring the package at the top of the file.
;;; maybe we put thses tests in their own package and in the package file
;;; with a fresh compilation unit, ensure the target packages and exports.
(defpackage+-1:ensure-package (string-upcase "json-schema.test.event"))
(defpackage+-1:ensure-package (string-upcase "json-schema.test.address"))
(defpackage+-1:ensure-package (string-upcase "json-schema.test.sync-room-event"))
