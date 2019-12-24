;;;; json-schema.asd

(asdf:defsystem #:json-schema
  :description "Generate clos stuff from json schemas."
  :author "Gnuxie <Gnuxie@protonmail.com>"
  :license  "NON-VIOLENT PUBLIC LICENSE v2+"
  :version "0.0.1"
  :depends-on ("json-schema.schema" "jsown" "closer-mop" "defpackage-plus")
  :serial t
  :components ((:module "code" :components
                        ((:file "package")
                         (:file "json-metaclass")
                         (:file "generation-option")
                         (:file "generation-protocol")
                         (:file "reader")))))

