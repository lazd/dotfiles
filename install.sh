#!/bin/bash
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

set -euo pipefail

echo "🧑🏽‍🔧 Installing lazd's dotfiles"

# delete old links to dotfiles
for file in .gitconfig .zshrc .zprofile; do
  if [ -L "$HOME/$file" ]; then
    target=$(readlink "$HOME/$file")
    if [[ "$target" != /* ]]; then
      target="$HOME/$target"
    fi
    target_dir=$(cd "$(dirname "$target")" 2>/dev/null && pwd -P) || continue
    case "$target_dir/" in
      "$BASEDIR/"*)
        echo "🧹 Removing old symlink for $file..."
        rm "$HOME/$file"
        : > "$HOME/$file"
        ;;
    esac
  fi
done

# git config
if ! git config --global --get-all include.path | grep -Fxq -- "$BASEDIR/gitconfig_base"; then
  echo "⚙️ Installing git config..."
  git config --global --add include.path "$BASEDIR/gitconfig_base"
else
  echo "✅ git config already installed"
fi

# git user info
git_user_info_set=false
for key in user.name user.email; do
  if ! git config --global --includes --get "$key" >/dev/null; then
    echo "⚙️ Setting git user information: $key..."
    git config --global "$key" "$(git config --file "$BASEDIR/gitconfig_user" --get "$key")"
    git_user_info_set=true
  fi
done
if [ "$git_user_info_set" = false ]; then
  echo "✅ git user information already set up locally"
fi

# git ignore
if [ "$(git config --global --includes --get core.excludesFile || true)" != "$BASEDIR/gitignore_global" ]; then
echo "⚙️ Configuring .gitignore_global..."
  git config --global core.excludesFile "$BASEDIR/gitignore_global"
else
  echo "✅ .gitignore_global already configured"
fi

# profile and rc files
if [ ! "$HOME/.zshrc" -ef "$BASEDIR/rc" ] &&
  ! grep -Fxq "source \"$BASEDIR/rc\"" "$HOME/.zshrc" 2>/dev/null; then
  echo "⚙️ Installing rc..."
  printf '\nsource "%s"\n' "$BASEDIR/rc" >> "$HOME/.zshrc"
else
  echo "✅ rc already installed"
fi

if [ ! "$HOME/.zprofile" -ef "$BASEDIR/profile" ] &&
  ! grep -Fxq "source \"$BASEDIR/profile\"" "$HOME/.zprofile" 2>/dev/null; then
  echo "⚙️ Installing profile..."
  printf '\nsource "%s"\n' "$BASEDIR/profile" >> "$HOME/.zprofile"
else
  echo "✅ profile already installed"
fi

# pure
if [ ! -d "$HOME/.zsh/pure" ]; then
  echo "📦 Installing pure prompt..."
  mkdir -p "$HOME/.zsh"
  git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
else 
  echo "✅ pure prompt already installed"
fi

# delta
if ! command -v delta >/dev/null 2>&1; then
  echo "📦 Installing git-delta pager..."
  if command -v brew >/dev/null 2>&1; then
    command brew install -y git-delta
  elif command -v apt >/dev/null 2>&1; then
    if [ "$(id -u)" -eq 0 ]; then
      command apt update
      command apt install -y git-delta
    else
      command sudo apt update
      command sudo apt install -y git-delta
    fi
  else
    printf '%s\n' 'Error: failed to install git-delta neither brew nor apt is installed.' >&2
    return 1
  fi
else
  echo "✅ git-delta pager already installed"
fi
