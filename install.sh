#!/bin/bash
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# git
ln -s ${BASEDIR}/.gitconfig ~/
ln -s ${BASEDIR}/.gitignore_global ~/
