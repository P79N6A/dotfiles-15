# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Environment Variables
# Local Executables
export PATH="${HOME}/.dotfiles/bin:${PATH}"
# macOS Homebrew Compatibility
# Import serveral paths of the homebrew-installed packges into PATH.
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
export PATH="/usr/local/opt/gettext/bin:$PATH"
export PATH="/usr/local/opt/curl/bin:$PATH"

# Alias
alias ls='ls --color'
alias l='ls -lh'
alias ll='ls -Alh'
alias ..='cd ..'
alias ...='cd ../..'

# Prompt
export PS1="[\u@\h:\w]\$ "

# ls colors
eval $( dircolors -b $HOME/.ls_colors )
