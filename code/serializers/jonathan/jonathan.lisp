#|
    Copyright (C) 2019-2020 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.jonathan)

(defmethod slot-serializer (slot effective-slotd class instance-var)
  (declare (ignore effective-slotd class))
  (let ((slot-name (c2mop:slot-definition-name slot)))
    `(when (slot-boundp ,instance-var ',slot-name)
       (jonathan:write-key-value
        ,(json-key-name slot)
        (slot-value object ',slot-name)))))

(defmethod create-encoder ((class json-serializable-class))
  `(defmethod jonathan:%to-json :around ((object ,(class-name class)))
     (jonathan:with-object
       ,@ (loop :for ((effective-slotd slot))
             :on (json-schema.mop:slot-precedence-list class)
             :collect (slot-serializer slot effective-slotd class 'object)))))

(defmethod serialize-slot ((slot json-serializable-slot) effective-slotd class instance)
  (within-object
    (when (c2mop:slot-boundp-using-class class instance effective-slotd)
      (jonathan:write-key-value
       (json-key-name slot)
       (c2mop:slot-value-using-class class instance effective-slotd)))))

(defmethod jonathan:%to-json ((object json-serializable))
  (let ((class (class-of object)))
    (with-object
      (loop :for ((effective-slotd slot))
         :on (json-schema.mop:slot-precedence-list class)
         :do (serialize-slot slot effective-slotd class object)))))

(defun key-normalizer (string)
  (declare (type string string))
  (declare (optimize (speed 3) (safety 0)))
  (loop :for c :across string
     :for i :from 0 :by 1 :do
       (setf (aref string i)
             (let ((char (char-upcase c)))
               (if (eql char #\_)
                   #\-
                   char))))
  string)


(defmethod json-schema.mop:make-instance-from-json ((class json-serializable-class)
                                                    json)
  (apply #'make-instance class
         (jonathan:parse json :keyword-normalizer #'key-normalizer)))

