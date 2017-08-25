#!/bin/bash

function cdd
{
  cd "$HOME/Desktop"
}

function mount
{
  if [[ -n $1 ]]; then
    /bin/mount "$@"
  else
    /bin/mount | column -t
  fi
}

function digga()
{
  dig +nocmd "$1" any +multiline +noall +answer;
}

# some pretty common cd aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"
alias cd..='cd ..'

# fixing stupidity. fucking yay.
alias tree='tree -C -a -h'
alias gdb='gdb -q'
#alias whois="whois -H"
alias grep='grep --color=auto'
alias rgrep='grep -r --color=auto'
alias ls='ls --color=auto'
alias sl=ls
alias units='units --verbose'

# sausage fingers
alias lsls=ls
alias eit=edit
alias edot=edit

for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
  alias "$method"="lwp-request -m '$method'"
done

