#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.test)

(defun run (&key (report 'parachute:plain))
  (parachute:test 'json-schema.test :report report))

(defun ci-run ()
  (setf (verbose:repl-level) :debug)
  (let ((test-result (run)))
    (when (not (null (parachute:results-with-status :failed test-result)))
      (uiop:quit -1))))
