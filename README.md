# tshmux

🔧 **tshmux** is my personal Tmux configuration, designed for speed, clarity, and portability. It includes plugin management, status bar customization, and clean defaults.

This setup features:

* A modular `~/.tmux.conf` with powerline-style status bar
* Integrated plugin management using [TPM (Tmux Plugin Manager)](https://github.com/tmux-plugins/tpm)
* Submodule structure for consistent installs across systems

---

## 📦 Installation

```bash
git clone --recurse-submodules https://github.com/shmul95/tshmux.git
cd tshmux
./install.sh
```

---

## 🚀 Use It

- Start tmux: `tmux`
- Install plugins: inside tmux press `prefix` + `I` (default prefix is `Ctrl-b`).
- Reload config any time: `tmux source-file ~/.tmux.conf` (or open a new session).

Once plugins finish installing, your tmux will load this config (theme, keybinds, and plugins).

---

## ⌨️ Keybindings

- Alt-n: new window in current directory
- Alt-d: detach client
- Alt-q: enter copy-mode (vi keys enabled)
- Alt-s: session tree switcher
- Alt-h/j/k/l: jump to windows 1–4; Alt-H/J/K/L: windows 5–8
- Alt-Left/Right/Up/Down: move between panes
- Alt--: vertical split (side-by-side)
- Alt-_: horizontal split (stacked)
- Alt-:: tmux command prompt
- Alt-r: restore sessions (tmux-resurrect)
- Alt-w: create a preconfigured "work" session (lazygit, nvim, term)

---

## 📁 Structure

```
tshmux/
├── tmux.conf              → Main Tmux config
├── install.sh             → Symlinks and setup
└── plugins/
    └── tpm/               → Tmux Plugin Manager (TPM)
```

---

## 🔧 What It Does

* Symlinks `tmux.conf` to `~/.tmux.conf`
* Links TPM to `~/.tmux/plugins/tpm`
* Initializes plugin submodules
* Prompts you to install plugins with `<prefix> + I` inside Tmux

---

## ✅ Requirements

* `tmux`
* Git (for plugin installation)
* Clipboard helper for tmux-yank (`xclip`, `xsel`, or `wl-clipboard`). The installer attempts to add one automatically on Linux; install manually if you're on a platform it can't detect.

Notes:
- This config sets zsh as the default shell. If your zsh path differs (e.g., `/bin/zsh`) or you prefer another shell, edit the two `default-shell`/`default-command` lines near the top of `tmux.conf`.

---

## 🔄 Update / Uninstall

- Update: `git pull --recurse-submodules && git submodule update --init --recursive` then restart tmux (or `tmux source-file ~/.tmux.conf`).
- Uninstall: remove the symlink `~/.tmux.conf` and the TPM link at `~/.tmux/plugins/tpm` if created.

---

## 💬 License

MIT — feel free to use, fork, and adapt.
