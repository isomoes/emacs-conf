# emacs-conf

A minimal, hand-rolled Emacs configuration with Vim keybindings — no framework.

The whole Vim experience is four packages: [`evil`](https://github.com/emacs-evil/evil)
(Vim emulation), [`evil-collection`](https://github.com/emacs-evil/evil-collection)
(Vim keys in dired/magit/help/…), [`general`](https://github.com/noctuid/general.el)
(a clean `SPC` leader, Doom-style), and the built-in `which-key`. Everything else is
sane built-in defaults plus a leader map bound only to built-in commands.

## Layout

| File | Role |
|---|---|
| `early-init.el` | startup/UI tuning (runs first) |
| `init.el` | packages, defaults, evil, leader map, theme |
| `themes/` | `github-dark-colorblind` — a 1:1 port of the nvim colorscheme |

## Install

Requires **Emacs 30+** (ships `use-package` and `which-key`).

```sh
git clone https://github.com/isomoes/emacs-conf.git ~/.config/emacs
```

> Note: Emacs prefers `~/.emacs.d` over `~/.config/emacs`. Make sure no
> `~/.emacs.d` or `~/.emacs` exists, or it will silently shadow this config.

First launch installs the packages from MELPA and native-compiles them.

## Leader keys

`SPC` in normal/visual states, `M-SPC` while typing (insert). Press `SPC` and wait
for the which-key popup. Groups: `f`ile · `b`uffer · `w`indow · `s`earch ·
`p`roject · `c`ode · `g`it · `t`oggle · `h`elp · `q`uit.
