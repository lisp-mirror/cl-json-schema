(asdf:defsystem #:json-schema.postgres
  :description "Postges store for json-schema, I'm evil."
  :author "Gnuxie <Gnuxie@protonmail.com>"
  :license  "NON-VIOLENT PUBLIC LICENSE v2+"
  :version "0.0.1"
  :depends-on ("json-schema" "postmodern")
  :serial t
  :components ((:module "code"
                        :components
                        ((:module "postgres" :components
                                   ((:file "package")
                                    (:file "metaclass")
                                    (:file "generation-option")))))))
