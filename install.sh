#!/bin/bash

basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# dotfiles
rm -f ~/.dotfiles
ln -sT ${basedir}/ ~/.dotfiles

# bashrc
rm -f ~/.bashrc
ln -sT ~/.dotfiles/bashrc ~/.bashrc

# bash profile
rm -f ~/.bash_profile
ln -sT ~/.dotfiles/bash_profile ~/.bash_profile

# dircolors
rm -f ~/.dircolors
ln -sT ~/.dotfiles/dircolors ~/.dircolors

# tmux
rm -f ~/.tmux.conf
ln -sT ~/.dotfiles/tmux.conf ~/.tmux.conf

# emacs
rm -rf ~/.emacs.d
ln -sT ~/.dotfiles/emacs.d/ ~/.emacs.d
# create custom.el if not exists
touch ~/.emacs.d/custom.el

