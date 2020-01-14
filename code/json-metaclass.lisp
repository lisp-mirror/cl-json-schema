#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>

    This file is a part of json-schema

    This file contains modified work from https://github.com/gschjetne/json-mop
    Copyright (C) 2015 Grim Schjetne
    See NOTICE.txt for details.

    All work (as defined by the NON-VIOLENT PUBLIC LICENSE v2) in this file is
    licensed under the NON-VIOLENT PUBLIC LICENSE v2

    See the attached LICENSE or https://thufie.lain.haus/NPL.html

|#

(in-package #:json-schema)

(defclass json-serializable-class (closer-mop:standard-class) ())

(defmethod closer-mop:validate-superclass ((class json-serializable-class)
                                           (super closer-mop:standard-class))
  t)

(defmethod closer-mop:validate-superclass ((class standard-class)
                                           (super json-serializable-class))
  t)

(defclass json-serializable-slot (closer-mop:standard-direct-slot-definition)
  ((json-key :initarg :json-key
             :initform nil
             :reader json-key-name)
   (json-type :initarg :json-type
              :initform :any
              :reader json-type)))

(defmethod closer-mop:direct-slot-definition-class ((class json-serializable-class)
                                                    &rest initargs)
  (declare (ignore class initargs))
  (find-class 'json-serializable-slot))

(defclass json-serializable () ())

(defmethod slot-key-pair ((object json-serializable) (slot json-serializable-slot) slot-name)
  (cons (json-key-name slot) (slot-value object slot-name)))

(defmethod jsown:to-json ((object json-serializable))
  (let ((json
         `(:obj ,@(loop :for class :in (c2mop:class-precedence-list (class-of object))
                     :appending
                       (loop
                          :for slot :in (c2mop:class-direct-slots class) :append
                            (let* ((slot-name (c2mop:slot-definition-name slot)))
                              (when (slot-boundp object slot-name)
                                  (list (slot-key-pair object slot slot-name)))))))))
    (jsown:to-json json)))

(defmethod c2mop:class-direct-superclasses ((class json-serializable-class))
  (append (remove (find-class 'standard-object) (call-next-method))
          (list (find-class 'json-serializable)
                (find-class 'standard-object))))
