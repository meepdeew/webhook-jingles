;; Handle in emacs initialization
;; (unless (package-installed-p 'emms)
;;   (package-refresh-contents)
;;   (package-install 'emms))
;; (add-to-list 'load-path "~/elisp/emms/")
;; (require 'emms-setup)
;; (emms-standard)
;; (emms-default-players)

;; (unless (package-installed-p 'elnode)
;;   (package-refresh-contents)
;;   (package-install 'elnode))

(require 'json)
(require 'elnode)
(require 'cl-lib)

(defun pluck-item-with-car (listo test)
  (let ((head (car listo))
	(tail (cdr listo)))
    (if (and (listp head)
	     (equal (car head) test))
	head
      (pluck-item-with-car tail test))))

(defcustom receiver-port 8010
  "The port number at which to listen."
  :group 'receiver
  :type 'integer)

(setq nwlc "
")

(defun receiver--handler (httpcon)
  "The elnode response handler.  HTTPCON: the elnode request map."
  (with-current-buffer (process-buffer httpcon)
    (let* ((req (buffer-substring-no-properties (point-min) (point-max)))
	   (pieces (split-string req nwlc))
	   (payload (car (last pieces)))
	   (data (json-read-from-string payload))
	   ;; specific to the response format (GitHub, BitBucket, etc.)
	   (pull-req (pluck-item-with-car data 'pullrequest))
	   (source (pluck-item-with-car pull-req 'source))
	   (src-branch (pluck-item-with-car source 'branch))
	   (src-name (cdr (car (cdr src-branch))))
	   (destination (pluck-item-with-car pull-req 'destination))
	   (dst-branch (pluck-item-with-car destination 'branch))
	   (dst-name (cdr (car (cdr dst-branch))))
	   (actor (pluck-item-with-car data 'actor))
	   (actor-name (cdr (pluck-item-with-car actor 'display_name))))
      ;; logic based on name, etc...
      (print (format "%s: %s->%s" actor-name src-name dst-name))
      (emms-play-file "./korok-seed-breath-of-the-wild.mp3")
      (elnode-http-start httpcon 200 '("Content-type" . "text/plain"))
      (elnode-http-return httpcon "response body"))))

(elnode-start 'receiver--handler :port receiver-port)

;; (elnode-stop receiver-port)

