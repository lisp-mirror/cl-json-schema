#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema)

;;; base method
(defmethod jonathan:%to-json ((object json-serializable))
  (jonathan:with-object
    (loop :for class :in (c2mop:class-precedence-list (class-of object)) :do
         (loop
            :for slot :in (c2mop:class-direct-slots class) :do
              (let* ((slot-name (c2mop:slot-definition-name slot)))
                (when (slot-boundp object slot-name)
                  (jonathan:write-key-value (json-key-name slot)
                                            (slot-value object slot-name))))))))

;;; faster method, would be nice if we could use the compile-encoder
;;; but it doesn't account for unbound slots.
(defun %to-json<-finalized-class (class)
  (declare (type json-serializable-class class))
  `(defmethod jonathan:%to-json :around ((object ,(class-name class)))
     (jonathan:with-object
       ,@(loop :for slot :in (c2mop:class-direct-slots class) :collect
              (let ((slot-name (c2mop:slot-definition-name slot)))
                `(when (slot-boundp object ',slot-name)
                   (jonathan:write-key-value
                    ,(json-key-name slot)
                    (slot-value object ',slot-name))))))))

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


(defmethod make-instance-from-json ((class json-serializable-class) json)
  (apply #'make-instance class
         (jonathan:parse json :keyword-normalizer #'key-normalizer)))
