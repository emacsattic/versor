;;;; languide-custom.el -- customization definitions for languide
;;; Time-stamp: <2006-04-10 15:59:05 john>

;;  This program is free software; you can redistribute it and/or modify it
;;  under the terms of the GNU General Public License as published by the
;;  Free Software Foundation; either version 2 of the License, or (at your
;;  option) any later version.

;;  This program is distributed in the hope that it will be useful, but
;;  WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;  General Public License for more details.

;;  You should have received a copy of the GNU General Public License along
;;  with this program; if not, write to the Free Software Foundation, Inc.,
;;  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

(provide 'languide-custom)

(defgroup languide nil
  "Languide-guided editing.
This includes things like turning pieces of inline code into separate functions,
detecting automatically what arguments need to be passed to them."
  :group 'editing
  :prefix "languide-")

(defface languide-auto-edit-overlay-face
  '((t (:background "red")))
  "How to draw attention to what languide has done.
When languide does something that involves changes away from point,
it shows the changed text in this face, until the next user input."
  :group 'languide)

(defcustom languide-debug-messages nil
  "*Whether languide should tell you what it is doing, in great detail.
You should need to set this only if working on the internals of languide.
See also languide-debug-functions."
  :type '(restricted-sexp :match-alternatives
			 (integerp 't 'nil))
  :group 'languide)

(defcustom languide-debug-functions '(
				      ;;  beginning-of-statement-internal
				      ;; end-of-statement-internal
				      ;; continue-back-past-curly-ket
				      ;; previous-statement
				      ;; next-statement
				      ;; navigate-to
				      )
  "Which functions languide-debug-messages should output messages for.
You should need to set this only if working on the internals of languide."
  :group 'languide
  :type '(set (const beginning-of-statement-internal)
	      (const continue-back-past-curly-ket)
	      (const end-of-statement-internal)
	      (const identify-statement)
	      (const languide-c-back-to-possible-ender)
	      (const navigate-to)
	      (const next-statement)
	      (const next-statement-internal)
	      (const previous-statement)
	      (const skip-to-actual-code)
	      (const statement-container)))

(defcustom navigate-container-whole-statement t
  "*Whether to include the whole statement as the container.
If this is non-nil, when you select the container of a statement,
the whole containing statement is selected, rather than just the
part of it containing the statement. For example, if you have
  if (a) {
    b;
    c;
  }
and are on \"b\" and select the container of b, you will get the
whole if statement, rather than just the block body."
  :type 'boolean
  :group 'languide)

(defcustom statement-navigate-parts-cyclic nil
  "*Whether to step forwards from body (or tail if present) back round to head."
  :type 'boolean
  :group 'languide)

(defcustom statement-navigate-parts-include-container t
  "*Whether to step forwards from body (or tail if present) or back from head, to container."
  :type 'boolean
  :group 'languide)

;;; end of languide-custom.el
