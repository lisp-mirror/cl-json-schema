;;;; json-schema.asd

(asdf:defsystem #:json-schema
  :description "Generate clos stuff from json schemas."
  :author "Gnuxie <Gnuxie@protonmail.com>"
  :license  "NON-VIOLENT PUBLIC LICENSE v4+"
  :version "0.0.1"
  :depends-on ("jonathan" "json-schema.schema" "json-schema.mop" "closer-mop"
                          "defpackage-plus" "verbose")
  :serial t
  :components ((:module "code" :components
                        ((:file "package")
                         (:file "generation-option")
                         (:file "generation-protocol")
                         (:module "serializers" :components
                                  ((:module "jonathan" :components
                                            ((:file "package")
                                             (:file "protocol")
                                             (:file "macros")
                                             (:file "jonathan")))))))))

