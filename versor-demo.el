;;;; versor-demo.el -- demo for versor and languide
;;; Time-stamp: <2007-07-25 20:44:32 jcgs>

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

(require 'versor)

(defun versor-find-demo-files ()
  "Find the versor demo data files.
This assumes they are in a subdirectory of the directory containing versor itself,
the latter being on the load-path."
  (let ((dirs load-path))
    (catch 'found
      (while dirs
	(message "Looking in %s for versor.el" (car dirs))
	(if (file-exists-p (expand-file-name "versor.el" (car dirs)))
	    (throw 'found
		   (expand-file-name "../demo"
				     (file-name-directory (car dirs))))
	  (setq dirs (cdr dirs))))
      nil)))

(defun demo-find-file (file)
  "Find FILE. Get rid of an old buffer visiting it first, to prevent interaction about it."
  (let ((buf (find-buffer-visiting file))
	(find-file-hooks nil))
    (when buf
      (set-buffer-modified-p nil)
      (kill-buffer buf))
    (find-file file)
    (font-lock-mode 1)
    (goto-char (point-min))))

(defvar demo-slowdown 1
  "*Multiplier for delays in running demo scripts.")

(defvar demo-show-commentary t
  "*Whether to show a commentary on the demo.
You almost certainly want this enabled. I made it suppressable so that
I could use the demo code to prepare a series of screenshots for the
project web pages, with the commentary text on the accompanying
HTML.
If the commentary is suppressed from the display, it goes into the buffer *Commentary*,
and the user has to press a key after each step of the demo.")

(defvar demo-lookat-function nil
  "*A function to run each time the demo is ready for the user to look at it.
Meant for taking screenshots as automatically as it will let me, for preparing
the web version of the demo.")

(defvar demo-screenshots-active t
  "Used for skipping parts of the screenshots.
You can control this by putting \(recording nil) and \(recording t) in the script.")

(defun demo-insert (string)
  "Insert STRING character by character, with short pauses, so the user can see it being typed."
  (let ((n (length string))
	(i 0))
    (while (< i n)
      (message "Typing %c" (aref string i))
      (insert (aref string i))
      (setq i (1+ i))
      (sit-for (* .3 demo-slowdown)))))

(defvar recorded-demo-html-directory "/tmp/recorded-demo"
  "*Where to put the recorded demo.")

(defvar demo-latest-commentary ""
  "The latest piece of commentary to be used.")

(defun demo-write-commentary (text)
  "Write TEXT to a commentary file.
Meant for use with preparing a series of screenshots."
  (setq demo-latest-commentary text)
  (unless (file-directory-p recorded-demo-html-directory)
    (make-directory recorded-demo-html-directory))
  (save-excursion
    (set-buffer
     (get-buffer-create "*Commentary*"))
    (goto-char (point-max))
    (insert "" text "\n")))

(defun demo-reset-commentary ()
  "Reset the commentary used by demo-write-commentary."
  (setq versor-demo-step-number 0)
  (save-excursion
    (set-buffer
     (get-buffer-create "*Commentary*"))
    (erase-buffer)))

(defvar versor-demo-mastering nil
  "*Whether we are producing a master copy.
This outputs into the message buffer information from which should-be statements
in the demo script language can be derived.")

(defvar versor-demo-step-number 0
  "The step number for the demo.")

(defvar demo-latest-command ""
  "The symbol-name of the symbol naming the latest command step in the script.")

(defvar demo-latest-keys ""
  "The keys that would have to be typed to run the latest command step in the script.")

(defvar demo-script-first-step nil
  "Whether the current step is the first one in the script.")

(defvar demo-script-last-step nil
  "Whether the current step is the last one in the script.")

(defun versor-demo-describer (description)
  "Output DESCRIPTION, and give the user time to see it."
  (message "%s" description)
  (sit-for demo-slowdown))

(defvar versor-demo-auto-correct t
  "*Whether to try to correct for slippage.")

(defun versor-demo-auto-correct (regexp)
  "Move to the nearest occurrence of REGEXP."
  (let* ((before (save-excursion
		   (re-search-backward regexp (point-min) t)))
	 (back (if (numberp before) 
		   (- (point) before)
		 nil))
	 (after (save-excursion
		  (re-search-forward regexp (point-max) t)
		  (match-end 0)))
	 (forward (if (numberp after) 
		      (- after (point))
		    nil))
	 (correction (if before
			 (if after
			     (if (> back forward)
				 after
			       before)
			   before)
		       (if after
			   after
			 nil))))
    (if (null correction)
	(error "Could not correct from %d for %S" (point) regexp)
      (message "Correcting from %d to %d for %S" (point) correction regexp)
      (goto-char correction))))

(defvar debug-demo nil
  "*Whether to output debugging information about the demo.")	    

(defvar demo-countdown t
  "*Whether to display a countdown for each display.")

(defun run-demo-script (script)
  "Run demo SCRIPT.
Lists are lisp forms to evaluate, except:
   if beginning with an integer, repeat the rest of the list that many times
   if beginning with 'recording and t or nil, switch recording on or off.
   if beginning with 'should-be, contains a regexp to check that we are looking-at
Strings are commentary.
Numbers are pauses in seconds (scaled by demo-slowdown), or cause a screenshot if recording.
Nil clears the commentary and removes any extra windows."
  (when debug-demo
    (message "Running script %S" script))
  (save-window-excursion
    (delete-other-windows)
    (let ((steps script)
	  (temp-buffer-setup-hook nil)
	  (versor-display-highlighted-choice-time demo-slowdown)
	  (demo-step-name-prefix "")
	  (versor-describe-selection-hook versor-describe-selection-hook))
      (add-hook 'versor-describe-selection-hook 'versor-demo-describer)
      (setq demo-script-first-step t
	    demo-script-last-step (cdr steps))
      (while steps
	(let ((step (car steps)))
	  (when debug-demo
	    (message "Step %S" step) (sit-for 1))
	  (cond
	   ((consp step)
	    (cond
	     ((integerp (car step))
	      (let ((count (car step))
		    (sub-script (cdr step)))
		(when debug-demo
		  (message "Repeating %S %d times" sub-script count))
		(while (> count 0)
		  (when debug-demo
		    (message "-- recursing to run %S" sub-script))
		  (run-demo-script sub-script)
		  (setq count (1- count)))))
	     ((eq (car step) 'recording)
	      (setq demo-screenshots-active (cadr step)))
	     ((eq (car step) 'should-be)
	      (if (looking-at (cadr step))
		  (when versor-demo-mastering
		    (message "Confirmed should-be %S" (cadr step)))
		(if versor-demo-auto-correct
		    (versor-demo-auto-correct (cadr step))
		  (error "Expected text %S not found" (cadr step)))))
	     (t
	      (when versor-demo-mastering
		(message "Step: %S; (should-be %S)"
			 step
			 (regexp-quote
			  (buffer-substring-no-properties
			   (point)
			   (save-excursion
			     (forward-word 1)
			     (point))))))
	      (setq this-command (car step)
		    demo-latest-command (symbol-name (car step))
		    demo-latest-keys (substitute-command-keys (format "\\[%s]" demo-latest-command)))
	      (when (and demo-show-commentary
			 (commandp (car step)))
		(message "Typing %s" demo-latest-keys)
		(sit-for demo-slowdown))
	      (delete-other-windows)
	      (eval step)
	      (setq last-command this-command)
	      (sit-for 0))))
	   ((stringp step)
	    (if demo-show-commentary
		(if (string-match "\n" step)
		    (with-output-to-temp-buffer "*Demo commentary*"
		      (message nil)
		      (princ step))
		  (delete-other-windows)
		  (message step))
	      (demo-write-commentary step)))
	   ((null step)
	    (delete-other-windows)
	    (message nil))
	   ((numberp step)
	    (if demo-show-commentary
		(if demo-countdown
		    (let ((i step))
		      (while (> i 0)
			(when (> i 1)
			    (message "Countdown %d" i))
			(sit-for demo-slowdown)
			(setq i (1- i))))
		  (sit-for (* step demo-slowdown)))
	      (if demo-lookat-function
		  (progn
		    (sit-for 0)
		    (force-mode-line-update)
		    (funcall demo-lookat-function))
		(read-event)	   ; is this necessary????????????????
		)))))
	(when debug-demo
	  (message "that was %S; type a key" (car steps)) (read-event))
	(setq steps (cdr steps)
	      demo-script-first-step nil
	      demo-script-last-step (null (cdr steps)))))))

(defun versor-lisp-demo-1 ()
  "Helper function for versor-demo."
  (interactive)
  (let ((emacs-lisp-mode-hook nil))
    (demo-find-file (expand-file-name "demo-text.el" demo-dir)))
  (setq lisp-buffer (current-buffer)
	demo-first-script t
	demo-last-script nil)
  (versor-select-named-meta-level "cartesian")
  (versor-select-named-level "chars")
  (run-demo-script
   '((should-be ";;;; demo-text.el -- elisp demo text for versor")
     "Welcome to the versor demo.

This is an animated demonstration, with commentary, of the main versor
commands.

We begin with editing an emacs-lisp file.

Watch this pop-up buffer, and the echo area (minibuffer), for
commentary on what is going on in the demo.

If you are running this demo live on Emacs, it will step from
stage to stage automatically, with delays for reading the
explanations.  (Use C-u M-x versor-demo if you don't want the
countdown for reading each screen -- it is there to assure you
something is happening.)

If you are reading the web version, use the \"Next\" links \(or
the screenshot image itself is also a link to the next stage\) to
step through it."
     20
     (versor-over-next)
     "When you are not doing Versor commands, an Emacs with Versor
loaded looks pretty much like any other Emacs. Note, however, that
there is the text <cartesian:lines/chars> in the mode line, indicating that
the cursor is currently set to move in cartesian coordinates (just
like a normal cursor) and is zoomed in to the \"chars\" scale of
movement.

By default, versor starts in cartesian co-ordinates, with the cursor
keys moving by characters and lines."
     12
     (recording nil)
     (4 (versor-over-next) .5)
     (4 (versor-next) .5)
     (should-be "un find-next")
     (recording t)
     "Now we've pressed the \"Down Arrow\" and \"Left Arrow\" keys a few times.
The cursor has moved down, almost as normal (except that, if in the
margin, which it is in this case, it follows the indentation; it does
this because you're more likely to want to edit in the non-blank text
than in the margin, and Versor tries to get the cursor to useful
places as much as possible)."
     12
     "Now we get into what Versor is built for... Pressing Ctrl-X then the
Down Arrow (or Meta (ALT) with the Down Arrow if you prefer) changes
what coordinate system we are moving in, and brings up a little
display of the coordinate space.

So, cursor keys without the Meta or Ctrl-X modifier move in the
buffer space, but with the modifier, they move in the space of
possible ways of moving.

This is how Versor packs many forms of movement into just a few keys.
We'll also press C-x Right Arrow (or M-right) to zoom out, and skip to
what it displays...

Here, we step to the \"structural\" co-ordinates, selecting \"expressions\"
and \"depth\" as our pair of co-ordinates."
     10
     (versor-demo-step-to-meta-level "structural")
     (versor-demo-step-to-level "exprs") 
     "We can move by s-expressions...

Note that the cursor has turned green, the colour Versor uses to
indicate that the arrow keys are currently set to do expression-level
movement." 6
     (versor-next)
     "Now Versor is moving by s-expressions, and it highlights the whole
expression. This highlighted region, which Versor calls the
Selection, is what Versor editing commands will act on.

Note that Languide (the part of versor that handles language-related
things) has spotted what kind of piece of code the cursor is on, and
has put the description into the header line across the top of the window.

Some of the more advanced commands use this information, to decide, for
example, whether the current selection is suitable to have a conditional
wrapped around it, and, if so, whether it needs a new conditional
statement or just needs to add a condition to an existing conditional.

You can turn this feature off, if it is slowing your system, or is
annoying you."
     12
     (should-be "find-next-lisp-binding-outwards")
     "Pressing Right again selects the next expression." 2
     (versor-next)
     "...and Right again a few more times..." 1
     (should-be "(&optional")
     (versor-next) 1
     (should-be "\"Move")
     (versor-next) 1
     (should-be "(interactive)")
     (versor-next) 1
     (should-be "(let")
     (versor-next) 1
     "When we go right again from the last one within the enclosing
expression, the ordinary cursor moves to the end of the selection.
This may seem a little inconsistent, but Versor's aim is to make it as
convenient as possible to get the cursor/selection to the places where
you're likely to want to do things, and this is definitely one of
those places; in this case, it's one where you're likely to want to
use some non-Versor commands, such as typing in an extra argument." 6
     (versor-prev)
     "Of course, we can also move back by s-expressions, using Left Arrow." 1
     "We can also move by depth.

When the Left and Right keys move by expressions, the Up and Down keys
move by depth of bracketing.

And if we land on a bracket, both of the matching pair of brackets are
selected. Pressing delete at this point would delete them both
\(haven't you ever wished for a command to do that, that would hit the
right bracket at the other end first time? ... and you don't even have
to go back manually to where you were before\), and would put them
into adjacent elements on the kill-ring. Versor has a corresponding
``insert around'' command, that will surround the selection with a
pair of things from the kill-ring.

It also does this for matching tags in XML, HTML etc." 12
     (should-be "(let")
     (versor-over-next) 1
     (versor-over-next) 1
     (should-be "(binding")
     (versor-over-next) 1
     (should-be "binding")
     (versor-over-next) 1
     "We go in again, but this time do not land on a parenthesis, so,
although the selection is still a single character (which is because
moving by levels always leaves a single character or two separate
single characters), there is only one part to the selection." 4
     (should-be "if allow")
     (versor-over-prev)
     "Pressing Up takes us out a level of brackets." 2
     (versor-over-prev)
     "Now we navigate to a piece of code we want to change." 2
     (versor-over-prev)
     (should-be "((binding")
     (versor-next) .5
     (should-be "(while")
     (versor-next) .5
     (should-be "(if")
     (versor-next) .5
     (3 (versor-over-next) 1)
     (message "At %d: %S..." (point) (buffer-substring-no-properties (point) (+ (point) 12)))
     (should-be "looking")
     (versor-next)
     "Pressing DEL will delete the current selection, and tidy up
whitespace around it. If the selection were a multi-part one, the
parts would go onto successive elements of the kill-ring." 4
     (should-be "binding")
     (message "About to kill, at %d: %S..." (point) (buffer-substring-no-properties (point) (+ (point) 12)))
     (versor-kill) 2 ; this kills the wrong thing... the bug seems to be in versor-last-item-first which is not returning the same thing as given by the motion framework; I suspect it's versor-clear-current-item-indication that's clearing it
     "Typing ordinary text, and non-versor commands, still works as usual:" 1
     (demo-insert " (concat \"^\" ")
     (versor-yank) 1
     (demo-insert ")") 3
     "Now we move into the next function.
     Moving forward past the last sub-expression moves us past the brackets.
     We keep doing it until we are on the next function." 3
     (6 (versor-next))
     (should-be "(defmodal")
     "We navigate into the function..." 2
     (versor-over-next) .5
     (5 (versor-next) .5)
     (versor-over-next) .5
     (3 (versor-next)) .5
     (2 (versor-over-next)) .5
     (versor-next) .5
     (should-be "next")
     "We now wrap the selection in brackets, using the \"insert around\" command" 3
     (versor-insert-around '("(" ")")) .5
     (versor-next) .5
     (demo-insert " nil") .5
     (2 (versor-over-prev) .5)
     (2 (versor-next) .5)
     (versor-over-next) .5
     (2 (versor-next)) .5
     "Next, we use the \"select surrounding\" command, followed by deleting the
selection, to make something unconditional.

This removes the expression surrounding the selection, leaving just the selection in
its place." 5
     (versor-select-surrounding) 4
     ;;      (versor-kill) 2
     ;;      "This has put two items onto the kill ring. We can now use the \"insert around\" command
     ;; to wrap them around another selection." 5
     ;;      (versor-next) (versor-over-next) (versor-next)
     ;;      (3 (versor-next) (versor-over-next))
     ;;      (2 (versor-next))
     ;;      (versor-insert-around (current-kill 0) (current-kill 1 t))

     )))

(defun versor-c-demo-1 ()
  "Helper function for versor-demo."
  (interactive)
  (demo-find-file (expand-file-name "demo-text.c" demo-dir))
  (run-demo-script
   '((goto-char (point-min))
     (skip-to-actual-code)
     "Now we look at the statement-based co-ordinates, using C as an example.

The co-ordinates used are called \"statements\" and \"statement-parts\".

Their definitions are language-specific. This release of versor
supports the Lisp and C families of languages, with limited support
for haskell and python, but more are planned." 4
     (versor-demo-step-to-meta-level "program")
     (versor-demo-step-to-level "statement-parts")
     "First, we step down a couple of whole statements at the top level;
these are function definitions."
     2
     (2 (versor-over-next) 1)
     (should-be "static void output_graphic")
     (versor-next) (message "selection is %S" (buffer-substring-no-properties (car (versor-get-current-item)) (cdr (versor-get-current-item))))
     (should-be "static void output_graphic")
     "Then we select the head of the function..." 
     2
     (message "About to do the troublesome one, point is %d and the selection is %S" (point) (versor-get-current-item))
     (versor-next)			; this is the one that gets to the wrong place
     (message "done the troublesome one, point is %d and the selection is %S" (point) (versor-get-current-item))     "Now we should have got to the body of it" (message "text at point begins %S" (buffer-substring-no-properties (point) (+ 24 (point))))
     (should-be "char graphics_buf")
     "And now the body of it"
     2
     "If we now go down some more statements, we will be moving inside the function."
     2
     (versor-over-next) (should-be "char graphics_buf")
     "We select a statement within the function..."
     2
     (versor-over-next) (should-be "char \\*graphic")
     "and the next statement"
     2
     (versor-over-next) (should-be "struct entry \\*more_entries")
     (versor-over-next) (should-be "if (fread)")
     "Now we can select the head or body of the statement."
     2
     (versor-next) 1 (versor-next) 1
     "When in the statement body, we can step among its constituent statements." 2
     (versor-over-next) 1
     (versor-over-next) 1
     "As well as selecting head, body (or tail), we can also select the framework
of a statement, that is, the syntax around the variable parts of it.

If we deleted that, it would put several strings onto the kill-ring." 2
     (versor-prev) 2
     "We can also select the statement containing the current selection.
This is a way of going back up the syntax of the code being edited." 2
     (versor-prev) 2
     ;; (message "selection is %S" (versor-get-current-item)) 2
     "Next, we see some high-level editing operations, starting with turning
a block of code into a separate function and substituting a call to it.

Support for these is provided by versor's companion package, languide.
You can also use such languide commands directly (without versor),
applying them to the GNUemacs region." 8
;; (message "selection is %S" (versor-get-current-item)) 2 
     (versor-languide-convert-selection-to-function "get_graphic") 4
     (beginning-of-defun)
     (versor-over-prev)
     (versor-over-prev) 2
     "The orange highlighting draws attention to complex automatic changes,
some of which may be some distance from the point at which you issued the command." 4
     (languide-remove-auto-edit-overlays) 2
     "Now we make some code conditional.
We select two statements here, by extending the selection." 4
     (versor-next) 1
     (versor-next) 1
     (versor-over-next) 1		; step into the function body
     (versor-next) 1
     (versor-next) 1
     "We can extend the selection to include the next statement,
but first we have to make \"statements\" be the current level,
because extending the selection works only at the current level,
and not its parent level." 6
     (versor-demo-step-to-level "statements") 1
     (versor-next) 1
     (versor-extend-item-forwards) (versor-extend-item-forwards) 1
     "Extended the selection" 2
     "Now we will make the selected code conditional.

If the selection had been exactly the body of an existing if-then, the new
condition would have been added as a further term to the condition of the
existing if-then statement." 4
     (versor-languide-make-conditional "disallow_null") 4
     (languide-remove-auto-edit-overlays) 2)))

(defun versor-test-c-demo-1 ()
  "Test version of demo function"
  (interactive)
  (versor-demo-setup)
  (demo-find-file (expand-file-name "demo-text.c" demo-dir))
  (statement-forget-cache)
  (goto-char (point-min))
  (skip-to-actual-code)
  (versor-demo-step-to-meta-level "program")
  (versor-demo-step-to-level "statement-parts")
  (versor-over-next)
  (versor-over-next)
  (if (looking-at "static void output_graphic") (message "Confirmed \"static void output_graphic\"") (message "Did not get \"static void output_graphic\""))
  (versor-next)
  (message "selection is %S" (buffer-substring-no-properties (car (versor-get-current-item)) (cdr (versor-get-current-item))))
  (if (looking-at "static void output_graphic") (message "Confirmed \"static void output_graphic\" again") (message "Did not get \"static void output_graphic\" again"))
  (message "About to do the troublesome one, point is %d and the selection is %S" (point) (versor-get-current-item))
  (versor-next)		; this is the one that gets to the wrong place
  (message "done the troublesome one, point is %d and the selection is %S" (point) (versor-get-current-item))     "Now we should have got to the body of it"
  (message "text at point begins %S" (buffer-substring-no-properties (point) (+ 24 (point))))
  (if (looking-at "char graphics_buf") (message "Confirmed \"char graphics_buf\"") (message "Did not get \"char graphics_buf\""))
  (versor-over-next)
  (if (looking-at "char graphics_buf") (message "Confirmed \"char graphics_buf\"") (message "Did not get \"char graphics_buf\""))
  (versor-over-next)
  (if (looking-at "char *graphic") (message "Confirmed \"char *graphic\"") (message "Did not get \"char *graphic\""))
  (versor-over-next)
  (if (looking-at "struct entry *more_entries") (message "Confirmed \"struct entry *more_entries\"") (message "Did not get \"struct entry *more_entries\""))
  (versor-over-next)
  (if (looking-at "if (fread)") (message "Confirmed \"if (fread)\"") (message "Did not get \"if (fread)\""))
  (versor-next)
  (versor-next)
  (versor-over-next)
  (versor-over-next)
  (versor-prev)
  (versor-prev)
  (message "selection is %S" (versor-get-current-item))
  (versor-languide-convert-selection-to-function "get_graphic")
  (beginning-of-defun)
  (versor-over-prev)
  (versor-over-prev)
  (languide-remove-auto-edit-overlays)
  (versor-next)
  (versor-next)
  (versor-over-next) 			; step into the function body
  (versor-next)
  (versor-next)
  (versor-demo-step-to-level "statements")
  (versor-next)
  (versor-extend-item-forwards)
  (versor-extend-item-forwards)
  (versor-languide-make-conditional "disallow_null")
  (languide-remove-auto-edit-overlays) )

(defun foo ()
  "Run this in demo-text.c and it will do the wrong thing"
  (interactive)
  (find-file (substitute-in-file-name "$COMMON/open-projects/emacs-versor/demo/demo-text.c"))
  (statement-forget-cache)
  (message "Beginning foo")
  (goto-line 2)
  (message "current item valid: %S; items: %S" (versor-current-item-valid) versor-items)
  ;; This is not idempotent -- sometimes it hits the first defun,
  ;; sometimes the second. I'd like it to go for the first, always.
  (message "First versor-over-next:")
  (versor-over-next)
  (message "Second versor-over-next:")
  (versor-over-next)
  (message "First versor-next:")
  (versor-next)
  ;; this is the dodgy one -- it selects the body apart from the first
  ;; statement. Doing this sequence of things interactively correctly
  ;; selects the whole body.
  ;; Bizarrely, it's not even idempotent!
  (message "Second versor-next:")
  (versor-next)
  (message "done foo"))

(defun fu ()
  (interactive)
  (statement-forget-cache)
  (goto-line 2)
  (versor-over-next)
  (versor-over-next)
  (versor-next))

(defun bar ()
  (interactive)
  (statement-forget-cache)
  (versor-next))

(defun versor-lisp-demo-2 ()
  "Helper function for versor-demo."
  (interactive)
  (goto-char (point-min))
  (run-demo-script
   '("Now we return to the emacs-lisp demonstration buffer to show the
automatic conversion of an expression to a variable.

This works in C as well, in which it tries to deduce the appropriate
type of the variable, too. We demonstrate it in Lisp to show that this
level of operation is cross-language."
     10
     (search-forward "languide-region-type")
     (versor-select-named-meta-level "structural")
     (versor-select-named-level "exprs")
     (4 (versor-next) .2)
     (versor-over-next) .2
     (versor-next) .2 (versor-over-next) .2
     (versor-next) .2 (versor-over-next) .2
     (versor-next) .2 (versor-next) .2
     (versor-over-next)
     (3 (versor-next) .2)
     (versor-over-next) .2
     (2 (versor-next) .2) (versor-prev) (versor-prev) 
     "Having selected the expression, we give a single command to convert it
to a variable at a suitable scope." 2
     (versor-languide-convert-selection-to-variable "is-digit")
     "Note that the command has determined the widest scope at which the new
variable can be defined -- all the variables needed for the expression
are in scope at that point." 10
     )))

(defvar demo-first-script nil)
(defvar demo-last-script nil)

(defvar demo-dir nil
  "The directory containing the demo.")

(defun versor-demo-setup ()
  "Helper function for versor-demo."
  (interactive)
  (unless demo-dir
    (setq demo-dir (versor-find-demo-files)))
  (unless (file-directory-p demo-dir)
    (setq demo-dir (read-file-name "Could not find demo dir, please choose: ")))
  (mapcar (lambda (extension)
	    (copy-file (expand-file-name (format "demo-text-orig.%s" extension)
					 demo-dir)
		       (expand-file-name (format "demo-text.%s" extension)
					 demo-dir)
		       t))
	  '("el" "c"))
  (visit-tags-table demo-dir))

(defun versor-demo (&optional arg)
  "Demonstrate versor.
With optional / prefix arg, don't output countdown messages."
  (interactive "P")
  (unless (memq 'versor-current-level-name global-mode-string)
    (versor-setup 'arrows 'arrows-misc 'text-in-code 'verbose))
  (demo-reset-commentary)
  (setq versor-demo-step-number 0)
  (save-window-excursion
    (let* ((demo-countdown (not arg))
	   (versor-display-underlying-commands nil)
	   (versor-quiet-commands (append '(versor-demo-step-to-level
					    versor-demo-step-to-meta-level)
					  versor-quiet-commands))
	   (lisp-buffer nil))
      (versor-demo-setup)
      (versor-lisp-demo-1)
      (setq demo-first-script nil)
;;       (versor-c-demo-1)
;;       (setq demo-last-script t)
;;       (let ((emacs-lisp-mode-hook nil))
;; 	(demo-find-file (expand-file-name "demo-text.el" demo-dir)))
;;       (versor-lisp-demo-2)

;;       (run-demo-script
;;        '("This is the end of the versor demo." 10))
)))

(defvar demo-file-name-format "demo-step-%d.html"
  "File name format for demo steps.")

(defvar sourceforge-logo
  "<a href=\"http://sourceforge.net/\"><img
  src=\"http://sourceforge.net/sflogo.php?group_id=97002&amp;type=2\"
  align=\"right\"
  width=\"125\"
  height=\"37\"
  border=\"0\"
  alt=\"SourceForge.net Logo\" /></a>"
  "HTML text for the SourceForge.net logo.")

(defun versor-take-screenshot ()
  "Helper function for versor-record-screenshots."
  ;; (message "point at %d" (point))
  (when demo-screenshots-active
    (let ((place (point))
	  (buffer (current-buffer)))
      ;; (message "taking screenshot from %s:%d" buffer place)
      (save-window-excursion
	(save-excursion
	  (let* ((raw-screenshot-file-name "~/Screenshot-Emacs.png")
		 (screenshot-file-name (format "step-%d.png" versor-demo-step-number))
		 (screenshot-full-name (expand-file-name screenshot-file-name
							 recorded-demo-html-directory))
		 (has-next (not (and demo-last-script
				     demo-script-last-step))))
	    (when (and (file-exists-p raw-screenshot-file-name)
		       (yes-or-no-p "Delete old screenshot file? "))
	      (delete-file raw-screenshot-file-name)
	      (message nil))
	    (shell-command "gnome-panel-screenshot --window")
	    (when (file-exists-p screenshot-full-name)
	      (delete-file screenshot-full-name))
	    (rename-file raw-screenshot-file-name screenshot-full-name)
	    (find-file (expand-file-name
			(format demo-file-name-format versor-demo-step-number)
			recorded-demo-html-directory))
	    (erase-buffer)
	    (insert "<html>\n<head>\n<title>Versor demo step "
		    (int-to-string versor-demo-step-number)
		    "</title>\n</head>\n<body>\n")
	    (insert "<!-- "
		    (format "demo-first-script=%S demo-last-script=%S demo-script-first-step=%S demo-script-last-step=%S"
			    demo-first-script demo-last-script demo-script-first-step demo-script-last-step)
		    " -->")
	    (when has-next
	      (insert "<a href=\"" (format demo-file-name-format (1+ versor-demo-step-number)) "\">"))
	    (insert "<img border=\"0\" src=\"" screenshot-file-name "\">\n")
	    (when has-next
	      (insert "</a>"))
	    (insert "<table width=\"100%\" border=\"0\">\n<tr>\n<td align=\"left\">\n")
	    (when (or (not demo-script-first-step)
		      (not demo-first-script))
	      (insert "<a href=\""
		      (format demo-file-name-format (1- versor-demo-step-number))
		      "\">Previous</a>\n"))
	    (insert "</td>\n<td align=\"center\">\n"
		    "Demo frame " (int-to-string versor-demo-step-number)
		    "</td>\n<td align=\"right\">\n")
	    (if has-next
		(insert "<a href=\""
			(format demo-file-name-format (1+ versor-demo-step-number))
			"\">Next</a>")
	      (insert "End of demo"))
	    (insert "\n</td>\n</tr>\n"

		    ;; 		    "<tr><td align=\"left\">Just typed: "
		    ;; 		    demo-latest-keys
		    ;; 		    "</td><td></td><td align=\"right\">Latest command: "
		    ;; 		    demo-latest-command
		    ;;		    "</td></tr>\n"

		    "</table>\n"
		    "\n<p>")
	    (let ((commentary-start (point))
		  (replacements '(("<" . "&lt;")
				  (">" . "&gt;")
				  ("\n\n" . "</p>\n\n<p>"))))
	      (insert demo-latest-commentary)
	      (while replacements
		(goto-char commentary-start)
		(while (search-forward (caar replacements) (point-max) t)
		  (replace-match (cdar replacements)))
		(setq replacements (cdr replacements)))
	      (goto-char (point-max)))
	    (insert "</p>\n")
	    (insert "<hr>\n" sourceforge-logo)
	    (insert "\n"
		    "</body>\n</html>\n")
	    (setq demo-latest-commentary "")
	    (basic-save-buffer)
	    (kill-buffer nil)
	    (message nil))))
      ;; Something weird is going on here; I don't see why point should be moving!
      ;; (sit-for 1)
      ;; (message "Place %d, why %d" place (point))
      ;; (message "back to %s:%d" buffer place)
      (switch-to-buffer buffer)
      (goto-char place)
      ;; (redraw-display)
      (sit-for 0)
      ;; (message nil)
      (setq versor-demo-step-number (1+ versor-demo-step-number)))))

(defun versor-record-screenshots ()
  "Record the screenshots for the versor web demo."
  (interactive)
  (let ((demo-show-commentary nil)
	(demo-lookat-function 'versor-take-screenshot))
    (message "Press any key after taking each screenshot, to advance to the next step.")
    (versor-demo)
    (message "End of demo")))

(defun versor-demo-step-to-level (level)
  (let* ((targets (versor-find-level-by-single-name level))
	 (target (cdr targets))
	 (stepper (if (> target versor-level)
		      'versor-out
		    'versor-in)))
    (unless (= versor-meta-level (car targets))
      (setq versor-meta-level (car targets))
      (versor-trim-meta-level)
      (versor-trim-level)
      (setq targets (versor-find-level-by-single-name level))
      (target (cdr targets))
      (stepper (if (> target versor-level)
		   'versor-out
		 'versor-in)))
    (while (not (= versor-level target))
      (call-interactively stepper)
      (if demo-lookat-function
	  (progn
	    (sit-for 0)
	  ;; (funcall demo-lookat-function)
	    )
	(sit-for demo-slowdown)))))

(defun versor-demo-step-to-meta-level (meta-level)
  (let* ((target (versor-find-meta-level-by-name meta-level))
	 (stepper (if (> target versor-level)
		      'versor-next-meta-level
		    'versor-prev-meta-level)))
    (while (not (= versor-meta-level target))
      (call-interactively stepper)
      (if demo-lookat-function
	  (progn
	    (sit-for 0)
	    ;; (funcall demo-lookat-function)
	    )
	(sit-for demo-slowdown)))))

;;;;;;;;;;;;;;;; some test functions ;;;;;;;;;;;;;;;;
(defun should-be (pattern) (if (looking-at pattern) (message "%s confirmed" pattern) (message "%s missing" pattern)))
(defun demo-test ()
  (interactive)
  (versor-demo-setup)
  (demo-find-file (expand-file-name "demo-text.c" demo-dir))
  (goto-char (point-min))
  (versor-demo-step-to-meta-level "program")
  (versor-demo-step-to-level "statement-parts")
  (versor-over-next)
  (should-be "static void output_graphic")
  (versor-next) 
  (should-be "static void output_graphic")
  (versor-next)		; this is the one that gets to the wrong place
  (message "done the troublesome one, point is %d and the selection is %S" (point) (versor-get-current-item)) 
  (should-be "char graphics_buf"))
;;;;;;;;;;;;;;;; end of test functions ;;;;;;;;;;;;;;;;

(provide 'versor-demo)

;;; end of versor-demo.el
