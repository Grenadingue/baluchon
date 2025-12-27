#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignorespace:ignoredups:erasedups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=-1
HISTFILESIZE=100000000

# save history immediatly
# write history in file, clears session's history, then reload history file's content
PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND}"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Set user's bin directory path
if [ -d "$HOME/bin" ]; then
  export PATH="$PATH:$HOME/bin"
fi

# Current session detection (ssh...)
if [ -f ~/.baluchon.d/session-detection.bash ]; then
  . ~/.baluchon.d/session-detection.bash
fi

# Retrieve and print informations about current execution environment
# (Like operating system, distribution, kernel, ...)
if [ ! $SUDO_USER ] && [ -f ~/.baluchon.d/whereami/whereami ]; then
  . ~/.baluchon.d/whereami/whereami
  CURRENT_SHELL=`if [[ "$0" == /* ]]; then which $0; else echo $SHELL; fi`
  SHELL_INFOS=`"$CURRENT_SHELL" --version | head -n 1`
  echo "Shell: $CURRENT_SHELL: $SHELL_INFOS"
fi

# Create a file named `force_color` in ~/.baluchon.d to force color in shell
if [ -f ~/.baluchon.d/force_color ]; then
  force_color=yes
fi
# Enable color support
if [ -f ~/.baluchon.d/enable-color.bash ]; then
  . ~/.baluchon.d/enable-color.bash
fi

# Set custom prompt
if [ -f ~/.baluchon.d/prompt.bash ]; then
  . ~/.baluchon.d/prompt.bash
fi

# Init some shell commands
if [ -f ~/.baluchon.d/init-commands.bash ]; then
  . ~/.baluchon.d/init-commands.bash
fi

# Enable handy aliases
if [ -f ~/.baluchon.d/aliases.bash ]; then
  . ~/.baluchon.d/aliases.bash
fi
