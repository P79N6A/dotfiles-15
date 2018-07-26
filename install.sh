#!/bin/bash

basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# dotfiles
ln -isT ${basedir}/ ~/.dotfiles

# emacs
rm -rf ~/.emacs.d
ln -isT ~/.dotfiles/emacs.d/ ~/.emacs.d

