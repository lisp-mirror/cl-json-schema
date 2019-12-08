;;;; json-schema.asd

(asdf:defsystem #:json-schema
  :description "Generate clos stuff from json schemas."
  :author "Gnuxie <Gnuxie@protonmail.com>"
  :license  "NON-VIOLENT PUBLIC LICENSE v2+"
  :version "0.0.1"
  :depends-on ("cl-yaml" "cl-change-case" "jsown")
  :serial t
  :components ((:file "package")
               (:file "utils")
               (:file "json-schema")))
