(asdf:defsystem #:json-schema.schema
  :description "Handle schema files"
  :author "Gnuxie <Gnuxie@protonmail.com>"
  :license  "NON-VIOLENT PUBLIC LICENSE v2+"
  :version "0.0.1"
  :depends-on ("cl-yaml" "defpackage-plus")
  :serial t
  :components ((:file "package")
               (:file "utils")
               (:file "schema")))
