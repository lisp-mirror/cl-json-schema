#|
    Copyright (C) 2019-2020 Gnuxie <Gnuxie@protonmail.com>

    This file is a part of json-schema

    This file contains modified work from https://github.com/gschjetne/json-mop
    Copyright (C) 2015 Grim Schjetne
    See NOTICE.txt for details.

    All work (as defined by the NON-VIOLENT PUBLIC LICENSE v4+) in this file is
    licensed under the NON-VIOLENT PUBLIC LICENSE v4+

    See the attached LICENSE or https://thufie.lain.haus/NPL.html

|#

(in-package #:json-schema.mop)

(defclass json-serializable-class (closer-mop:standard-class)
  ((%slot-precedence-list :reader slot-precedence-list
                          :type list
                          :documentation "
like the class-precedence-list except this list is sorted by json-key-name
of the slots, so that the json can easily be made canonical.
")))

(defmethod c2mop:finalize-inheritance ((class json-serializable-class))
  (prog1 (call-next-method class)
    (setf (slot-value class '%slot-precedence-list)
          (compute-slot-precedence-list class))))

(defmethod compute-slot-precedence-list ((class json-serializable-class))
  "yes, this is taken from SB-PCL."
  (let ((name-dslots-alist '()))
    (dolist (c (reverse (c2mop:class-precedence-list class)))
      (dolist (slot (c2mop:class-direct-slots c))
        (when (typep slot 'json-serializable-slot)
          (let* ((name (c2mop:slot-definition-name slot))
                 (entry (assoc name name-dslots-alist)))
            (if entry
                (push slot (cdr entry))
                (push (list name slot) name-dslots-alist))))))
    (let ((effective-definitions (c2mop:class-slots class)))
      (sort
       (loop :for ((name slot &rest other-slots)) :on name-dslots-alist :collect
            (let ((effective-slot (find name effective-definitions
                                        :key #'c2mop:slot-definition-name)))
              (list effective-slot slot)))
       #'string<
       :key (lambda (slot-list)
              (destructuring-bind (effective-slot top-slot) slot-list
                (declare (ignore effective-slot))
                (json-key-name top-slot)))))))

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

(defmethod c2mop:class-direct-superclasses ((class json-serializable-class))
  (append (remove (find-class 'standard-object) (call-next-method))
          (list (find-class 'json-serializable)
                (find-class 'standard-object))))

