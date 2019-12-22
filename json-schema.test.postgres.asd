(asdf:defsystem #:json-schema.test.postgres
  :description "Postges store for json-schema, I'm evil."
  :author "Gnuxie <Gnuxie@protonmail.com>"
  :license  "NON-VIOLENT PUBLIC LICENSE v2+"
  :version "0.0.1"
  :depends-on ("verbose" "parachute" "json-schema.postgres")
  :serial t
  :components ((:module "test"
                        :components
                        ((:module "postgres" :components
                                  ((:file "package")
                                   (:file "run")
                                   (:file "generation")))))))
