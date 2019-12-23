#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema)

(defclass mop-option ()
  ((package-designator :initarg :package-designator
                       :initform "JSON-SCHEMA.GENERATED"
                       :type string
                       :accessor package-designator)

   (ref-overrides :initarg :ref-overrides
                  :initform '()
                  :type list
                  :accessor ref-overrides
                  :documentation "When a reference to a schema is made
that is overriden, the slots for this schema are placed into the referee
rather than inherited, which is actually the way json schema should behave
if we were not abusing it to generate our classes.
")
   (whitelist :initarg :whitelist
              :accessor whitelist
              :initform '()
              :type list
              :documentation "Only the schemas named here will be implemented.

Empty means that it's not being used."))
  (:documentation "This is just something to configure before passing to the generator."))

(defmethod target-package ((option mop-option))
  (let ((package-designator (package-designator option)))
    (defpackage+-1:ensure-package package-designator)
    (find-package package-designator)))

(defmethod make-load-form ((mop-option mop-option) &optional env)
  (declare (ignore env))
  `(make-instance 'mop-option
                  :package-designator ,(package-designator mop-option)
                  :ref-overrides ',(ref-overrides mop-option)
                  :whitelist ',(whitelist mop-option)))

(defgeneric inherit-schema-p (schema-name option)
  (:documentation "Determine if the generator should inherit this schema into
other schemas or pass through all slots/behavoir directly.")

  (:method (schema-name (option mop-option))
    (and (not (member schema-name (ref-overrides option) :test #'string=))
         (not (null (whitelist option)))
         (member schema-name (whitelist option) :test #'string=))))
