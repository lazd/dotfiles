#!/bin/bash
if [ -n "${BASH_VERSION:-}" ]; then
  BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  BASEDIR="${${(%):-%x}:A:h}"
fi

# error handling
set -euo pipefail

# read args
install_delta=false
for arg in "$@"; do
  if [ "$arg" = --delta ]; then
    install_delta=true
  fi
done

echo "🧑🏽‍🔧 Installing lazd's dotfiles"

# delete old links to dotfiles
for file in .gitconfig .zshrc .zprofile .bashrc .bash_profile; do
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
  echo "⚙️  Installing git config..."
  git config --global --add include.path "$BASEDIR/gitconfig_base"
else
  echo "✅ git config already installed"
fi

# git user info
git_user_info_set=false
for key in user.name user.email; do
  if ! git config --global --includes --get "$key" >/dev/null; then
    echo "⚙️  Setting git user information: $key..."
    git config --global "$key" "$(git config --file "$BASEDIR/gitconfig_user" --get "$key")"
    git_user_info_set=true
  fi
done
if [ "$git_user_info_set" = false ]; then
  echo "✅ git user information already set up locally"
fi

# git ignore
if [ "$(git config --global --includes --get core.excludesFile || true)" != "$BASEDIR/gitignore_global" ]; then
  echo "⚙️  Configuring .gitignore_global..."
  git config --global core.excludesFile "$BASEDIR/gitignore_global"
else
  echo "✅ .gitignore_global already configured"
fi

# profile and rc files
for file in .zshrc .bashrc; do
  if [ ! "$HOME/$file" -ef "$BASEDIR/rc" ] &&
    ! grep -Fxq "source \"$BASEDIR/rc\"" "$HOME/$file" 2>/dev/null; then
    echo "⚙️  Installing rc in $file..."
    printf '\nsource "%s"\n' "$BASEDIR/rc" >> "$HOME/$file"
  else
    echo "✅ rc already installed in $file"
  fi
done

for file in .zprofile .bash_profile; do
  if [ ! "$HOME/$file" -ef "$BASEDIR/profile" ] &&
    ! grep -Fxq "source \"$BASEDIR/profile\"" "$HOME/$file" 2>/dev/null; then
    echo "⚙️  Installing profile in $file..."
    printf '\nsource "%s"\n' "$BASEDIR/profile" >> "$HOME/$file"
  else
    echo "✅ profile already installed in $file"
  fi
done

if ! grep -Eq '(^|[[:space:]])(source|\.)[[:space:]].*\.bashrc' "$HOME/.bash_profile"; then
  printf '\n[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"\n' >> "$HOME/.bash_profile"
fi

# starship
source "$BASEDIR/profile"
if ! command -v starship >/dev/null 2>&1; then
  echo "📦 Installing Starship prompt..."
  mkdir -p "$HOME/.local/bin"
  command curl -fsSL https://starship.rs/install.sh | command sh -s -- -y --bin-dir "$HOME/.local/bin"
else
  echo "✅ Starship prompt already installed"
fi

starship_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
starship_config="$starship_config_dir/starship.toml"
mkdir -p "$starship_config_dir"
if [ ! "$starship_config" -ef "$BASEDIR/starship.toml" ]; then
  if [ -e "$starship_config" ] || [ -L "$starship_config" ]; then
    rm "$starship_config"
    echo "🧹 Removed existing Starship config"
  fi
  ln -s "$BASEDIR/starship.toml" "$starship_config"
  echo "✅ Installed Starship config"
else
  echo "✅ Starship config already installed"
fi

# delta
if [ "$install_delta" = true ] && ! command -v delta >/dev/null 2>&1; then
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
    printf '%s\n' '🛑 Error: failed to install git-delta neither brew nor apt is installed.' >&2
    exit 1
  fi
elif command -v delta >/dev/null 2>&1; then
  echo "✅ git-delta pager already installed"
fi

if command -v delta >/dev/null 2>&1; then
  git config --global core.pager delta
  git config --global interactive.diffFilter 'delta --color-only'
fi

echo "✨ Open a new terminal to load the shell configuration!"
