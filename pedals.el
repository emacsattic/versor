;;;; pedals.el -- set up the six-pedal system
;;; Time-stamp: <2004-01-26 14:48:29 john>
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

(provide 'pedals)

(require 'versor)
(require 'versor-menu)

(require 'structure-edit)

;;;; packages / modes for which we add key definitions
;;; uncomment these as needed
;; (require 'info)
;; (require 'yank-menu)
;; (require 'dired)
;; (require 'gud)
;; (require 'autocue)
;; (require 'vm)

(defvar pedals-hosts-preferring-num-lock
  '("hosea")
  "Hosts on which the pedals appear to work better with the keypad in num lock mode.")

(defun handsfree-use-num-lock ()
  "Whether the pedals appear to work better with the keypad in num lock mode on this system."
  (member (downcase (system-name)) pedals-hosts-preferring-num-lock))

(defvar pedal-aux nil
  "The aux pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-C-aux nil
  "The C-aux pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-M-aux nil
  "The M-aux pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-S-aux nil
  "The S-aux pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-C-S-aux nil
  "The C-S-aux pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-M-S-aux nil
  "The M-S-aux pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-C-M-S-aux nil
  "The C-M-S-aux pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-onward nil
  "The onward pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-C-onward nil
  "The C-onward pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-M-onward nil
  "The M-onward pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-S-onward nil
  "The S-onward pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-C-S-onward nil
  "The C-S-onward pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-M-S-onward nil
  "The M-S-onward pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-C-M-S-onward nil
  "The C-M-S-onward pedal.
This symbol may be given inside a vector to define-key etc")


(defvar pedal-menu nil
  "The menu pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-C-menu nil
  "The C-menu pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-M-menu nil
  "The M-menu pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-S-menu nil
  "The S-menu pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-C-S-menu nil
  "The C-S-menu pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-M-S-menu nil
  "The M-S-menu pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedal-C-M-S-menu nil
  "The C-M-S-menu pedal.
This symbol may be given inside a vector to define-key etc")

(defvar pedals-use-kp-divide t
  ;; maybe should be t on WinNT and nil elsewhere?
  "Whether to use kp-divide instead of kp-down")

(defun pedals-setup-codes ()
  "Set up the pedal codes"
  ;; I had great trouble getting a setup that would work on NTemacs,
  ;; but eventually found that it was describe-key that was giving the
  ;; impression that the Shift modifier did not work on the keypad
  ;; arrow keys. Hence, all this stuff about num-lock, which I hope to
  ;; get rid of once I've verified that it is in fact OK.
  (let ((num-lock (handsfree-use-num-lock)))
    (cond
     ((eq system-type 'gnu/linux)
      (message "Setting up pedals as for gnu/linux")
      (setq pedal-aux [ kp-down ]
	    pedal-C-aux [ C-kp-down ]
	    pedal-M-aux [ M-kp-down ]
	    pedal-S-aux [ S-kp-2 ]
	    pedal-C-S-aux [ C-S-kp-2 ]
	    pedal-M-S-aux [ M-S-kp-2 ]

	    pedal-onward [ kp-right ]
	    pedal-C-onward [ C-kp-right ]
	    pedal-M-onward [ M-kp-right ]
	    pedal-S-onward [ S-kp-6 ]
	    pedal-C-S-onward [ C-S-kp-6 ]
	    pedal-M-S-onward [ M-S-kp-6 ]

	    pedal-menu [ kp-end ]
	    pedal-C-menu [ C-kp-end ]
	    pedal-M-menu [ M-kp-end ]
	    pedal-S-menu [ S-kp-1 ]
	    pedal-C-S-menu [ C-S-kp-1 ]
	    pedal-M-S-menu [ M-S-kp-1 ]

	    pedal-v-1 [ kp-up ]
	    pedal-C-v-1 [ C-kp-up ]
	    pedal-M-v-1 [ M-kp-up ]
	    pedal-S-v-1 [ S-kp-8 ]
	    pedal-C-S-v-1 [ C-S-kp-8 ]
	    pedal-M-S-v-1 [ M-S-kp-8 ]

	    pedal-v-2 [ kp-left ]
	    pedal-C-v-2 [ C-kp-left ]
	    pedal-M-v-2 [ M-kp-left ]
	    pedal-S-v-2 [ S-kp-4 ]
	    pedal-C-S-v-2 [ C-S-kp-4 ]
	    pedal-M-S-v-2 [ M-S-kp-4 ]

	    pedal-v-3 [ kp-home ]
	    pedal-C-v-3 [ C-kp-home ]
	    pedal-M-v-3 [ M-kp-home ]
	    pedal-S-v-3 [ S-kp-7 ]
	    pedal-C-S-v-3 [ C-S-kp-7 ]
	    pedal-M-S-v-3 [ M-S-kp-7 ]
	    )
      )
     (pedals-use-kp-divide
      (message "Setting up pedals using kp-divide for onward")
      (setq
       pedal-onward [ kp-divide ]
       pedal-C-onward [ C-kp-divide ]
       pedal-M-onward [ M-kp-divide ]
       pedal-S-onward [ S-kp-divide ]
       pedal-C-S-onward [ C-S-kp-divide ]
       pedal-M-S-onward [ M-S-kp-divide ]
       pedal-C-M-S-onward [ C-M-S-kp-divide ]
       pedal-aux [ kp-end ]
       pedal-C-aux [ C-kp-end ]
       pedal-M-aux [ M-kp-end ]
       pedal-S-aux [ S-kp-1 ]
       pedal-C-S-aux [ C-S-kp-1 ]
       pedal-M-S-aux [ M-S-kp-1 ]
       pedal-C-M-S-aux [ C-M-S-kp-1 ]

       pedal-menu [ kp-next ]
       pedal-C-menu [ C-kp-next ]
       pedal-M-menu [ M-kp-next ]
       pedal-S-menu [ S-kp-3 ]
       pedal-C-S-menu [ C-S-kp-3 ]
       pedal-M-S-menu [ M-S-kp-3 ]
       pedal-C-M-S-menu [ C-M-S-kp-3 ]
       )
      )
     (t
      (message "Using default pedal setup")
      (setq
	   pedal-onward [ kp-down ]
	   pedal-C-onward [ C-kp-down ]
	   pedal-M-onward [ M-kp-down ]
	   pedal-S-onward [ S-kp-2 ]
	   pedal-C-S-onward [ C-S-kp-2 ]
	   pedal-M-S-onward [ M-S-kp-2 ]
	   pedal-C-M-S-onward [ C-M-S-kp-2 ]
	   pedal-aux [ kp-end ]
	   pedal-C-aux [ C-kp-end ]
	   pedal-M-aux [ M-kp-end ]
	   pedal-S-aux [ S-kp-1 ]
	   pedal-C-S-aux [ C-S-kp-1 ]
	   pedal-M-S-aux [ M-S-kp-1 ]
	   pedal-C-M-S-aux [ C-M-S-kp-1 ]

	   pedal-menu [ kp-next ]
	   pedal-C-menu [ C-kp-next ]
	   pedal-M-menu [ M-kp-next ]
	   pedal-S-menu [ S-kp-3 ]
	   pedal-C-S-menu [ C-S-kp-3 ]
	   pedal-M-S-menu [ M-S-kp-3 ]
	   pedal-C-M-S-menu [ C-M-S-kp-3 ])))))

(defun pedals-test-keys ()
  "Read key events and display what they were.
Useful for exploring which keys can be read with all modifiers,
which are most suitable for duplicating onto pedals."
  (interactive)
  (let ((key (read-event "Key (space to end): ")))
    (while (not (equal key ? ))
      (setq key (read-event (format "That was %s; next key (space to end): "
				    (key-description (list key))))))))

(defvar pedal:versor-change-dimension-ctrl nil
  "*Whether the control pedal should make versor movements switch dimension.
This is the function normally assigned to meta and a versor movement, but
pedal physical layout may make it more convenient to put it on control.")

(defun pedals-setup ()
  "Set up the six-switch system.
In general:
  the middle pedal of the right cluster does fine movements;
  the right pedal brings up a menu or picks an item;
  the left pedal does coarse movements.
See versor.el (versatile cursors) for fine and coarse movements.
See handsfree-menus.el for menus."
  (interactive)

  (versor:setup)

  (pedals-setup-codes)

  ;; left pedal of right cluster -- misc things at point
  (global-set-key pedal-aux 'versor:over-next)
  (global-set-key pedal-S-aux 'versor:over-prev)

  (global-set-key pedal-C-aux (if pedal:versor-change-dimension-ctrl
				  'versor:next-meta-level
				'wander-yank))
  (global-set-key pedal-C-S-aux (if pedal:versor-change-dimension-ctrl
				    'versor:prev-meta-level
				  'pick-up-sexp-at-point))

  (global-set-key pedal-M-aux (if pedal:versor-change-dimension-ctrl
				  'wander-yank
				'versor:next-meta-level))
  (global-set-key pedal-M-S-aux (if pedal:versor-change-dimension-ctrl
				    'pick-up-sexp-at-point
				  'versor:prev-meta-level))

  ;; middle pedal of right cluster -- dimensional navigation
  (global-set-key pedal-onward 'versor:next)
  (global-set-key pedal-S-onward 'versor:prev)

  (global-set-key pedal-C-onward (if pedal:versor-change-dimension-ctrl
				     'versor:in
				   'versor:end))
  (global-set-key pedal-C-S-onward (if pedal:versor-change-dimension-ctrl
				       'versor:out
				     'versor:start))

  (global-set-key pedal-M-onward (if pedal:versor-change-dimension-ctrl
				     'versor:end
				   'versor:in))
  (global-set-key pedal-M-S-onward (if pedal:versor-change-dimension-ctrl
				       'versor:start
				     'versor:out))

  ;; right pedal of right cluster -- menus, yank, repeat, undo, quit
  (global-set-key pedal-menu 'handsfree-main-menu)
;;  (global-set-key pedal-S-menu 'handsfree-popup-tools-menu)
  (global-set-key pedal-S-menu 'versor:do-dynamic-menu)

  (global-set-key pedal-C-menu 'other-window )
  (global-set-key pedal-C-S-menu 'repeat-complex-command )

  (global-set-key pedal-M-menu 'move-sexp-from-point) ; should become "select value"?
  (global-set-key pedal-M-S-menu 'keyboard-quit )

;;  (global-set-key pedal-C-M-S-aux 'describe-key )
;;  (global-set-key pedal-C-M-S-onward 'foo )

  ;; minibuffer -- left pedal is "expand", middle is "navigate", right is "do it"
  (mapcar
   (function
    (lambda (map-name)
      (let* ((map (eval map-name))
	     (upkey (lookup-key map [ up ]))
	     (downkey (lookup-key map [ down ]))
	     (returnkey (lookup-key map "\n")))
	(message "in map %S" map-name)
	(message "  down is %S, up is %S, return is %S" downkey upkey returnkey)
	(define-key map pedal-aux
	  'minibuffer-blank ;; (lookup-key map " ")
	  )
	(define-key map pedal-S-aux (lookup-key map "\t"))

	(message "  Defining %S to do %S" pedal-onward downkey)
	(define-key map pedal-onward downkey)
	(message "  Defining %S to do %S" pedal-S-onward upkey)
	(define-key map pedal-S-onward upkey)
	(define-key map pedal-C-S-onward 'keyboard-escape-quit)

	(define-key map pedal-menu returnkey)
	(define-key map pedal-S-menu returnkey)
	)))
   '(minibuffer-local-map
     minibuffer-local-ns-map
     minibuffer-local-completion-map
     minibuffer-local-must-match-map
     read-expression-map))

  ;; modal -- generally right pedal is "do it", shift-right is "delete"
  ;;                    middle pedal is "next"
  ;;                    left pedal is "do something else with it"
  (define-key isearch-mode-map pedal-onward 'isearch-repeat-forward)
  (define-key isearch-mode-map pedal-aux 'isearch-yank-word)
  (define-key isearch-mode-map pedal-S-onward 'isearch-repeat-backward)

  (if (and (boundp 'Buffer-menu-mode-map)
	   (keymapp Buffer-menu-mode-map))
      (progn
	(define-key Buffer-menu-mode-map pedal-onward 'next-line)
	(define-key Buffer-menu-mode-map pedal-S-onward 'previous-line)
	(define-key Buffer-menu-mode-map pedal-M-onward 'end-of-buffer)
	(define-key Buffer-menu-mode-map pedal-M-S-onward 'beginning-of-buffer)
	(define-key Buffer-menu-mode-map pedal-menu 'Buffer-menu-select)
	(define-key Buffer-menu-mode-map pedal-S-menu 'Buffer-menu-delete)))

  (if (and (boundp 'dired-mode-map)
	   (keymapp dired-mode-map))
      (progn
	(define-key dired-mode-map pedal-onward 'dired-next-line)
	(define-key dired-mode-map pedal-S-onward 'dired-previous-line)
	(define-key dired-mode-map pedal-C-onward 'dired-prev-subdir)
	(define-key dired-mode-map pedal-C-S-onward 'dired-next-subdir)
	(define-key dired-mode-map pedal-M-onward 'dired-tree-up)
	(define-key dired-mode-map pedal-M-S-onward 'dired-tree-down)
	(define-key dired-mode-map pedal-menu 'dired-find-file-or-insert-subdir)
	(define-key dired-mode-map pedal-S-menu 'dired-flag-file-deletion)
	(define-key dired-mode-map [ C-kp-3 ] 'revert-buffer)
	(define-key dired-mode-map pedal-C-S-menu 'dired-do-flagged-delete)
	(define-key dired-mode-map pedal-M-S-menu 'kill-buffer)))

  (if (and (boundp 'vm-summary-mode-map)
	   (keymapp vm-summary-mode-map))
      (progn
	(define-key vm-summary-mode-map pedal-aux 'vm-scroll-forward)
	(define-key vm-summary-mode-map pedal-S-aux 'vm-scroll-backward)
	(define-key vm-summary-mode-map pedal-onward 'vm-next-message)
	(define-key vm-summary-mode-map pedal-S-onward 'previous-line)
	(define-key vm-summary-mode-map pedal-menu 'exit-recursive-edit ) ; because I normally run the mailer in a recursive edit
	(define-key vm-summary-mode-map pedal-S-menu 'vm-delete-message)
	(define-key vm-summary-mode-map pedal-C-S-menu 'vm-expunge-folder)
	(define-key vm-summary-mode-map pedal-M-menu 'handsfree-main-menu)
	(define-key vm-summary-mode-map pedal-M-S-menu 'handsfree-popup-tools-menu)))

  (if (boundp 'w3-mode-map)
      (progn
	(define-key w3-mode-map pedal-onward 'scroll-up)
	(define-key w3-mode-map pedal-S-onward 'scroll-down)
	(define-key w3-mode-map pedal-aux 'w3-widget-forward)
	(define-key w3-mode-map pedal-S-aux 'w3-widget-backward)
	(define-key w3-mode-map pedal-menu 'widget-button-press)
	(define-key w3-mode-map pedal-S-menu 'w3-prev-document)))

  (if (boundp 'gnus-group-mode-map)
      (progn
	(define-key gnus-group-mode-map pedal-aux 'gnus-group-catchup-current)
	(define-key gnus-group-mode-map pedal-S-aux 'gnus-group-exit)
	(define-key gnus-group-mode-map pedal-onward 'next-line)
	(define-key gnus-group-mode-map pedal-S-onward 'previous-line)
	(define-key gnus-group-mode-map pedal-menu 'gnus-group-select-group)
	(define-key gnus-group-mode-map pedal-S-menu 'gnus-group-read-group)))

  (if (and (boundp 'gnus-summary-mode-map)
	   (keymapp gnus-summary-mode-map))
      (progn
	(define-key gnus-summary-mode-map pedal-aux 'gnus-summary-tick-article-forward)
	(define-key gnus-summary-mode-map pedal-S-aux 'gnus-summary-followup)
	(define-key gnus-summary-mode-map pedal-onward 'gnus-summary-next-page)
	(define-key gnus-summary-mode-map pedal-S-onward 'gnus-summary-previous-page)
	(define-key gnus-summary-mode-map pedal-menu 'gnus-summary-exit)
	(define-key gnus-summary-mode-map pedal-S-menu 'gnus-summary-catchup-and-exit)))

  (if (and (boundp 'Info-mode-map)
	   (keymapp Info-mode-map))
      (progn
	(define-key Info-mode-map pedal-aux 'Info-forward-node)
	(define-key Info-mode-map pedal-S-aux 'Info-backward-node)
	(define-key Info-mode-map pedal-C-aux 'Info-follow-reference)
	(define-key Info-mode-map pedal-C-S-aux 'Info-last)
	(define-key Info-mode-map pedal-onward 'Info-scroll-up)
	(define-key Info-mode-map pedal-S-onward 'Info-scroll-down)
	(define-key Info-mode-map pedal-menu 'Info-exit)
	(define-key Info-mode-map pedal-S-menu 'Info-menu)
))

  (if (and (boundp 'yank-menu-map)
	   (keymapp yank-menu-map))
      (progn
	(define-key yank-menu-map pedal-onward 'yank-menu-next)
	(define-key yank-menu-map pedal-S-onward 'yank-menu-previous)
	(define-key yank-menu-map pedal-M-S-onward 'yank-menu-top)
	(define-key yank-menu-map pedal-M-onward 'yank-menu-bottom)
	(define-key yank-menu-map pedal-menu 'yank-menu-insert)
	(define-key yank-menu-map pedal-S-menu 'yank-menu-quit)))

  (if (and (boundp 'comint-mode-map)
	   (keymapp comint-mode-map))
      (progn
	(define-key comint-mode-map pedal-onward 'handsfree-comint-onwards)
	(define-key comint-mode-map pedal-S-onward 'handsfree-comint-backwards)
	(define-key comint-mode-map pedal-S-menu 'handsfree-comint-choose-or-return)))

  (if (and (boundp 'autocue-keymap)
	   (keymapp autocue-keymap))
      (progn
	(define-key autocue-keymap pedal-C-aux 'autocue:faster)
	(define-key autocue-keymap pedal-C-S-aux 'autocue:slower)
	(define-key autocue-keymap pedal-aux 'autocue:bigger)
	(define-key autocue-keymap pedal-S-aux 'autocue:smaller)
	(define-key autocue-keymap pedal-onward 'scroll-up)
	(define-key autocue-keymap pedal-S-onward 'scroll-down)
	(define-key autocue-keymap pedal-menu 'autocue:put-aside))))


(defun pedals-draw-bindings (&optional keymap)
  "Draw the pedal bindings, in the main keymap or (from a program) the one given."
  (interactive)
  (if (null keymap) (setq keymap global-map))
  (let* ((aux (lookup-key keymap pedal-aux))
	 (C-aux (lookup-key keymap pedal-C-aux))
	 (M-aux (lookup-key keymap pedal-M-aux))
	 (S-aux (lookup-key keymap pedal-S-aux))
	 (C-S-aux (lookup-key keymap pedal-C-S-aux))
	 (M-S-aux (lookup-key keymap pedal-M-S-aux))
	 (aux-longest (apply 'max
			     (mapcar 'length
				     (mapcar 'symbol-name
					     (list aux C-aux M-aux S-aux
						   C-S-aux M-S-aux)))))

	 (onward (lookup-key keymap pedal-onward))
	 (C-onward (lookup-key keymap pedal-C-onward))
	 (M-onward (lookup-key keymap pedal-M-onward))
	 (S-onward (lookup-key keymap pedal-S-onward))
	 (C-S-onward (lookup-key keymap pedal-C-S-onward))
	 (M-S-onward (lookup-key keymap pedal-M-S-onward))
	 (onward-longest (apply 'max
				(mapcar 'length
					(mapcar 'symbol-name
						(list onward C-onward M-onward S-onward
						      C-S-onward M-S-onward)))))
	 (menu (lookup-key keymap pedal-menu))
	 (C-menu (lookup-key keymap pedal-C-menu))
	 (M-menu (lookup-key keymap pedal-M-menu))
	 (S-menu (lookup-key keymap pedal-S-menu))
	 (C-S-menu (lookup-key keymap pedal-C-S-menu))
	 (M-S-menu (lookup-key keymap pedal-M-S-menu))
	 (menu-longest (apply 'max
			      (mapcar 'length
				      (mapcar 'symbol-name
					      (list menu C-menu M-menu S-menu
						    C-S-menu M-S-menu)))))

	 (descr-format (format "%%4s | | %%%ds |   %%%ds   | %%%ds | |\n"
			       aux-longest onward-longest menu-longest))
	 (edge-format (format "     | +-%s-+   %s   +-%s-+ |\n"
			      (make-string aux-longest ?-)
			      (make-string onward-longest ? )
			      (make-string menu-longest ?-)))
	 (outer-format  (format "     |   %s     %s     %s   |\n"
				(make-string aux-longest ? )
				(make-string onward-longest ? )
				(make-string menu-longest ? )))
	 (outer-edge-format  (format "     +---%s-----%s-----%s---+\n"
				     (make-string aux-longest ?-)
				     (make-string onward-longest ?-)
				     (make-string menu-longest ?-)))

	 )
    (with-output-to-temp-buffer "*Pedal bindings*"
      (princ outer-edge-format)
      (princ outer-format)
      (princ edge-format)
      (princ (format descr-format
		     "M-S"
		     (symbol-name M-S-aux)
		     (symbol-name M-S-onward)
		     (symbol-name M-S-menu)))
      (princ (format descr-format
		     "C-S"
		     (symbol-name C-S-aux)
		     (symbol-name C-S-onward)
		     (symbol-name C-S-menu)))
      (princ (format descr-format
		     "M"
		     (symbol-name M-aux)
		     (symbol-name M-onward)
		     (symbol-name M-menu)))
      (princ (format descr-format
		     "C"
		     (symbol-name C-aux)
		     (symbol-name C-onward)
		     (symbol-name C-menu)))
      (princ (format descr-format
		     "S"
		     (symbol-name S-aux)
		     (symbol-name S-onward)
		     (symbol-name S-menu)))
      (princ (format descr-format
		     ""
		     (symbol-name aux)
		     (symbol-name onward)
		     (symbol-name menu)))
      (princ edge-format)
      (princ outer-format)
      (princ outer-edge-format)

      )))