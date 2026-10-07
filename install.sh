#!/bin/bash
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

set -euo pipefail

echo "🧑🏽‍🔧 Installing lazd's dotfiles"

# git config
echo "⚙️ Installing git config..."
if [ -f "$HOME/.gitconfig" ] && [ ! "$HOME/.gitconfig" -ef "$BASEDIR/.gitconfig" ] &&
  ! git config --file "$HOME/.gitconfig" --get-all include.path | grep -Fx "$BASEDIR/.gitconfig" >/dev/null; then
  config_tmp=$(mktemp "$HOME/.gitconfig.XXXXXX")
  git config --file "$config_tmp" include.path "$BASEDIR/.gitconfig"
  cat "$HOME/.gitconfig" >> "$config_tmp"
  mv "$config_tmp" "$HOME/.gitconfig"
elif [ ! -e "$HOME/.gitconfig" ]; then
  ln -s "$BASEDIR/.gitconfig" "$HOME/.gitconfig"
fi

# pure
if [ ! -d "$HOME/.zsh/pure" ]; then
  echo "📦 Installing pure prompt..."
  mkdir -p "$HOME/.zsh"
  git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
else 
  echo "📦 pure prompt already installed"
fi

# delta
if ! command -v delta >/dev/null 2>&1; then
  echo "📦 Installing git-delta pager..."
  if command -v brew >/dev/null 2>&1; then
    command brew install git-delta
  elif command -v apt >/dev/null 2>&1; then
    if [ "$(id -u)" -eq 0 ]; then
      command apt update
      command apt install git-delta
    else
      command sudo apt update
      command sudo apt install git-delta
    fi
  else
    printf '%s\n' 'Error: failed to install git-delta neither brew nor apt is installed.' >&2
    return 1
  fi
else
  echo "📦 git-delta pager already installed"
fi

# git ignore
echo "⚙️ Configuring .gitignore_global..."
while IFS= read -r pattern || [ -n "$pattern" ]; do
  if ! grep -Fxq -- "$pattern" "$HOME/.gitignore_global" 2>/dev/null; then
    printf '\n%s\n' "$pattern" >> "$HOME/.gitignore_global"
  fi
done < "$BASEDIR/.gitignore_global"

# profile and rc files
echo "⚙️ Installing profile and rc files..."
if [ ! "$HOME/.zshrc" -ef "$BASEDIR/rc" ] &&
  ! grep -Fxq "source \"$BASEDIR/rc\"" "$HOME/.zshrc" 2>/dev/null; then
  printf '\nsource "%s"\n' "$BASEDIR/rc" >> "$HOME/.zshrc"
fi
if [ ! "$HOME/.zprofile" -ef "$BASEDIR/profile" ] &&
  ! grep -Fxq "source \"$BASEDIR/profile\"" "$HOME/.zprofile" 2>/dev/null; then
  printf '\nsource "%s"\n' "$BASEDIR/profile" >> "$HOME/.zprofile"
fi
