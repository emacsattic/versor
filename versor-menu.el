;;;; versor-menu.el -- part of dimensional navigation
;;; Time-stamp: <2003-10-22 14:18:36 john>

;;; If you have even fewer keys than normal available for versor (for
;;; example, a more restricted set of input than that arranged by
;;; versor-pedals) you may need a menu for some of the actions -- for
;;; example, reversing motion if you only have a "move" key rather
;;; than a "next" and "previous" pair

(provide 'versor-menu)
(require 'versor)
(require 'versor-names)

(defvar versor-control-menu-items
  `(["Out briefly" versor:out-briefly-only t]
    ["Backwards" versor:reverse [ :included (and versor:reversible (not versor:reversed))]]
    ["Forwards" versor:reverse [ :included (and versor:reversible versor:reversed)]]
    ["Set level" versor:select-named-level t]
    ["Set meta-level" versor:select-named-meta-level t]
    ["Copy" versor:copy t]
    ["Kill" versor:kill t]
    ["Mark" versor:mark t]
    )
  "Control of versor.")

(easy-menu-define versor-control-menu nil
                  "Versor Control Menu" (cons "Versor control" versor-control-menu-items))

(defun versor:control-menu ()
  "Run the versor control menu."
  (interactive)
  (tmm-prompt versor-control-menu)
  ;; return t because we can be used in aux-pedal (pedals.el) as a hook
  t)

(defun versor:add-menu-item (menu name command)
  "Add to MENU an item made from NAME and COMMAND."
  (rplacd (cdr menu)
	  (cons
	   (list (intern name) 'menu-item name command)
	   (cdr (cdr menu)))))

(defun versor:generate-dynamic-menu ()
  "Generate dynamic menu for versor.
Allows various actions that depend on the current fine movement dimension."
  (let ((dynamic-menu (make-sparse-keymap "Versor dynamic menu")))
    (mapcar (function
	     (lambda (name-command)
	       (let* ((raw-name (car name-command))
		      (formatted-name (format raw-name versor:current-level-name))
		      )
		 (versor:add-menu-item dynamic-menu formatted-name (cdr name-command)))))
	    '(
	      ("yank" . yank)
	      ("kill %s" . versor:kill)
	      ("versor control" . versor:control-menu)
	      ;; cannibalize ~/open-projects/emacs-pedals/handsfree-tools-menus.el for
	      ;; more to go here
	      ("copy region" . kill-ring-save)
	      ("mark %s" . versor:mark)
	      ("copy %s" . versor:copy)
	      ))
    dynamic-menu))

(defun versor:do-dynamic-menu ()
  "Dynamic menu for versor.
Allows various actions that depend on the current fine movement dimension."
  (interactive)
  (tmm-prompt (versor:generate-dynamic-menu)))


;;;;experimental!!!!!!!!!!!!!!!!

(defun inform-about (string)
  "Tell the user something about STRING.
This will try the help system, tag files etc."
  (interactive "sInformation about: ")
  (let* ((symbol (intern-soft string))
	 (information
	  (cond
     ((and symbol
	   (documentation symbol)))
     (t
      "no information about %s" string))))
    (message "%s" information)
    information))