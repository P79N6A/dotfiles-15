#!/bin/bash

basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# dotfiles
ln -isT ${basedir}/ ~/.dotfiles

# emacs
rm -f ~/.emacs.d
ln -isT ~/.dotfiles/emacs.d/ ~/.emacs.d

# yasnippets
rm -f ~/.yasnippets
ln -isT ~/.dotfiles/yasnippets ~/.yasnippet
