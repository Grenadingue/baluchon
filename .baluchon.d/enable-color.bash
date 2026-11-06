#!/usr/bin/env bash
#
# Terminal color configuration
#

# Detect terminal color support
color_support=

if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    if tput setaf 1 >/dev/null 2>&1; then
        color_support=yes
    fi
fi

# Allow forcing color support
if [[ -n "$force_color" ]]; then
    color_support=yes
fi

# Initialize color definitions
declare -A colors=()
declare -A style=()

function colored_man() {
    env -u MAN_KEEP_FORMATTING \
        GROFF_NO_SGR=1 \
        MANPAGER='less -R' \
        LESS_TERMCAP_md=$'\e[1;31m' \
        LESS_TERMCAP_me=$'\e[0m' \
        man "$@"
}

if [[ "$color_support" == yes ]]; then

    # Semantic colors, mapped to the terminal ANSI palette
    colors=(
        ["blue"]="$(tput setaf 4)"
        ["yellow"]="$(tput setaf 3)"
        ["red"]="$(tput setaf 1)"
        ["green"]="$(tput setaf 2)"
        ["white"]="$(tput setaf 15)"
        ["magenta"]="$(tput setaf 5)"
        ["light-gray"]="$(tput setaf 7)"
        ["dark-gray"]="$(tput setaf 8)"
    )

    # Text styles
    style=(
        ["bold"]="$(tput bold)"
        ["underline"]="$(tput smul)"
        ["blink"]="$(tput blink)"
        ["reverse"]="$(tput rev)"
        ["reset"]="$(tput sgr0)"
    )

    # Enable command colors
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias man='colored_man'
fi
