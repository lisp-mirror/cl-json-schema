#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema)

(defmethod jonathan:%to-json ((object json-serializable))
  (format t "wohoo")
  (jonathan:with-object
    (loop :for class :in (c2mop:class-precedence-list (class-of object)) :do
         (loop
            :for slot :in (c2mop:class-direct-slots class) :do
              (let* ((slot-name (c2mop:slot-definition-name slot)))
                (when (slot-boundp object slot-name)
                  (jonathan:write-key-value (json-key-name slot)
                                            (slot-value object slot-name))))))))

(defmethod jonathan:%to-json :around ((object json-schema.test.address::address))
  (jonathan:with-object
    (when (slot-boundp object 'json-schema.test.address:house-number)
      (jonathan:write-key-value "house_number" (slot-value object 'json-schema.test.address:house-number)))
    (jonathan:write-key-value "street_name" (slot-value object 'json-schema.test.address:street-name))
    (jonathan:write-key-value "street_type" (slot-value object 'json-schema.test.address:street-type))))

(let ((compile-encoder
          (jonathan:compile-encoder () (house-number street-name street-type)
            (list "house_number" house-number
                  "street_name" street-name
                  "street_type" street-type))))
  (defmethod jonathan:%to-json :around ((object json-schema.test.address::address))
             (funcall compile-encoder
               (slot-value object 'json-schema.test.address:house-number)
               (slot-value object 'json-schema.test.address:street-name)
               (slot-value object 'json-schema.test.address:street-type))))

(let ((compile-encoder
          (jonathan:compile-encoder () (house-number street-name street-type)
            (list "house_number" house-number))))
  (defmethod jonathan:%to-json :around ((object json-schema.test.address::address))
             (funcall compile-encoder
               (slot-value object 'json-schema.test.address:house-number))))


