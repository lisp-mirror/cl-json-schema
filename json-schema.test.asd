(asdf:defsystem #:json-schema.test
  :description "Generate clos stuff from json schemas."
  :author "Gnuxie <Gnuxie@protonmail.com>"
  :license  "NON-VIOLENT PUBLIC LICENSE v2+"
  :version "0.0.1"
  :depends-on ("json-schema" "parachute" "verbose")
  :serial t
  :components ((:module "test" :components
                        ((:file "package")
                         (:file "generation-package")
                         (:file "generation")
                         (:file "reader")
                         (:file "resolve")))))
