#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#
(in-package #:json-schema.test)

(defclass the-big-cheese-wheel ()
    ((cheese :json-key "cheese"
             :initarg :cheese))
    (:metaclass json-serializable-class))

(parachute:define-test make-instance-from-json
  
  (let* ((jsown-data '(:obj ("cheese" . "test-value")))
         (serializable-instance
          (make-instance-from-json-using-serial (find-class 'the-big-cheese-wheel) jsown-data)))
    (parachute:is #'string= "test-value" (slot-value serializable-instance 'cheese))))
