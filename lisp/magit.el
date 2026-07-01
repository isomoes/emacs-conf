;;; magit.el --- Git porcelain -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; Magit.  `evil-collection' (see evil.el) already installs Vim keys inside every
;; Magit buffer, so this just pulls in the package and sets a couple of
;; preferences.  The leader bindings (`SPC g ...') that open it live in
;; keymaps.el.  Loaded by init.el, before keymaps.el.

;;; Code:

;; `:commands' defers the (heavy) load until one of them is first called.
(use-package magit
  :commands (magit-status magit-dispatch magit-file-dispatch magit-blame
             magit-log-current)
  :init
  ;; Open the status buffer filling the whole frame, and restore the previous
  ;; window layout when you quit it with `q'.
  (setq magit-display-buffer-function
        #'magit-display-buffer-fullframe-status-v1)
  :config
  (setq magit-diff-refine-hunk 'all))     ; word-level highlighting within hunks

;;; magit.el ends here
