#!/bin/bash
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# git
ln -s ${BASEDIR}/.gitconfig ~/
ln -s ${BASEDIR}/.gitignore_global ~/

# pure
brew install pure

# files
ln -s ${BASEDIR}/.rc ~/.zshrc
# todo: echo this in
# # dotfiles
# . ~/repos/dotfiles/.bash_profile
# ln -s ${BASEDIR}/.profile ~/.zprofile
