;;; init.el --- Minimal evil-based Emacs config -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; Vim keybindings in Emacs, rolled by hand instead of via a framework.
;; Core packages:
;;
;;   evil            - the Vim emulation (normal/insert/visual states, motions)
;;   evil-collection - Vim keys in dired, magit, help, *Messages*, etc.
;;   general         - clean `SPC' leader-key definitions (Doom-style)
;;   which-key       - popup of available keys (built into Emacs 30)
;;   vertico+orderless+marginalia+consult - live fuzzy minibuffer completion
;;
;; The rest is a small pile of sane built-in defaults. Each plugin lives in its
;; own file under lisp/; all keybindings live in keymaps.el.
;;
;; Layout:
;;   early-init.el  - UI/startup tuning (runs first)
;;   init.el        - this file: package bootstrap + built-in defaults, then
;;                    loads each plugin file under lisp/, then keymaps.el
;;   lisp/          - one file per plugin/concern (evil, completion, magit, ...)
;;   keymaps.el     - the SPC leader map + global override keys
;;   themes/        - the github-dark-colorblind theme (ported from nvim)

;;; Code:

;;; ----------------------------------------------------------------------------
;;; Package bootstrap
;;; ----------------------------------------------------------------------------

(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; `use-package' ships with Emacs 29+; install it only as a fallback.
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t        ; auto-install declared packages
      use-package-expand-minimally t)

;;; ----------------------------------------------------------------------------
;;; Sane built-in defaults
;;; ----------------------------------------------------------------------------

;; Encoding everywhere.
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)

;; Behaviour.
(setq-default indent-tabs-mode nil      ; spaces, not tabs
              tab-width 4
              fill-column 80)
(setq use-short-answers t               ; y/n instead of yes/no
      ring-bell-function #'ignore       ; no audible bell
      scroll-conservatively 101         ; don't recenter when scrolling off-screen
      scroll-margin 3
      sentence-end-double-space nil
      require-final-newline t
      enable-recursive-minibuffers t)

;; Keep the config directory tidy: backups, auto-saves and lockfiles out of the
;; way, and the machine-generated custom.el out of init.el (and out of git).
(let ((backup-dir    (expand-file-name "backups/"   user-emacs-directory))
      (autosave-dir  (expand-file-name "auto-save/" user-emacs-directory)))
  (make-directory backup-dir   t)
  (make-directory autosave-dir t)
  (setq backup-directory-alist         `(("." . ,backup-dir))
        auto-save-file-name-transforms `((".*" ,autosave-dir t))
        create-lockfiles nil
        backup-by-copying t
        delete-old-versions t
        version-control t
        kept-new-versions 6
        kept-old-versions 2))

;; Auto-save more eagerly than the stock defaults — this is the whole point of
;; auto-saving (the "Auto Save" node of the Emacs manual). Emacs auto-saves a
;; buffer after `auto-save-interval' keystrokes OR `auto-save-timeout' seconds
;; idle, whichever comes first; lowering both trades a little disk churn for
;; losing less work on a crash. Enabled per-buffer via `auto-save-default' (no
;; global mode call needed); the files land in `auto-save/' (transforms above).
(setq auto-save-default t                ; auto-save every file-visiting buffer
      auto-save-interval 200             ; ...every 200 keystrokes (default 300)
      auto-save-timeout 20               ; ...or after 20s idle (default 30)
      auto-save-no-message nil)          ; show "Auto-saving..."; set t to silence

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file nil 'nomessage))

;; Persist minibuffer history, recent files, and cursor position between sessions.
;; Set the vars BEFORE enabling recentf: the default `recentf-auto-cleanup' of
;; `mode' runs a stat-everything cleanup at mode-enable, which can hang on remote
;; (TRAMP) paths — `never' only helps if it's set first.
(setq recentf-max-saved-items 200
      recentf-auto-cleanup 'never)
(recentf-mode 1)
(savehist-mode 1)
(save-place-mode 1)

;; Editor niceties.
(setq display-line-numbers-type 'relative) ; relative (vim-style); set to t for absolute
;; Numbers in code/prose buffers only — not dired, *Help*, terminals, images, etc.
(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
  (add-hook hook #'display-line-numbers-mode))
(column-number-mode 1)
(show-paren-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)             ; reload files changed on disk
(setq global-auto-revert-non-file-buffers t)
(winner-mode 1)                         ; undo/redo window layout changes
(delete-selection-mode 1)               ; typing replaces the active region

;; Font — ported from the previous Doom config (JetBrainsMono Nerd Font, large).
;; `:height' is in 1/10 pt; bump or drop it to taste. Applied per-frame so it
;; also reaches GUI frames spawned later by `emacsclient' under a daemon (where
;; `display-graphic-p' is nil at init time). No-op on TTY/--batch or if the font
;; isn't installed.
(defun isomoes/set-default-font (&optional frame)
  "Set the default font on FRAME when it is graphical and the font exists."
  (when (and (display-graphic-p frame)
             (find-font (font-spec :family "JetBrainsMono Nerd Font")))
    (set-face-attribute 'default frame
                        :family "JetBrainsMono Nerd Font" :height 180)))
(add-hook 'after-make-frame-functions #'isomoes/set-default-font)
(isomoes/set-default-font)                   ; the initial (non-daemon) frame

;;; ----------------------------------------------------------------------------
;;; Plugins — one file per concern under lisp/
;;; ----------------------------------------------------------------------------

;; Each external package is configured in its own file under lisp/. They are
;; `load'ed by explicit path, in order, rather than added to `load-path' and
;; `require'd: files named lisp/evil.el and lisp/general.el would otherwise
;; SHADOW the real `evil'/`general' packages whenever something calls
;; `(require 'evil)'. Order matters — evil first; all before keymaps.el below.
(dolist (module '("evil"          ; Vim emulation: evil + evil-collection
                  "which-key"     ; keybinding popup
                  "completion"    ; vertico + orderless + marginalia + consult
                  "general"       ; SPC leader-key definer
                  "theme"))       ; github-dark-colorblind + SPC t t switcher
  (load (expand-file-name (format "lisp/%s" module) user-emacs-directory)
        nil 'nomessage))

;;; ----------------------------------------------------------------------------
;;; Keybindings — the SPC leader map + global overrides (keymaps.el)
;;; ----------------------------------------------------------------------------

;; Loaded last so `general' and every command these keys point at (including
;; `isomoes/load-theme' from lisp/theme.el) are already defined by the time the
;; bindings run.
(load (expand-file-name "keymaps.el" user-emacs-directory) nil 'nomessage)

;;; ----------------------------------------------------------------------------
;;; Add your own packages / bindings below.
;;; ----------------------------------------------------------------------------
;; New plugins go in their own file under lisp/ and get added to the list above.
;; Popular next steps (all play nicely with the leader map in keymaps.el):
;;   corfu + cape   - in-buffer (as-you-type) completion
;; The ported theme already styles these.

(provide 'init)
;;; init.el ends here
