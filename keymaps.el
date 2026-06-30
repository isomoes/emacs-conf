;;; keymaps.el --- All keybindings: SPC leader + global overrides -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; Every explicit keybinding lives here, kept out of init.el so that file stays
;; about packages and defaults.  Loaded from init.el once `general' (and the
;; commands these keys point at) are available.  Three groups:
;;
;;   1. the `SPC' leader map (Doom-style), via general's definer
;;   2. C-hjkl window jumps (normal/visual/motion — NOT insert)
;;   3. zoom + save, on the `override' map in every state
;;
;; Why everything sits on general's `override' keymap: several evil-collection
;; modes rebind keys like `C-j'/`C-k' as next/prev-item in their own
;; buffer-local mode maps (e.g. xref), and those outrank the global evil state
;; maps.  `override' sits above them, so these bindings win everywhere — the
;; same mechanism that lets the `SPC' leader reach into those buffers.

;;; Code:

(require 'general)

;;; ----------------------------------------------------------------------------
;;; Leader key (SPC)
;;; ----------------------------------------------------------------------------

(general-create-definer my/leader
  :states '(normal insert visual motion emacs)
  :keymaps 'override
  :prefix "SPC"
  :global-prefix "M-SPC")              ; reach the leader from insert/other states via
                                       ; M-SPC (SPC still self-inserts there). M-SPC, not
                                       ; C-SPC, keeps set-mark free — but note some desktops
                                       ; grab Alt+SPC (KDE/GNOME); rebind there if it's eaten.

(my/leader
  "SPC" '(project-find-file       :which-key "find file in project")
  ":"   '(execute-extended-command :which-key "M-x")
  ";"   '(eval-expression         :which-key "eval")
  "."   '(find-file               :which-key "find file")
  ","   '(consult-buffer          :which-key "switch buffer")
  "!"   '(shell-command           :which-key "shell command")
  "u"   '(universal-argument      :which-key "C-u")

  ;; buffers
  "b"   '(:ignore t :which-key "buffer")
  "bb"  '(switch-to-buffer        :which-key "switch")
  "bd"  '(kill-current-buffer     :which-key "kill")
  "bn"  '(next-buffer             :which-key "next")
  "bp"  '(previous-buffer         :which-key "prev")
  "br"  '(revert-buffer           :which-key "revert")
  "bs"  '(scratch-buffer          :which-key "scratch")

  ;; files
  "f"   '(:ignore t :which-key "file")
  "ff"  '(find-file               :which-key "find")
  "fs"  '(save-buffer             :which-key "save")
  "fS"  '(write-file              :which-key "save as")
  "fr"  '(recentf-open-files      :which-key "recent")
  "fR"  '(rename-visited-file     :which-key "rename")

  ;; windows
  "w"   '(:ignore t :which-key "window")
  "wv"  '(split-window-right      :which-key "split right")
  "ws"  '(split-window-below      :which-key "split below")
  "wd"  '(delete-window           :which-key "delete")
  "wo"  '(delete-other-windows    :which-key "only")
  "ww"  '(other-window            :which-key "other")
  "wh"  '(windmove-left           :which-key "left")
  "wj"  '(windmove-down           :which-key "down")
  "wk"  '(windmove-up             :which-key "up")
  "wl"  '(windmove-right          :which-key "right")
  "w="  '(balance-windows         :which-key "balance")
  "wu"  '(winner-undo             :which-key "undo layout")
  "wU"  '(winner-redo             :which-key "redo layout")

  ;; search
  "s"   '(:ignore t :which-key "search")
  "ss"  '(consult-line            :which-key "in buffer")
  "so"  '(occur                   :which-key "occur")
  "sp"  '(consult-ripgrep         :which-key "in project (rg)")
  "si"  '(consult-imenu           :which-key "imenu")

  ;; project (built-in project.el)
  "p"   '(:ignore t :which-key "project")
  "pp"  '(project-switch-project   :which-key "switch")
  "pf"  '(project-find-file        :which-key "find file")
  "pb"  '(project-switch-to-buffer :which-key "buffer")
  "pg"  '(project-find-regexp      :which-key "grep")
  "pd"  '(project-dired            :which-key "dired")

  ;; code
  "c"   '(:ignore t :which-key "code")
  "cc"  '(comment-line            :which-key "comment line")
  "cd"  '(comment-dwim            :which-key "comment dwim")

  ;; git (built-in vc; swap to magit once you install it)
  "g"   '(:ignore t :which-key "git")
  "gg"  '(vc-dir                  :which-key "vc-dir")
  "gb"  '(vc-annotate             :which-key "blame")

  ;; toggles
  "t"   '(:ignore t :which-key "toggle")
  "tl"  '(display-line-numbers-mode :which-key "line numbers")
  "tw"  '(visual-line-mode        :which-key "word wrap")
  "tt"  '(my/load-theme           :which-key "load theme")

  ;; help
  "h"   '(:ignore t :which-key "help")
  "hf"  '(describe-function       :which-key "function")
  "hv"  '(describe-variable       :which-key "variable")
  "hk"  '(describe-key            :which-key "key")
  "hm"  '(describe-mode           :which-key "mode")
  "ho"  '(describe-symbol         :which-key "symbol")
  "hi"  '(info                    :which-key "info browser")
  "hR"  '(info-display-manual     :which-key "read a manual")

  ;; quit / restart
  "q"   '(:ignore t :which-key "quit")
  "qq"  '(save-buffers-kill-terminal :which-key "quit")
  "qr"  '(restart-emacs           :which-key "restart"))

;;; ----------------------------------------------------------------------------
;;; Window jumps — C-hjkl without the `C-w' prefix (tmux-navigator style)
;;; ----------------------------------------------------------------------------

;; normal/visual/motion ONLY — NOT insert — so `C-h' stays backspace, `C-j'
;; stays newline and `C-k' stays evil-insert-digraph while typing. The lost
;; `C-h' help prefix is still on `<f1>' (and `SPC h'); `C-w h/j/k/l' and
;; `SPC w h/j/k/l' also work.
(general-define-key
 :states '(normal visual motion)
 :keymaps 'override
 "C-h" #'windmove-left
 "C-j" #'windmove-down
 "C-k" #'windmove-up
 "C-l" #'windmove-right)

;;; ----------------------------------------------------------------------------
;;; Zoom + save — in EVERY state (incl. insert, so they work mid-type)
;;; ----------------------------------------------------------------------------

;; Zoom: `text-scale-*' rescales the CURRENT buffer's text only (a buffer-local
;; face remap); for whole-frame zoom swap in `global-text-scale-adjust' (Emacs
;; 28+): "C-=" -> (lambda () (interactive) (global-text-scale-adjust 1)), "C--"
;; -> -1, "C-0" -> 0.  Shadows `C-0'/`C--' (digit-/negative-argument) — use
;; `C-u' or `M-<digit>' for prefix args.
;;
;; Save: `C-s' shadows `isearch-forward' — fine here (search is on `/',
;; `SPC s s', `SPC s o'; `M-x isearch-forward' still works; `SPC f s' also
;; saves).  In a TTY (`emacs -nw') the terminal may eat `C-s' as flow-control
;; (XOFF/freeze) — a non-issue in GUI/`emacsclient' frames.
(defun my/text-scale-reset ()
  "Reset the current buffer's text scale to the default size."
  (interactive)
  (text-scale-set 0))

(general-define-key
 :states '(normal insert visual motion emacs)
 :keymaps 'override
 "C-=" #'text-scale-increase     ; zoom in
 "C-+" #'text-scale-increase     ; zoom in (Shift+= on most layouts)
 "C--" #'text-scale-decrease     ; zoom out
 "C-0" #'my/text-scale-reset     ; reset zoom
 "C-s" #'save-buffer)            ; save file

(provide 'keymaps)
;;; keymaps.el ends here
