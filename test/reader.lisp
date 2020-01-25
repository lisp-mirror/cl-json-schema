#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#
(in-package #:json-schema.test)

(defclass the-big-cheese-wheel ()
    ((cheese :json-key "cheese"
             :initarg :cheese))
  (:metaclass json-serializable-class))

(c2mop:finalize-inheritance (find-class 'the-big-cheese-wheel))

(parachute:define-test make-instance-from-json
  :parent json-schema.test
  
  (let* ((jsown-data '(:obj ("cheese" . "test-value")))
         (serializable-instance
          (make-instance-from-json (find-class 'the-big-cheese-wheel)
                                   (jonathan:to-json jsown-data :from :jsown))))
    (parachute:is #'string= "test-value" (slot-value serializable-instance 'cheese))))
