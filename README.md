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

---

## 💬 License

MIT — feel free to use, fork, and adapt.
