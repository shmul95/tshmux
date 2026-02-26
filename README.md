# tshmux

**tshmux** is my personal Tmux configuration, designed for speed, clarity, and portability. It includes plugin management, status bar customization, and clean defaults.

This setup features:

* **Nix-native plugin management** - All plugins built and managed through Nix flakes
* **Alt-key workflow** - Comprehensive Alt+key bindings for fast navigation  
* **Vi-style copy mode** - Familiar vim keybindings for text selection and copying
* **Smart clipboard integration** - Automatic detection of system clipboard (Wayland/X11/macOS)
* **Session persistence** - Automatic session save/restore with tmux-resurrect + continuum
* **Clean status bar** - Minimalist yellow-on-black theme with session info
* **Developer shortcuts** - Quick setup commands for common development workflows

---

## Installation

### Option 1: Nix Flake (Recommended)

For Nix users, the easiest way to install tshmux:

```bash
# Install tshmux directly (includes tmux with embedded config)
nix profile add github:shmul95/tshmux

# Run tmux with your configuration
tshmux
```

Or if you want to set up the configuration files locally:

```bash
# Install and setup configuration files
nix profile add github:shmul95/tshmux
tshmux-setup

# Then use regular tmux
tmux
```

### Option 2: Traditional Git Install

```bash
git clone --recurse-submodules https://github.com/shmul95/tshmux.git
cd tshmux
./install.sh
```

### Option 3: Home Manager

Add to your `home.nix`:

```nix
{
  inputs = {
    tshmux.url = "github:shmul95/tshmux";
  };
}
```

Then in your configuration:

```nix
{ inputs, ... }: {
  imports = [ (inputs.tshmux + "/tshmux.nix") inputs ];
  
  shmul.tshmux.enable = true;
}
```

---

## Use It

### With Nix Flake
- Direct use: `tshmux` (runs tmux with embedded config)
- After `tshmux-setup`: `tmux` (uses standard tmux with installed config)

### Traditional Install
- Start tmux: `tmux`
- Install plugins: inside tmux press `prefix` + `I` (default prefix is `Ctrl-b`).
- Reload config any time: `tmux source-file ~/.tmux.conf` (or open a new session).

Once plugins finish installing, your tmux will load this config (theme, keybinds, and plugins).

---

## Available Packages

When using the Nix flake, several packages are available:

* `default` / `tshmux`: Complete setup with `tshmux` and `tshmux-setup` commands  
* `tmux-configured`: Tmux with embedded configuration (no separate setup needed)
* `config`: Just the configuration files and plugins (for manual setup)
* `plugins`: All tmux plugins as nix packages

Examples:
```bash
# Install the complete package (default)
nix profile add github:shmul95/tshmux

# Install just the configured tmux binary
nix profile add github:shmul95/tshmux#tmux-configured

# Install just the config files
nix profile add github:shmul95/tshmux#config
```

## Plugins Included

tshmux comes with a curated set of tmux plugins, automatically managed through Nix:

| Plugin | Purpose | Repository |
|--------|---------|------------|
| **TPM** | Tmux Plugin Manager | [tmux-plugins/tpm](https://github.com/tmux-plugins/tpm) |
| **tmux-sensible** | Sensible tmux defaults | [tmux-plugins/tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) |
| **tmux-resurrect** | Save/restore tmux sessions | [tmux-plugins/tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) |
| **tmux-continuum** | Automatic session save/restore | [tmux-plugins/tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) |
| **tmux-yank** | Copy to system clipboard | [tmux-plugins/tmux-yank](https://github.com/tmux-plugins/tmux-yank) |
| **vim-tmux-navigator** | Seamless vim-tmux navigation | [christoomey/vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) |

*Note: With the Nix flake approach, plugins are automatically built and loaded—no manual plugin installation required.*

---

## Keybindings

### Window Management
| Key | Action | Description |
|-----|--------|-------------|
| `Alt+n` | New window | Create new window in current directory |
| `Alt+Shift+N` | New session | Prompt for new session name, create in current directory |
| `Alt+d` | Detach | Detach from current tmux session |

### Window Navigation  
| Key | Action | Description |
|-----|--------|-------------|
| `Alt+h` | Window 0 | Jump to window 0 |
| `Alt+j` | Window 1 | Jump to window 1 |
| `Alt+k` | Window 2 | Jump to window 2 |
| `Alt+l` | Window 3 | Jump to window 3 |
| `Alt+Shift+H` | Window 4 | Jump to window 4 |
| `Alt+Shift+J` | Window 5 | Jump to window 5 |
| `Alt+Shift+K` | Window 6 | Jump to window 6 |
| `Alt+Shift+L` | Window 7 | Jump to window 7 |

### Pane Management
| Key | Action | Description |
|-----|--------|-------------|
| `Alt+-` | Vertical split | Split pane vertically (side-by-side) |
| `Alt+_` | Horizontal split | Split pane horizontally (stacked) |
| `Alt+←` | Move left | Move to left pane |
| `Alt+→` | Move right | Move to right pane |  
| `Alt+↑` | Move up | Move to upper pane |
| `Alt+↓` | Move down | Move to lower pane |

### Session Management
| Key | Action | Description |
|-----|--------|-------------|
| `Alt+s` | Session switcher | Open session tree chooser |
| `Alt+r` | Restore session | Restore sessions via tmux-resurrect |

### Copy Mode & Clipboard
| Key | Action | Description |
|-----|--------|-------------|
| `Alt+q` | Enter copy mode | Enter vi-style copy mode |
| `v` (in copy mode) | Begin selection | Start visual selection |
| `V` (in copy mode) | Line selection | Select entire line |
| `y` (in copy mode) | Yank to clipboard | Copy selection to system clipboard and exit |
| `Escape` / `Alt+q` (in copy mode) | Exit copy mode | Cancel copy mode |

### Quick Setup
| Key | Action | Description |
|-----|--------|-------------|
| `Alt+w` | Work session | Run `copilot`, open nvim window, and create terminal window |
| `Alt+:` | Command prompt | Open tmux command prompt |

### Plugin Features

#### tmux-resurrect & tmux-continuum
- **Auto-save**: Sessions automatically saved every 15 minutes
- **Auto-restore**: Sessions restored on tmux start
- **Manual restore**: `Alt+r` to manually restore sessions
- **Captures**: Pane contents, working directories, and running programs

#### vim-tmux-navigator  
- Seamlessly navigate between vim splits and tmux panes with `Ctrl+h/j/k/l`
- Works automatically when vim-tmux-navigator is installed in vim/neovim

#### tmux-yank
- **Smart clipboard**: Automatically detects system clipboard (wl-copy, xclip, or pbcopy)
- **Copy integration**: `y` in copy mode copies to system clipboard
- **Mouse support**: Click and drag selection automatically copies

---

## Structure

```
tshmux/
├── tmux.conf              → Main Tmux config
├── install.sh             → Symlinks and setup
└── plugins/
    └── tpm/               → Tmux Plugin Manager (TPM)
```

---

## What It Does

* Symlinks `tmux.conf` to `~/.tmux.conf`
* Links TPM to `~/.tmux/plugins/tpm`
* Initializes plugin submodules
* Prompts you to install plugins with `<prefix> + I` inside Tmux

---

## Requirements

* `tmux`
* Git (for plugin installation)
* Clipboard helper for tmux-yank (`xclip`, `xsel`, or `wl-clipboard`). The installer attempts to add one automatically on Linux; install manually if you're on a platform it can't detect.

Notes:
- This config sets zsh as the default shell. If your zsh path differs (e.g., `/bin/zsh`) or you prefer another shell, edit the two `default-shell`/`default-command` lines near the top of `tmux.conf`.

---

## Update / Uninstall

- Update: `git pull --recurse-submodules && git submodule update --init --recursive` then restart tmux (or `tmux source-file ~/.tmux.conf`).
- Uninstall: remove the symlink `~/.tmux.conf` and the TPM link at `~/.tmux/plugins/tpm` if created.

---

## License

MIT — feel free to use, fork, and adapt.
