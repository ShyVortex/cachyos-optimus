#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fastfetch='fastfetch -c neofetch.jsonc'
PS1='[\[\e[1;92m\]\u\[\e[1;97m\]@\[\e[1;96m\]\h\[\e[0m\] \[\e[1;94m\]\w\[\e[0m\]]\$ '

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

. "$HOME/.local/bin/env"


# Load Angular CLI autocompletion.
source <(ng completion script)
