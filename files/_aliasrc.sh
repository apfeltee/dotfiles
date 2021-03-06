#!/bin/bash

alias sg='strgrep -nis'
alias rrm='rm -rf'

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

function mcd()
{
  dest="$1"
  mkdir -p "$dest"
  cd "$dest"
}

# some pretty common cd aliases
alias l=ls
alias ll='ls -l'
alias la='ls -la'
alias lss='ls -1 --sort=time'
alias lsr='ls -1 --sort=time -r'
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias .......="cd ../../../../../.."
alias ........="cd ../../../../../../.."
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"
alias cd..='cd ..'

# lllaaazzzyyyy
alias h='head'
alias f='file'
alias md='mkdir'
alias agdb='autogdb'

#if type most >/dev/null ; then
#  alias v='most -u -v'
#else
  alias v='less -f -F'
#fi

alias cf='countfiles'
# fixing stupidity. fucking yay.
alias tree='tree -C -a -h'
alias gdb='gdb -q'
#alias whois="whois -H"
alias grep='grep --color=auto'
alias rgrep='grep -r --color=auto'
alias ls='ls --color=auto'
alias ls1='ls -1'
alias shelldepth='echo $SHLVL'

alias units='units --verbose'

# sausage fingers
alias sl=ls
alias lsls=ls
alias eit=edit
alias edot=edit
alias ifle=file

# aliases for lwp-request
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
  alias "$method"="lwp-request -m '$method'"
done
unset method

if [[ -n "$SHELL_IS_ZSH" ]]; then
  # list only files, skip directories
  alias lsnd="ls *(D.)"

  # list only directories, skip files
  alias lsod="ls -d *(/)"
fi

