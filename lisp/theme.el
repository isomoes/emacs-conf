;;; theme.el --- Color theme: github-dark-colorblind -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; Loads the `github-dark-colorblind' theme (a 1:1 port of the nvim colorscheme,
;; generated with `autothemer' — hence that dependency) and defines the `SPC t t'
;; theme switcher.  Loaded by init.el before keymaps.el, so `isomoes/load-theme'
;; exists when the leader map that points at it is built.

;;; Code:

;; The theme is generated with autothemer, so it needs that package available.
(use-package autothemer)

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes/" user-emacs-directory))
(setq custom-safe-themes t)             ; personal config: don't prompt on load
(load-theme 'github-dark-colorblind t)

;; `SPC t t' switch: disable the current theme first so themes don't stack into
;; a muddy mix (bare `load-theme' layers them).
(defun isomoes/load-theme (theme)
  "Disable all enabled themes, then load THEME."
  (interactive
   (list (intern (completing-read
                  "Theme: " (mapcar #'symbol-name (custom-available-themes))))))
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme theme t))

;;; theme.el ends here
