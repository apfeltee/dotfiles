#!/bin/bash
#set -x

# debug settings
g_cfg_debug=0
g_cfg_loadcompletion=0

# If not running interactively, don't do anything
[[ -z "$PS1" ]] && return
[ -z "$BASH_VERSION" -o -z "$PS1" -o -n "$BASH_COMPLETION" ] && return

###################
## sensible bash ##
###################

## GENERAL OPTIONS ##

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
  shopt -s "$option" 2> /dev/null;
done;

# enable case-insensitive glob, particularly important-ish on cygwin
shopt -s nocaseglob
# enable extended globbing features, like
# !(<pat>) to negate glob (matches anything but <pat>)
# etc
shopt -s extglob
# Prevent file overwrite on stdout redirection
#set -o noclobber
# Update window size after every command
shopt -s checkwinsize
### ignore ^D (aka, EOF), so bash won't exit() when ^D is hit a few times
set -o ignoreeof
### get rid of "'!': event not found"
### i don't even need it!
set +H


# Automatically trim long paths in the prompt (requires Bash 4.x)
#PROMPT_DIRTRIM=2

## SMARTER TAB-COMPLETION (Readline bindings) ##
# Perform file completion in a case insensitive fashion
bind "set completion-ignore-case on"
# Treat hyphens and underscores as equivalent
bind "set completion-map-case on"
# Display matches for ambiguous patterns at first tab press
bind "set show-all-if-ambiguous on"

## SANE HISTORY DEFAULTS ##
# Append to the history file, don't overwrite it
shopt -s histappend

# Save multi-line commands as one command
#shopt -s cmdhist

# Record each line as it gets issued
#PROMPT_COMMAND='history -a'
# Huge history. Doesn't appear to slow things down, so why not?
HISTSIZE=5000
HISTFILESIZE=10000
# Avoid duplicate entries
HISTCONTROL="erasedups:ignoreboth"
# Don't record some commands
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history"
# Useful timestamp format
HISTTIMEFORMAT='%F %T '
## BETTER DIRECTORY NAVIGATION ##
# Prepend cd to directory names automatically
shopt -s autocd
# Correct spelling errors during tab-completion
shopt -s dirspell
# Correct spelling errors in arguments supplied to cd
shopt -s cdspell
# autocomplete hack, so that empty nothingness followed by a tab won't choke bash
shopt -s no_empty_cmd_completion

# This defines where cd looks for targets
# Add the directories you want to have fast access to, separated by colon
# Ex: CDPATH=".:~:~/projects" will look for targets in the current working directory, in home and in the ~/projects folder
CDPATH="."

# This allows you to bookmark your favorite places across the file system
# Define a variable containing a path and you will be able to cd into it regardless of the directory you're in
shopt -s cdable_vars

# Examples:
# export dotfiles="$HOME/dotfiles"
# export projects="$HOME/projects"
# export documents="$HOME/Documents"
# export dropbox="$HOME/Dropbox"


#####################################
####### internal utility funcs ######
#####################################

function __bashrc_debugmsg
{
  if [[ $g_cfg_debug == 1 ]]; then
    echo "bashrc(PID=$$):dbg: $@" >&2
  fi
}

function __strjoin
{
  local IFS="$1"
  shift
  echo "$*"
}

#####################################
############ language settings ######
#####################################
#_user_lang="en_US.UTF-8"
_user_lang="C.utf8"
export LC_ALL="$_user_lang"
export LANG="$_user_lang"
export LANGUAGE="$_user_lang"

# get rid of retarded builtins
enable -n kill

###############################
### utility env values for ####
### some programs #############
###############################
#export EDITOR="$HOME/bin/edit"

# needed for a variety of java programs
export JAVA_HOME="C:/progra~1/Java/jdk/"
export JRE_HOME="C:/progra~1/Java/jre/"
###############################
####### PATH elements #########
###############################
userpath=(
  "/bin"
  "/usr/bin/"
  "/usr/sbin/"
  "$HOME/bin/"
  # programs that technically exist for UNIX-ish oses, but are a
  # royal pain in the ass to build on cygwin
  "/cygdrive/c/Users/${USER}/.cargo/bin"
  "/cygdrive/c/scripting/nodejs/"
  "/cygdrive/c/Users/${USER}/AppData/Roaming/npm"
  "/cygdrive/c/ProgramData/Oracle/Java/javapath"
  "/cygdrive/c/progra~1/Java/jdk/bin"
  "/cygdrive/c/cloud/gdrive/portable/video/mkvtoolnix/"

  # distinctly windows-specific paths
  "/cloud/gdrive/portable/devtools/dmd/dmd2/windows/bin/"
  #"/cygdrive/c/ProgramData/Chocolatey/bin"
  "/cygdrive/c/Progra~1/qemu"
  "/cygdrive/c/tools/dart-sdk/bin/"
  "/cygdrive/c/Progra~1/dotnet"
  #"/cygdrive/c/PROGRA~2/MICROS~1/Windows/v8.1A/bin/NETFX4~1.1TO"
  #"/cygdrive/c/Windows"
  #"/cygdrive/c/Windows/system32"
  #"/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0"
)

#export PATH="$(__strjoin ':' "${userpath[@]}")"
export PATH="$(
  ruby --disable-gems -e '
    class FStat < File::Stat
      attr_accessor :path
      def initialize(path)
        @path = path
        super(path)
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
          #$stderr.puts("pa => #{pa.path.dump}")
          newpath.push(pa.path)
        end
      end
    end
    $stdout.print(newpath.join(":"))
  ' "${userpath[@]}"
)"
#export PATH="/usr/local/bin:/usr/bin:/bin:$HOME/bin:/cloud/gdrive/portable/devtools/dmd/dmd2/windows/bin/:$PATH"

export MANPATH="$MANPATH:/usr/share/man/:/opt/mono/share/man/"
# needed for nodejs
export NODE_PATH="$APPDATA/Roaming/npm/node_modules"
# fix for sdl apps under cygwin
export SDL_STDIO_REDIRECT="no"

###############################
###### youtube api key ########
###############################
files=("ytapikey.sh" "imgurapikey.sh" "redditapikey.sh")
for file in "${files[@]}"; do
  path="$HOME/.config/webapi/$file"
  if [[ -f "$path" ]]; then
    __bashrc_debugmsg "sourcing webapi file <$path>"
    source "$path"
  fi
done
unset files

###############################
####### platform ##############
###############################
g_operatingsystem="$(uname -o | tr A-Z a-z)"
if [[ "$g_operatingsystem" == "cygwin" ]]; then
  g_os_cygwin=1
  export DISPLAY=:0.0
  # if, for whatever reason, $CYGWIN *still* isn't defined, set it up here
  # to include native support for symbolic links
  export CYGWIN="winsymlinks:nativestrict"
fi

###############################
###### lessfilter #############
###############################
#export LESS='-R'
#export LESSOPEN='|~/.lessfilter %s'

# needed so sudo'd apps can connect to x11
if [[ "$DISPLAY" ]] && [[ $g_os_cygwin == 0 ]]; then
  if type xhost >/dev/null; then
    xhost local:root > /dev/null
  fi
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm*)
    color_prompt=yes
    ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes
if [[ -n "$force_color_prompt" ]]; then
  # cygwin doesn't have tput ...
  if [[ -x /usr/bin/tput ]] && tput setaf 1 >&/dev/null; then
  #if true; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [[ "$color_prompt" == "yes" ]]; then
  # setup PS1 to be pretty
  # the current template emulates cygwin
  ps_red="\\e[0;31m"
  ps_blue="\\e[0;34m"
  ps_yellow="\\e[0;33m"
  ps_end="\\e[0m"
  # use '\t' instead of $(date ...) (does the same, but it's also a builtin!)
  PS1="\[[${ps_blue}$$ / \t${ps_end}]\] ${ps_yellow}\w${ps_end}\n\$ "
fi

# alias definitions
bash_aliases_file="$HOME/.aliasrc"
if [[ -f "$bash_aliases_file" ]]; then
  __bashrc_debugmsg "including aliases file <$bash_aliases_file>"
  source "$bash_aliases_file"
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
bash_completion_file="/etc/bash_completion"
bash_completion_path="/etc/bash_completion.d"
if [[ "$g_cfg_loadcompletion" == "1" ]]; then
  if ! shopt -oq posix; then
    if [[ -f "$bash_completion_file" ]]; then
      if [[ -z "$BASH_COMPLETION" ]]; then
        __bashrc_debugmsg "sourcing completion file '$bash_completion_file'"
        source "$bash_completion_file"
        __bashrc_debugmsg "loading bash completion instructions from '$bash_completion_path':"
        for file in "$bash_completion_path"/* ; do
          case "$base" in
            findutils)
              _debug "sourcing '$file' ..."
              source "$file"
              ;;
          esac
        done
      fi
    fi
  fi
fi

# visual studio environment variables
visualstudio_envfile="$HOME/.visualstudio.env"
if [[ -f "$visualstudio_envfile" ]]; then
  __bashrc_debugmsg "including visual studio environment variables file <$visualstudio_envfile>"
  source "$visualstudio_envfile"
fi

unset __bashrc_debugmsg g_cfg_debug g_cfg_loadcompletion

