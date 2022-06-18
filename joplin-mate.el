(require 'cl-lib)
(require 'url)
(require 'request)
(require 'json)

(defvar joplin-mate-token nil
  "joplin token")

(defvar joplin-mate-auth-token nil
  "joplin auth token")

(defvar joplin-mate-server-alive nil
  "check joplin server alive")

(defconst joplin-mate-url "http://localhost:41184"
  "joplin server url")

(defun joplin-mate--check-server ()
  "check joplin is alive"

  (request (concat joplin-mate-url "/ping")
    :parser (lambda () (buffer-string))
    :error (cl-function
	    (lambda (&rest args &key error-thrown &allow-other-keys)
	      (message "%s" error-thrown)))
    :success (cl-function
	      (lambda (&key data &allow-other-keys)
		(if
		    (string= data "JoplinClipperServer")
		    (setq joplin-mate-server-alive t)
		  (message "not ok"))))))


(defun joplin-mate--get-token ()
  "get token"

  (request (concat joplin-mate-url "/auth/check?auth_token=" joplin-mate-auth-token)
    :parser 'json-read
    :error (cl-function
	    (lambda (&rest args &key error-thrown &allow-other-keys)
	      (message "%s" error-thrown)))
    :success (cl-function
	      (lambda (&key data &allow-other-keys)
		(message "%s" data)))))

(defun joplin-mate--auth ()
  "auth"
  (message "do joplin-mate--auth")

  (joplin-mate--check-server)


  ;; (request (concat joplin-mate-url "/auth/check?token=null")
  ;; :parser 'json-read
  ;; :error (cl-function
  ;; 	  (lambda (&rest args &key error-thrown &allow-other-keys)
  ;; 	    (message "%s" error-thrown)))
  ;; :success (cl-function
  ;; 	    (lambda (&key data &allow-other-keys)
  ;; 	      (message "%s" data))))


  (request (concat joplin-mate-url "/auth")
    :type "POST"
    :parser 'json-read
    :error (cl-function
	    (lambda (&rest args &key error-thrown &allow-other-keys)
	      (message "%s" error-thrown)))
    :success (cl-function
	      (lambda (&key data &allow-other-keys)
		(setq joplin-mate-auth-token
		      (cdr (assoc 'auth_token data)))))))

(defun send-to-joplin ()
  "send to joplin"
  (interactive "P")

  (if (not 'joplin-mate-auth)
      (message "do auth")
    (joplin-mate--auth)))

(provide 'joplin-mate)
