(asdf:defsystem #:json-schema.mop
  :description "Meta classes for representing json objects.
would be json-mop2."
  :author "Gnuxie <Gnuxie@protonmail.com>"
  :license  "NON-VIOLENT PUBLIC LICENSE v4+"
  :version "0.0.1"
  :depends-on ("closer-mop")
  :serial t
  :components ((:file "package")
               (:file "protocol")
               (:file "json-metaclass")))
