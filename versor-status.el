;;; versor-status.el -- versatile cursor
;;; Time-stamp: <2004-05-24 09:59:11 john>
;;
;; emacs-versor -- versatile cursors for GNUemacs
;;
;; Copyright (C) 2004  John C. G. Sturdy
;;
;; This file is part of emacs-versor.
;; 
;; emacs-versor is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.
;; 
;; emacs-versor is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with emacs-versor; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

(provide 'versor-status)

;; Display the current meta-dimension and dimension etc

(defvar versor:multi-line-level-display (and (boundp 'emacs-major-version)
					     (>= emacs-major-version 21))
  "*Whether to use multi-line indication of the current meta-level and level.")

(defun versor:set-status-display (&optional one of-these explicit)
  "Indicate the state of the versor system."
  (setq versor:current-level-name (first (versor:current-level))
	versor:current-meta-level-name (aref (versor:current-meta-level) 0))
  (if (and versor:multi-line-level-display explicit)
      (versor:display-dimensions-2d)
    (if one
	(if of-these
	    (versor:display-highlighted-choice one of-these)
	  (if (stringp one)
	      (message one)))
      (message (first (versor:current-level)))))
  (if versor:reversible
      (setq versor:mode-line-begin-string (if versor:reversed " <==" " <")
	    versor:mode-line-end-string (if versor:reversed ">" "==>"))
    (setq versor:mode-line-begin-string " <"
	  versor:mode-line-end-string ">"))
  (force-mode-line-update t)
  (when versor-change-cursor-color 
    (set-cursor-color (versor:action (versor:current-level) 'color)))
  (when (and versor-item-attribute (fboundp 'set-face-attribute))
    (set-face-attribute 'versor-item nil
			versor-item-attribute
			(versor:action (versor:current-level)
				       versor-item-attribute)))
  (let ((old-pair (assoc major-mode versor:mode-current-levels)))
    (if (null old-pair)
	(push (cons major-mode (cons versor:meta-level versor:level))
	      versor:mode-current-levels)
      (rplaca (cdr old-pair) versor:meta-level)
      (rplacd (cdr old-pair) versor:level))))

(defun versor:highlighted-string (string)
  "Return a highlighted version of STRING."
  (if versor:use-face-attributes
      (let ((strong (copy-sequence string)))
	(put-text-property 0 (length string)
			   'face 'versor-item
			   strong)
	strong)
    (format "[%s]" string)))

(defun versor:display-highlighted-choice (one of-these-choices)
  "Display, with ONE highlighted, the members of OF-THESE-CHOICES"
  (let* ((msg (mapconcat
	       (lambda (string)
		 (if (string= string one)
		     (versor:highlighted-string string)
		   string))
	       of-these-choices
	       ", ")))
    (message msg)))

(defvar versor:max-meta-name-length nil
  "The length of the longest meta-level name.
Used for display purposes, and cached here.")

(defun versor:display-dimensions-2d ()
  "Indicate the current meta-level and level, in a multi-line message."
  (interactive)
  (unless versor:max-meta-name-length
    (setq versor:max-meta-name-length
	  (apply 'max
		 (mapcar 'length
			 (mapcar 'car
				 (versor:meta-level-names))))))
  (message
   (let ((meta-levels-name-format-string (format "%% %ds" versor:max-meta-name-length)))
     (mapconcat
      'identity
      (let ((meta (1- (length moves-moves)))
	    (formats (reverse (versor:all-names-grid-formats)))
	    (result nil))
	(while (>= meta 1)
	  (let* ((meta-data (aref moves-moves meta))
		 (meta-name (aref meta-data 0))
		 (inner-result nil)
		 (row-formats formats)
		 (level 1)
		 (n-level (length meta-data)))
	    (while row-formats
	      (let* ((level-name-raw 
		      (if (< level n-level)
			  (first (aref meta-data level))
			""))
		     (level-name (format (car row-formats) level-name-raw)))
		(push
		 (if (and (= meta versor:meta-level)
			  (= level versor:level))
		     (versor:highlighted-string level-name)
		   level-name)
		 inner-result)
		(setq row-formats (cdr row-formats))
		(incf level)))
	    (push
	     (concat
	      (format meta-levels-name-format-string
		      (if (= meta versor:meta-level)
			  (versor:highlighted-string meta-name)
			meta-name))
	      ": "
	      (mapconcat 'identity inner-result " "))
	     result)
	    (decf meta)))
	result)
      "\n"))))

;;;; end of versor-status.el