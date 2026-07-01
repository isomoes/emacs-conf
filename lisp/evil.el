;;; evil.el --- Vim emulation: evil + evil-collection -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; The core Vim experience, kept together because evil-collection builds on
;; evil's settings:
;;   evil            - states (normal/insert/visual) + motions
;;   evil-collection - Vim keys in dired, magit, help, *Messages*, ...
;; Loaded by init.el (first, before the other plugin files).

;;; Code:

(use-package evil
  :init
  ;; MUST be set before evil loads so evil-collection can take over the rest.
  (setq evil-want-keybinding nil
        evil-want-integration t
        evil-want-C-u-scroll t          ; C-u scrolls (like Vim) instead of prefix-arg
        evil-want-Y-yank-to-eol t
        evil-undo-system 'undo-redo     ; built-in undo-redo (Emacs 28+); C-r redoes
        evil-split-window-below t
        evil-vsplit-window-right t
        evil-search-module 'evil-search)
  :config
  (evil-mode 1))
;; Note: `j'/`k' move by logical lines (pure Vim). Use `gj'/`gk' to move by
;; visual (wrapped) lines — both are bound out of the box by evil.

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;;; evil.el ends here
