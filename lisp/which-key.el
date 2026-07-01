;;; which-key.el --- Discoverable keybinding popup -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; Popup listing the keys available after a prefix (press `SPC' and wait).
;; Bundled with Emacs 30, so `:ensure nil' keeps it from being fetched from
;; ELPA.  Loaded by init.el.

;;; Code:

(use-package which-key
  :ensure nil                           ; bundled with Emacs 30; don't fetch from ELPA
  :config
  (setq which-key-idle-delay 0.3)
  (which-key-mode 1))

;;; which-key.el ends here
