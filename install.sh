#!/bin/bash
set -e

echo "🚀 Setting up your tmux environment..."

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Symlink tmux.conf
echo "🔗 Linking ~/.tmux.conf"
ln -sf "$REPO_DIR/tmux.conf" "$HOME/.tmux.conf"

# Symlink TPM
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "🔗 Linking TPM plugin manager"
  mkdir -p "$HOME/.tmux/plugins"
  ln -sf "$REPO_DIR/plugins/tpm" "$HOME/.tmux/plugins/tpm"
fi

# Init submodules
echo "📦 Initializing plugin submodules"
git submodule update --init --recursive

echo "✅ Done! Open tmux and press prefix + I to install plugins"
