#|
    Copyright (C) 2019 Gnuxie <Gnuxie@protonmail.com>
|#

#+sbcl (setf sb-ext:*derive-function-types* t)

(ql:register-local-projects)
(ql:update-dist "quicklisp" :prompt nil)
(ql:quickload :json-schema.test)
(json-schema.test:ci-run)
(ql:quickload :json-schema.test.postgres)
(json-schema.test.postgres:ci-run)
