#!/bin/zsh

##++
## substitutes .o with .c on an array of strings. fasntnig.
##++
## ofiles=(*.o)
## printf "<%s>\n" "${ofiles[@]/.o/.c}"
##++


# needed mostly for .aliasrc
export SHELL_IS_ZSH=1

# actually, don't
#emulate -L bash
export FPATH="$HOME/.config/zshfunctions:$FPATH"

# more history, please ...
export HISTSIZE=500


# init and load autocomplete as well as builtin prompt stuff
autoload -Uz compinit promptinit
compinit
promptinit

# disable completions for some custom commands
compdef -d new open sh

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

# autoquote pasted URLs
#autoload -Uz url-quote-magic
#zle -N self-insert url-quote-magic

# makes end (ende) / home (POS1) keys work
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line

#zstyle '*' single-ignored show
zstyle '*' single-ignored complete
# give <tab> some color
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ''


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

# set up os-specific stuff
g_operatingsystem="$(uname -o | perl -pe '$_=lc($_); s#gnu/##gi')"
if [[ "$g_operatingsystem" == "cygwin" ]]; then
  g_os_cygwin=1
  g_os_cdirpre="/cygdrive/c"
  export DISPLAY=:0.0
  # if, for whatever reason, $CYGWIN *still* isn't defined, set it up here
  # to include native support for symbolic links
  #export CYGWIN="winsymlinks:nativestrict wincmdln"
  export CYGWIN="winsymlinks wincmdln"
elif [[ "$g_operatingsystem" =~ msys* ]]; then
  g_os_msys=1
  g_os_cdirpre="/c"
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
  export JAVA_HOME="C:/progra~1/Java/jdk/"
  export JRE_HOME="C:/progra~1/Java/jre/"
fi

###############################
#### C/C++ Include Paths ######
###############################
cppincludepaths=(
  "${g_os_cdirpre}/cloud/local/sharedcode/include"
)
export CPATH="$(IFS=":"; echo "${cppincludepaths[*]}")"
export CPLUS_INCLUDE_PATH="$CPATH"


###############################
####### PATH elements #########
###############################
# don't use $JAVA_HOME or $JRE_HOME here!
userpath=(
  "/usr/bin"
  "/bin"
  "/usr/sbin"
  "/usr/local/bin"
  "$HOME/bin"
  "$HOME/.local/bin"

  # contains symlinks for windows commands
  "${g_os_cdirpre}/cloud/local/dev/winbin/bin"

  # symlinks to prod-rel clang-fix are generated there
  "${g_os_cdirpre}/cloud/local/dev/clangfix/bin"

  # programs that technically exist for UNIX-ish oses, but are a
  # royal pain in the ass to build on cygwin
  "${g_os_cdirpre}/progra~1/DockerTB"
  "${g_os_cdirpre}/Users/${USER}/.cargo/bin"
  "${g_os_cdirpre}/scripting/nodejs/"
  "${g_os_cdirpre}/Users/${USER}/AppData/Roaming/npm"
  "${g_os_cdirpre}/cloud/gdrive/portable/devtools/other"
  "${g_os_cdirpre}/cloud/gdrive/portable/devtools/re2c/bin"
  "${g_os_cdirpre}/cloud/gdrive/portable/devtools/go/bin"
  "${g_os_cdirpre}/cloud/gdrive/portable/devtools/freebasic"
  "${g_os_cdirpre}/cloud/gdrive/portable/devtools/fpc/bin/i386-win32"
  "${g_os_cdirpre}/cloud/gdrive/portable/devtools/nasm"
  "${g_os_cdirpre}/cloud/gdrive/portable/devtools/borlandcpp/bin"
  "${g_os_cdirpre}/cloud/gdrive/portable/devtools/ikvm/bin"
  "${g_os_cdirpre}/cloud/gdrive/portable/video/mkvtoolnix/"


  # distinctly windows-specific paths
  # (either don't exist for *nix, or integrate very poorly with cygwin)
  "${g_os_cdirpre}/progra~2/WABT/bin/"
  "${g_os_cdirpre}/progra~2/binaryen/bin/"
  "${g_os_cdirpre}/progra~1/Java/jre/bin/"
  "${g_os_cdirpre}/progra~1/Java/jdk/bin/"
  "${g_os_cdirpre}/cloud/gdrive/portable/devtools/apache-ant/bin"
  #"${g_os_cdirpre}/cloud/gdrive/portable/devtools/dlang/dmd/dmd2/windows/bin"
  "${g_os_cdirpre}/cloud/gdrive/portable/devtools/dlang/ldc/bin"
  "${g_os_cdirpre}/cloud/gdrive/portable/unsorted"
  #"${g_os_cdirpre}/ProgramData/Chocolatey/bin"
  "${g_os_cdirpre}/Progra~1/qemu"
  "${g_os_cdirpre}/tools/dart-sdk/bin"
  #"${g_os_cdirpre}/Progra~1/dotnet"
  #"${g_os_cdirpre}/users/$USER/.dotnet/x64"
  #"${g_os_cdirpre}/Windows"
  #"${g_os_cdirpre}/Windows/system32"
  #"${g_os_cdirpre}/Windows/System32/WindowsPowerShell/v1.0"
)

if ! type ruby >/dev/null; then
  #export PATH="$(__strjoin ':' "${userpath[@]}")"
  tmp=""
  for item in "${userpath[@]}"; do
    if [[ -d "$item" ]]; then
      if [[ "$tmp" == "" ]]; then
        tmp="$item"
      else
        tmp="$item:$tmp"
      fi
    fi
  done
  export PATH="$tmp"
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
  export DOCKER_CERT_PATH="C:/Users/sebastian/.docker/machine/machines/default"
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
[[ -f "$HOME/.aliasrc" ]] && source "$HOME/.aliasrc"

