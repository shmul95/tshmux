<div align="center">

# tshmux

**An opinionated, Nix-native tmux distribution.**
*Zero plugin bootstrap. Alt-key navigation. Ready in one command.*

[![Nix Flake](https://img.shields.io/badge/Nix-Flake-5277C3?logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)
[![tmux](https://img.shields.io/badge/tmux-managed-1BB91F?logo=tmux&logoColor=white)](https://github.com/tmux/tmux)
[![Home Manager](https://img.shields.io/badge/Home%20Manager-supported-7EB26D)](https://github.com/nix-community/home-manager)
[![Built with Nix](https://img.shields.io/badge/Built%20with-Nix-5277C3?logo=nixos&logoColor=white)](https://nixos.org)

[Quick Start](#quick-start) · [Highlights](#highlights) · [Keybindings](#keybindings-reference) · [Plugins](#plugins-included)

</div>

---

A typical tmux setup means installing TPM, copying a `.tmux.conf`, restarting tmux, hitting `prefix + I` to fetch plugins, and praying the clipboard works. `tshmux` skips all of that. Plugins are built by Nix at flake-eval time, the config is embedded, and the binary is one `nix profile` install away. The same flake works as a standalone command or a Home Manager module.

## Highlights

- **Nix-built plugins** — TPM, sensible, continuum, yank, vim-tmux-navigator are all built declaratively. No `prefix + I`, no plugin directory drift across machines.
- **Alt-key workflow** — windows, panes, splits, copy mode, and session switching all live on `Alt+<key>`. The leader stays free for muscle memory.
- **Vi-style copy mode** — `v` / `V` / `y` for select / line-select / yank, with automatic detection of `wl-copy`, `xclip`, or `pbcopy`.
- **Two install modes** — `nix profile` for an isolated `tshmux` command, or a Home Manager module that takes over `programs.tmux` directly.
- **Auto-save sessions** — tmux-continuum keeps your layout safe every 15 minutes; restored on next start.

## Architecture

```
tshmux/
├── flake.nix          # plugin set, packages, home-manager module
├── home-manager.nix   # programs.tshmux module exposed via the flake
├── tmux.conf          # the embedded config (keybinds, theme, plugin list)
└── flake.lock
```

Two outputs to choose from:

- `packages.<system>.default` — the standalone `tshmux` binary that launches tmux with the embedded config.
- `homeManagerModules.default` — a `programs.tshmux.enable` toggle that wires everything into your Home Manager setup.

## Quick Start

**Standalone (fastest path):**

```bash
nix profile add github:shmul95/tshmux
tshmux
```

**Home Manager:**

```nix
{
  inputs.tshmux.url = "github:shmul95/tshmux";
}
```

```nix
{ inputs, ... }: {
  imports = [ inputs.tshmux.homeManagerModules.default ];
  programs.tshmux.enable = true;
}
```

After `home-manager switch`, plain `tmux` picks up the full configuration — no extra flags, no plugin install step.

## Plugins Included

All built by Nix and loaded automatically — no manual install, no TPM bootstrap.

| Plugin | Purpose | Repository |
|--------|---------|------------|
| **TPM** | Plugin runtime | [tmux-plugins/tpm](https://github.com/tmux-plugins/tpm) |
| **tmux-sensible** | Sensible defaults | [tmux-plugins/tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) |
| **tmux-continuum** | Auto-save / auto-restore sessions | [tmux-plugins/tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) |
| **tmux-yank** | System clipboard integration | [tmux-plugins/tmux-yank](https://github.com/tmux-plugins/tmux-yank) |
| **vim-tmux-navigator** | Seamless vim ↔ tmux pane motion | [christoomey/vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) |

## Requirements

- Nix with flakes enabled
- A clipboard tool on `PATH` for yanking (`wl-copy`, `xclip`, or `pbcopy` — auto-detected)

tmux itself is provided by the flake.

## Updating

```bash
nix profile upgrade github:shmul95/tshmux       # standalone
home-manager switch                              # Home Manager users
```

## Keybindings Reference

### Window management

| Key | Action |
|-----|--------|
| `Alt+n` | New window in current directory |
| `Alt+Shift+N` | New session (prompts for name) |
| `Alt+d` | Detach session |

### Window navigation

| Key | Window |
|-----|--------|
| `Alt+h` / `j` / `k` / `l` | Jump to window 0 / 1 / 2 / 3 |
| `Alt+Shift+H` / `J` / `K` / `L` | Jump to window 4 / 5 / 6 / 7 |

### Pane management

| Key | Action |
|-----|--------|
| `Alt+-` | Split vertical (side-by-side) |
| `Alt+_` | Split horizontal (stacked) |
| `Alt+←` / `→` / `↑` / `↓` | Move between panes |
| `Ctrl+h` / `j` / `k` / `l` | Vim-aware pane motion (via vim-tmux-navigator) |

### Session management

| Key | Action |
|-----|--------|
| `Alt+s` | Session tree (press `x` inside to kill a session) |
| `Alt+Shift+X` | Kill current session (with confirmation) |

### Copy mode & clipboard

| Key | Action |
|-----|--------|
| `Alt+q` | Enter copy mode |
| `v` / `V` (in copy mode) | Begin selection / line selection |
| `y` (in copy mode) | Yank to system clipboard and exit |
| `Escape` or `Alt+q` | Exit copy mode |

### Quick setup

| Key | Action |
|-----|--------|
| `Alt+w` | Work session: run `copilot`, open nvim, spawn a terminal window |
| `Alt+:` | tmux command prompt |

---

<div align="center">

Built with Nix · Crafted by <a href="https://github.com/shmul95">@shmul95</a>

Part of the <a href="https://github.com/shmul95/zshmul">zshmul</a> · <strong>tshmux</strong> · <a href="https://github.com/shmul95/shmulvim">shmulvim</a> · <a href="https://github.com/shmul95/cabanashmul">cabanashmul</a> family

</div>
