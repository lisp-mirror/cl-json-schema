#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.postgres)

(defclass postgres-option (json-schema:mop-option)
  ())

(defmethod make-load-form ((option postgres-option) &optional env)
  (declare (ignore env))
  (with-accessors ((whitelist whitelist)
                   (package-designator package-designator)
                   (ref-overrides ref-overrides))
      option
    `(make-instance 'postgres-option
                    :package-designator ,package-designator 
                    :whitelist ,whitelist
                    :ref-overrides ,ref-overrides)))


(defun postmodern-type<-json-schema-type (type)
  "json schema types are way more complicated than this

TODO: Do it properly."
  (alexandria:switch (type :test #'string=)
    ("string" :text)
    ("integer" :integer)
    ("number" :numeric)
    ;; if we do get an object then fuck we need to find out what it is.
    ;;apply constraints and shit if it's a table ref, or
    ;;keep as a json field.
    ("object" :text)
    ;; what the fuck do we do with arrays?? (lists)
    ("boolean" :boolean)
    ("null" :null)))


(defmethod slot<-property (name property parent-schema (option postgres-option))
  (with-hash-keys (("type")) property
    (append (call-next-method)
            (list :col-type (postmodern-type<-json-schema-type type)))))

(defun find-ids (schema option)
  (let ((ids '()))

    (flet ((add-ids (&rest more-ids)
             (setf ids (append ids more-ids))))

      (do-referenced-schemas referenced-schema schema
        (with-hash-keys (("postmodern_keys")) (object referenced-schema)
          (unless (null postmodern-keys)
            (let ((key-syms
                   (mapcar (lambda (sym)
                             (symbol<-key sym (target-package option)))
                           postmodern-keys)))
              (apply #'add-ids key-syms)))
          (apply #'add-ids (find-ids referenced-schema option)))))
    (values ids)))

(defmethod class-options<-schema (schema (option postgres-option))
  `((:metaclass json-schema.postgres:json-store-class)
    (:keys ,@ (find-ids schema option))))
