# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then                                                                                       
    . /etc/bashrc                                                                                                 
fi

# Environment Variables
export PATH="${HOME}/.local/bin:${PATH}"

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
