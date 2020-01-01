(asdf:defsystem #:json-schema.cl-mongo
  :description "Utilities for storing json-schema instances with cl-mongo."
  :author "Gnuxie <Gnuxie@protonmail.com>"
  :license  "NON-VIOLENT PUBLIC LICENSE v2+"
  :version "0.0.1"
  :depends-on ("json-schema" "cl-mongo")
  :serial t
  :components ((:module "code" :components
                        ((:module "store" :components
                                  ((:module "cl-mongo" :components
                                            ((:file "cl-mongo")))))))))
