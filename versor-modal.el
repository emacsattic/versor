;;;; versor-modal.el -- part of versatile cursor
;;; Time-stamp: <2003-10-16 16:53:04 john>

(provide 'versor-modal)
(require 'versor-names)

(defun versor:bind-modal (mode meta-level level action fn)
  "For MODE and META-LEVEL LEVEL, bind ACTION to call FN."
  (let* ((level-index-pair (versor:find-level-by-double-name meta-level level)))
    (if level-index-pair
	(let* ((meta-level-index (car level-index-pair))
	       (level-index (cdr level-index-pair))
	       (level-data (versor:current-level))
	       (level-all-modal-data (versor:action level-data 'modal-bindings))
	       (level-this-mode-bindings (assoc mode level-all-modal-data)))
	  (when (null level-all-modal-data)
	    (setq level-all-modal-data (list 'modal-bindings))
	    (rplacd level-data (cons level-all-modal-data
				     (cdr level-data))))
	  (when (null level-this-mode-bindings)
	    (setq level-this-mode-bindings (list mode))
	    (rplacd level-all-modal-data (cons level-this-mode-bindings
					       (cdr level-all-modal-data))))
	  (rplacd level-this-mode-bindings
		  (cons (cons action
			      fn)
			(cdr level-this-mode-bindings))))
      (error "Cannot bind action %s in mode %s, level %s:%s, because no such level is defined"
	     action mode meta-level level))))

;;;; modal bindings

(if (fboundp 'vm-summary-mode)
    (progn
      (versor:bind-modal 'vm-summary-mode "cartesian" "lines" 'previous 'vm-previous-message)
      (versor:bind-modal 'vm-summary-mode "cartesian" "lines" 'next 'vm-next-message)))

(versor:bind-modal 'emacs-lisp-mode "structural" "defuns" 'insert 'tempo-template-lisp-mode-definition-defun)

(versor:bind-modal 'html-helper-mode "text" "paragraphs" 'insert 'tempo-template-html-paragraph)

(versor:bind-modal 'html-helper-mode "tables" "cells" 'insert 'tempo-template-html-table-data)
(versor:bind-modal 'html-helper-mode "tables" "rows" 'insert 'tempo-template-html-table-row)
