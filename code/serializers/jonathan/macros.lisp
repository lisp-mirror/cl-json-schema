#|
    Copyright (C) 2020 Gnuxie <Gnuxie@protonmail.com>

    This file contains modified work from jonathan
    https://github.com/Rudolph-Miller/jonathan
    Copyright (C) 2015 Rudolph-Miller

    See NOTICE.txt for details.

    All work (as defined by the NON-VIOLENT PUBLIC LICENSE v4+) in this file is
    licensed under the NON-VIOLENT PUBLIC LICENSE v4+

    See the attached LICENSE or https://thufie.lain.haus/NPL.html
    
|#

(in-package #:json-schema)

(defvar *first*)

(defmacro within-object (&body body)
  `(macrolet ((jonathan:write-key (key)
                `(progn
                   (if *first*
                       (setq *first* nil)
                       (jonathan.encode::%write-char #\,))
                   (jonathan.encode::string-to-json (princ-to-string ,key))))
              (jonathan::write-value (value)
                `(progn
                   (jonathan.encode::%write-char #\:)
                   ,(if (jonathan.encode::with-macro-p value)
                        value
                        `(jonathan.encode::%to-json ,value))))
              (jonathan::write-key-value (key value)
                `(progn
                   (jonathan.encode::write-key ,key)
                   (jonathan.encode::write-value ,value))))

     ,@body))

(defmacro with-object (&body body)
  `(let ((*first* t))
     (declare (special *first*))
     (within-object
      (jonathan.encode::%write-char #\{)
      ,@body
      (jonathan.encode::%write-char #\}))))
