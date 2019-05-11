# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Environment Variables
# Set git env
export GIT_EDITOR="emacs"
# Set locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
# Local Executables
export PATH="${HOME}/.local/bin:${PATH}"
export PATH="${HOME}/.dotfiles/bin:${PATH}"
export PATH="${HOME}/.cargo/bin:${PATH}"
# macOS Homebrew Compatibility
# Import serveral paths of the homebrew-installed packges into PATH.
export PATH="/usr/local/opt/coreutils/libexec/gnubin:${PATH}"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:${MANPATH}"
export PATH="/usr/local/opt/gettext/bin:${PATH}"
export PATH="/usr/local/opt/curl/bin:${PATH}"

# Alias
alias ls='ls --color'
alias l='ls -lh'
alias ll='ls -Alh'
alias ..='cd ..'
alias ...='cd ../..'

# Alias for Socks Proxy
alias proxy='export all_proxy=socks5://127.0.0.1:1080'
alias unproxy='unset all_proxy'

# Prompt
export PS1="[\u@\h:\w]\$ "

# ls colors
eval $( dircolors -b $HOME/.ls_colors )
