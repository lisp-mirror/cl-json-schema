#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

(in-package #:json-schema.test.postgres)

(defun run (&key (report 'parachute:plain))
  (parachute:test 'json-schema.test.postgres:test-postgres :report report))

(defun ci-run ()
  (postmodern:connect-toplevel "testdb" "test" "test" "testdb")
  (let ((test-result (run)))
    (unless (null (parachute:results-with-status :failed test-result))
      (uiop:quit -1))))

