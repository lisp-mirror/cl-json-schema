#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema)

(defclass mop-option ()
  ((package-prefix :initarg :package-prefix
                   :initform "json-schema.generated."
                   :type string
                   :accessor package-prefix)

   (ref-overrides :initarg :ref-overrides
                  :initform '()
                  :type list
                  :accessor ref-overrides
                  :documentation "When a reference to a schema is made
that is overriden, the slots for this schema are placed into the referee
rather than inherited, which is actually the way json schema should behave
if we were not abusing it to generate our classes.
"))
  (:documentation "This is just something to configure before passing to the generator."))

(defmethod target-package ((option mop-option) name)
  (let ((package-designator
         (string-upcase (concatenate 'string (package-prefix option)
                                     (%symbol<-key name)))))
    (defpackage+-1:ensure-package package-designator)
    (find-package package-designator)))

(defmethod make-load-form ((mop-option mop-option) &optional env)
  (declare (ignore env))
  `(make-instance 'mop-option
                  :package-prefix ,(package-prefix mop-option)
                  :ref-overrides ',(ref-overrides mop-option)))
