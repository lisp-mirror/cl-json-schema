#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema)

(defclass mop-option ()
  ((package-prefix :initarg :package-prefix
                   :initform "json-schema.generated."
                   :type string
                   :accessor package-prefix))
  (:documentation "This is just something to configure before passing to the generator.")
  )

(defmethod target-package ((option mop-option) name)
  (let ((package-designator
         (string-upcase (concatenate 'string (package-prefix option) name))))
    (defpackage+-1:ensure-package package-designator)
    (find-package package-designator)))
