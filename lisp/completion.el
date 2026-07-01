;;; completion.el --- Minibuffer completion UI -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; The completion stack — four packages designed to work together, so they
;; share a file:
;;   vertico    - vertical, live-filtering minibuffer
;;   orderless  - space-separated, order-free matching
;;   marginalia - annotations in the minibuffer margin
;;   consult    - practical search/navigation commands
;; Loaded by init.el.

;;; Code:

;; Vertical, live-filtering minibuffer for every completing-read (find-file,
;; switch-buffer, M-x, ...). `savehist-mode' (enabled in init.el) persists its history.
(use-package vertico
  :init (vertico-mode 1))

(use-package orderless
  :init
  ;; Space-separated, order-free substring matching: "ini cfg" matches init.el
  ;; in config/. For files, orderless (fuzzy) AND partial-completion (so the
  ;; /u/s/b path shorthand and ~/ expansion still work).
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles orderless partial-completion)))))

;; Annotations (file sizes, docstrings, key bindings) in the margin.
(use-package marginalia
  :init (marginalia-mode 1))

;; Practical search/navigation commands; wired into the leader map (see keymaps.el).
(use-package consult
  :config
  ;; Use ripgrep's PCRE2 engine for `SPC s p' — lookaround, backreferences,
  ;; non-greedy, \d/\w, etc. (your rg is built with +pcre2). Idempotent.
  (unless (string-match-p "--pcre2" consult-ripgrep-args)
    (setq consult-ripgrep-args (concat consult-ripgrep-args " --pcre2"))))

;;; completion.el ends here
