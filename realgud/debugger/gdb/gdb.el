;;; Copyright (C) 2010-2011, 2014 Rocky Bernstein <rocky@gnu.org>
;;  `realgud-gdb' Main interface to gdb via Emacs
(require 'load-relative)
(require-relative-list '("../../common/helper") "realgud-")
(require-relative-list '("core" "track-mode") "realgud-gdb-")

;; This is needed, or at least the docstring part of it is needed to
;; get the customization menu to work in Emacs 23.
(defgroup realgud-gdb nil
  "The dbgr interface to gdb"
  :group 'processes
  :group 'realgud
  :group 'gdb
  :version "23.1")

;; -------------------------------------------------------------------
;; User definable variables
;;

(defcustom realgud-gdb-command-name
  ;;"gdb --emacs 3"
  "gdb"
  "File name for executing the Ruby debugger and command options.
This should be an executable on your path, or an absolute file name."
  :type 'string
  :group 'realgud-gdb)

(declare-function gdb-track-mode (bool))
(declare-function realgud-command            'realgud-gdb-core)
(declare-function realgud-gdb-parse-cmd-args 'realgud-gdb-core)
(declare-function realgud-gdb-query-cmdline  'realgud-gdb-core)
(declare-function realgud-run-process        'realgud-core)

;; -------------------------------------------------------------------
;; The end.
;;

;;;###autoload
(defun realgud-gdb (&optional opt-command-line no-reset)
  "Invoke the gdb Ruby debugger and start the Emacs user interface.

String COMMAND-LINE specifies how to run gdb.

Normally command buffers are reused when the same debugger is
reinvoked inside a command buffer with a similar command. If we
discover that the buffer has prior command-buffer information and
NO-RESET is nil, then that information which may point into other
buffers and source buffers which may contain marks and fringe or
marginal icons is reset."

  (interactive)
  (let* ((cmd-str (or opt-command-line (realgud-gdb-query-cmdline "gdb")))
	 (cmd-args (split-string-and-unquote cmd-str))
	 (parsed-args (realgud-gdb-parse-cmd-args cmd-args))
	 (script-args (cdr cmd-args))
	 (script-name (expand-file-name (car script-args)))
	 (cmd-buf (realgud-run-process "gdb" (car script-args) cmd-args
				     'realgud-gdb-track-mode nil))
	 )
    (if cmd-buf
	(with-current-buffer cmd-buf
	  (realgud-command "set annotate 1" nil nil nil)
	  )
      )
    )

    ;; ;; Parse the command line and pick out the script name and whether
    ;; ;; --annotate has been set.

    ;; (condition-case nil
    ;; 	(setq cmd-buf
    ;; 	      (apply 'realgud-exec-shell "gdb" (car script-args)
    ;; 		     (car cmd-args) nil
    ;; 		     (cons script-name (cddr cmd-args))))
    ;; (error nil))
    ;; ;; FIXME: Is there probably is a way to remove the
    ;; ;; below test and combine in condition-case?
    ;; (let ((process (get-buffer-process cmd-buf)))
    ;;   (if (and process (eq 'run (process-status process)))
    ;; 	  (progn
    ;; 	    (switch-to-buffer cmd-buf)
    ;; 	    (realgud-gdb-track-mode 't)
    ;; 	    (realgud-cmdbuf-info-cmd-args= cmd-args)
    ;; 	    )
    ;; 	(message "Error running gdb command"))
    ;; )
    )

(provide-me "realgud-")
