#!/bin/bash
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# git
ln -s ${BASEDIR}/.gitconfig ~/
ln -s ${BASEDIR}/.gitignore_global ~/

# pure
mkdir -p "$HOME/.zsh"
if [ ! -d "$HOME/.zsh/pure" ]; then
    git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
fi

# delta
if command -v brew >/dev/null 2>&1; then
  command brew install git-delta
elif command -v apt >/dev/null 2>&1; then
  if [ "$(id -u)" -eq 0 ]; then
    command apt install git-delta
  else
    command sudo apt install git-delta
  fi
else
  printf '%s\n' 'Error: failed to install git-delta neither brew nor apt is installed.' >&2
  return 1
fi

# files
ln -s ${BASEDIR}/.rc ~/.zshrc

# todo: echo this in
# # dotfiles
# . ~/repos/dotfiles/.bash_profile
# ln -s ${BASEDIR}/.profile ~/.zprofile
