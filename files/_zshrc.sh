#!/bin/zsh

# cygwin bug(?): when program is run via 'cygstart --action=runas' (admin privs), then
# the spawned process inherits windows %PATH%, causing the process to not see
# paths like /bin, /usr/bin... you get the idea.
# actuall PATH munging happens further down; this just sets a sensible default.
export PATH="/bin:/usr/bin:/usr/local/bin:$PATH"

if [[ -z "$ZSH_VERSION" ]]; then
  echo "this file can only work under zsh!"
  return 1
fi

# if zsh is invoked via 'exec -c' (i.e., clear environment), then
# $TERM is not set. this fixes it.
if [[ -z "$TERM" ]]; then
  export TERM="cygwin"
fi

# needed mostly for .aliasrc
export SHELL_IS_ZSH=1

# actually, don't
#emulate -L bash
export FPATH="$HOME/.config/zshfunctions:$FPATH"

# more history, please ...
export HISTSIZE=500


# init and load autocomplete as well as builtin prompt stuff
autoload -Uz compinit promptinit
compinit -u
promptinit

########################################
### ******************************** ###
### *** TAB-COMPLETION UNFUCKERY *** ###
### ******************************** ###
########################################
# disable completions for some custom commands
compdef -d new open sh mpc man jq node

#autoload -Uz quote-and-complete-word
#zle -N quote-and-complete-word
#bindkey '\t' quote-and-complete-word

# don't be a moron, remember these neat lil things:
# for file (*.c) echo "$file"

# adds 'help' command, a la bash
unalias run-help 2>/dev/null
autoload run-help
# not really necessary, i think...?
#HELPDIR=/path/to/zsh_help_directory
alias help=run-help

##
## some initial options
##
#zsh is a tad too noisy by default
setopt no_beep
setopt extended_glob
setopt autolist
setopt menu_complete
# allow usage of comments (#) in interactive shell
setopt interactive_comments
setopt IGNORE_EOF
# unnecessary
setopt rm_star_silent
# get rid of '!: event not found' bullshit.
# does anyone even use history refs?
unsetopt banghist
# make glob case-insensitive
unsetopt case_glob
# always skip straight to last prompt
unsetopt always_last_prompt
# disable zsh trying to handle failed globs - instead forward as-is
unsetopt no_match
# if the braces aren't in either of the above forms, expands single
# letters and ranges of letters, i. e.:
#  $ print 1{abw-z}2
#  $ 1a2 1b2 1w2 1x2 1y2 1z2
setopt braceccl
# Make cd push the old directory onto the directory stack. 
setopt autopushd
# Don't push multiple copies of the same directory onto the directory
# stack
setopt pushdignoredups
# i'd like to keep it, thanks
setopt no_auto_remove_slash

# stop shit like "suspended (tty output)"
stty -tostop

# default is 100. it's annoying
export LISTMAX=800

# autoquote pasted URLs
#autoload -Uz url-quote-magic
#zle -N self-insert url-quote-magic

# makes end (ende) / home (POS1) keys work
#bindkey "${terminfo[khome]}" beginning-of-line || true
#bindkey "${terminfo[kend]}" end-of-line || true

#zstyle '*' single-ignored show
zstyle '*' single-ignored complete
# give <tab> some color
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ''

# afaik this is the closest to emulate windows-style sorting
zstyle ':completion:*' file-sort name

# This tells zsh that small letters will match small and capital letters.
# (i.e. capital letters match only capital letters.)
#if [[ "$HYPHEN_INSENSITIVE" = true ]]; then
#zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
#zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
# If you want that capital letters also match small letters use instead:
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# If you want case-insensitive matching only if there are no case-sensitive matches add '', e.g.
#zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
# make autocomplete case-insensitive (mostly for cygwin)
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# debugging utilities
function zsh-dump-keybinds
{
  # all key bindings:
  for m ($keymaps) bindkey -LM $m
}

function zsh-dump-widgets
{
  # all ZLE user widgets
  zle -lL
}

function zsh-dump-zstyles
{
  # all zstyles:
  zstyle -L
}

function zsh-dump-modules
{
  # loaded modules:
  zmodload -L
}

function zsh-dump-variables
{
  # all variables:
  typeset -p +H -m '*'
}

function zsh-dump-options
{
  # print all options
  print -aC2 ${(kv)options}
}


# set up os-specific stuff
g_operatingsystem="$(uname -o | perl -pe '$_=lc($_); s#gnu/##gi')"
if [[ "$g_operatingsystem" == "cygwin" ]]; then
  g_os_cygwin=1
  g_os_pathprefix="/cygdrive/c"
  export DISPLAY=:0.0
  # if, for whatever reason, $CYGWIN *still* isn't defined, set it up here
  # to include native support for symbolic links
  export CYGWIN="winsymlinks:native wincmdln"
  #export CYGWIN="winsymlinks wincmdln"
elif [[ "$g_operatingsystem" =~ msys* ]]; then
  g_os_msys=1
  g_os_pathprefix="/c"
fi

#####################################
############ language settings ######
#####################################
#+ NB. keep it at C.utf-8. it's the safest choice
export LANG=C.UTF-8



###############################
### utility env values for ####
### some programs #############
###############################
#export EDITOR="$HOME/bin/edit"
if [[ "$g_operatingsystem" =~ (cygwin|msys*) ]]; then
  # needed for a variety of java programs
  # but these are typically set by Linux very differently, so
  # this is only for cygwin, obviously
  #export JAVA_HOME="C:/progra~1/Java/jdk/"
  #export JRE_HOME="C:/progra~1/Java/jre/"
fi

###############################
#### C/C++ Include Paths ######
###############################
cppincludepaths=(
  "${g_os_pathprefix}/cloud/local/sharedcode/include"
)
export CPATH="$(IFS=":"; echo "${cppincludepaths[*]}")"
export CPLUS_INCLUDE_PATH="$CPATH"

#########################################################
#### this is just a dump from a termux bash session #####
#########################################################
# SHELL=/data/data/com.termux/files/usr/bin/bash
# PREFIX=/data/data/com.termux/files/usr
# PWD=/data/data/com.termux/files/home/remote/dotfiles
# EXTERNAL_STORAGE=/sdcard
# LD_PRELOAD=/data/data/com.termux/files/usr/lib/libtermux-exec.so
# HOME=/data/data/com.termux/files/home
# LANG=en_US.UTF-8
# TMPDIR=/data/data/com.termux/files/usr/tmp
# ANDROID_DATA=/data
# TERM=xterm-256color
# SHLVL=0
# ANDROID_ROOT=/system
# PATH=/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/bin/applets
# OLDPWD=/data/data/com.termux/files/home/remote/dotfiles/files
# _=/data/data/com.termux/files/usr/bin/env

###############################
####### PATH elements #########
###############################
# don't use $JAVA_HOME or $JRE_HOME here!
userpath=(

  # termux (!!!THESE HAVE TO BE AT THE TOP!!!)
  "/data/data/com.termux/files/bin"
  "/data/data/com.termux/files/usr/bin"
  "/data/data/com.termux/files/usr/bin/applets"

  # standard paths (unix, linux, cygwin, et cetera)
  "/usr/bin"
  "/bin"
  "/usr/sbin"
  "/usr/local/bin"
  "$HOME/bin"
  "$HOME/.local/bin"

  # this needs to be merged at some point
  "${g_os_pathprefix}/cloud/local/dev/home-paths/bin"

  # contains symlinks for windows commands
  "${g_os_pathprefix}/cloud/local/dev/winbin/bin"

  # symlinks to prod-rel clang-fix are generated there
  "${g_os_pathprefix}/cloud/local/dev/clangfix/bin"

  # rakudo auto-installs to c:/rakudo ... :-(
  "${g_os_pathprefix}/rakudo/bin"
  "${g_os_pathprefix}/rakudo/share/perl6/site/bin"

  # programs that technically exist for UNIX-ish oses, but are a
  # royal pain in the ass to build on cygwin
  "${g_os_pathprefix}/progra~1/DockerTB"
  "${g_os_pathprefix}/Users/${USER}/.cargo/bin"
  "${g_os_pathprefix}/Users/${USER}/.rustup/toolchains/nightly-x86_64-pc-windows-msvc/bin"
  "${g_os_pathprefix}/scripting/nodejs/"
  "${g_os_pathprefix}/scripting/zig/"
  "${g_os_pathprefix}/Users/${USER}/AppData/Roaming/npm"
  "${g_os_pathprefix}/Users/sebastian/go/bin/"
  #"${g_os_pathprefix}/cloud/gdrive/portable/systemtools/otvdm"
  "${g_os_pathprefix}/cloud/gdrive/portable/ipfs/"  
  "${g_os_pathprefix}/cloud/gdrive/portable/devtools/other"
  "${g_os_pathprefix}/cloud/gdrive/portable/devtools/re2c/bin"
  "${g_os_pathprefix}/cloud/gdrive/portable/devtools/go/bin"
  "${g_os_pathprefix}/cloud/gdrive/portable/devtools/freebasic"
  "${g_os_pathprefix}/cloud/gdrive/portable/devtools/nasm"
  "${g_os_pathprefix}/cloud/gdrive/portable/devtools/borlandcpp/bin"
  "${g_os_pathprefix}/cloud/gdrive/portable/devtools/ikvm/bin"
  "${g_os_pathprefix}/cloud/gdrive/portable/video/mkvtoolnix/"
  "${g_os_pathprefix}/cloud/gdrive/portable/android/bin"

  # fpc, lazarus, et al
  "${g_os_pathprefix}/cloud/gdrive/portable/devtools/lazarus/fpc/3.0.4/bin/x86_64-win64"
  "${g_os_pathprefix}/cloud/gdrive/portable/devtools/pas2js/bin"



  # distinctly windows-specific paths
  # (either don't exist for *nix, or integrate very poorly with cygwin)
  "${g_os_pathprefix}/Users/${USER}/.dotnet/tools/"
  "${g_os_pathprefix}/cloud/gdrive/portable/devtools/apache-ant/bin"
  #"${g_os_pathprefix}/cloud/gdrive/portable/devtools/dlang/dmd/dmd2/windows/bin"
  "${g_os_pathprefix}/cloud/gdrive/portable/devtools/dlang/ldc/bin"
  "${g_os_pathprefix}/cloud/gdrive/portable/unsorted"
  "${g_os_pathprefix}/go/bin"
  "${g_os_pathprefix}/cheerp/pathbin"
  "${g_os_pathprefix}/progra~2/WABT/bin/"
  "${g_os_pathprefix}/progra~2/binaryen/bin/"
  "${g_os_pathprefix}/progra~1/Java/bin/"
  "${g_os_pathprefix}/progra~1/Java/jdk/bin/"

  #"${g_os_pathprefix}/ProgramData/Chocolatey/bin"
  "${g_os_pathprefix}/Progra~1/qemu"
  "${g_os_pathprefix}/tools/dart-sdk/bin"
  #"${g_os_pathprefix}/Progra~1/dotnet"
  #"${g_os_pathprefix}/users/$USER/.dotnet/x64"
  #"${g_os_pathprefix}/Windows"
  #"${g_os_pathprefix}/Windows/system32"
  #"${g_os_pathprefix}/Windows/System32/WindowsPowerShell/v1.0"
)

# don't use ruby on termux!
if ! type ruby >/dev/null || [[ "$HOME" =~ /.*termux.*/ ]]; then
  #export PATH="$(__strjoin ':' "${userpath[@]}")"
  tmppathval=""
  for item in "${userpath[@]}"; do
    if [[ -d "$item" ]]; then
      if [[ "$tmppathval" == "" ]]; then
        tmppathval="$item"
      else
        tmppathval="$item:$tmppathval"
      fi
    fi
  done
  export PATH="$tmppathval"
  unset tmppathval
else
  # if ruby exists, then use a more sophisticated way of removing duplicates
  # and non-existant dirs from $PATH
  # this is only run once per login
  export PATH="$(
    ruby --disable-gems -e '
      class FStat < File::Stat
        attr_accessor :path
        def initialize(path)
          super(path)
          @path = path
        end
      end
      newpath = []
      oldpath = ARGV
      ## uncomment this line to use path entries added by system and/or conemu
      ## keep in mind that it adds A TON of paths that are not really useful in cygwin!
      ## also, keep in mind that reducing $PATH can result in a faster cygwin environment
      #oldpath = ENV["PATH"].split(/:/) + ARGV
      oldpath.map{|f| if File.exist?(f) then FStat.new(f) else nil end }.each do |pa|
        next if pa.nil?
        if File.directory?(pa.path) then
          if not newpath.include?(pa) then
            #$stderr.printf("pa => %p\n", pa)
            newpath.push(pa.path)
          end
        end
      end
      $stdout.print(newpath.join(":"))
    ' "${userpath[@]}"
  )"
fi
unset userpath

######################
#### docker ##########
######################
### !!!TODO!!! create these variables in a more dynamic way
if type docker >/dev/null; then
  #DOCKER_HOST=tcp://192.168.99.100:2376
  #export DOCKER_MACHINE_NAME=default
  export DOCKER_CERT_PATH="C:/Users/${USER}/.docker/machine/machines/default"
  #export DOCKER_HOST="tcp://192.168.99.100:2376"
  export DOCKER_MACHINE_NAME="default"
  export DOCKER_TLS_VERIFY="1"
  export DOCKER_TOOLBOX_INSTALL_PATH="C:/Program Files/DockerTB"
fi

######################
####### prompt #######
######################
if true; then
  #ps_red=$'\e[0;31m'
  #ps_blue=$'\e[0;34m'
  #ps_yellow=$'\e[0;33m'
  #ps_end=$'\e[0m'
  ps_newline=$'\n'
  #export PS1="[${ps_blue}$$ / %*${ps_end}] ${ps_yellow}%~${ps_end}${ps_newline}\$ "
  #unset ps_red ps_blue ps_yellow ps_end ps_newline
  #export PS1='%B%F{red}co%F{green}lo%F{blue}rs%f%b'
  datefmt="%D{%A[%d]/%h/%y | %H:%M:%S}"
  export PS1="[%F{blue}%M%f / %F{blue}$datefmt%f] %F{yellow}%~%f${ps_newline}%# "
  unset datefmt ps_newline
fi

# this obviously doesn't make sense on anything other than windows
if [[ "$g_operatingsystem" == "cygwin" ]]; then
  # visual studio environment variables
  visualstudio_placeholderfile="$HOME/dev/vscyg/placeholder.sh"
  if [[ -f "$visualstudio_placeholderfile" ]]; then
    source "$visualstudio_placeholderfile"
  fi
  unset visualstudio_placeholderfile
fi

# load aliases, if rc exists ...
local aliasrc="$HOME/.aliasrc"
if [[ -f "$aliasrc" ]]; then
 source "$aliasrc"
fi
unset aliasrc

# load ubuntu-specific(?) command_not_found hooks
if [[ "$WSLENV" ]]; then
  local file=/etc/zsh_command_not_found
  if [[ -f "$file" ]]; then
    source "$file"
  fi
fi
unset file
