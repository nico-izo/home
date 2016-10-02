# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# shopt configuration {{{
# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace
# append to the history file, don't overwrite it
shopt -s histappend
# recognize ** for recursive patterns
shopt -s globstar
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=4000
HISTFILESIZE=10000
# }}}

export QUICKLY_EDITOR=vim

# make less more friendly for non-text input files, see lesspipe(1)
export LESS="-R -M --shift 5"
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# setup colors {{{
# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

color_is_on=
color_red=
color_green=
color_yellow=
color_blue=
color_white=
color_gray=
color_bg_red=
color_off=
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_is_on=true
    color_red="\[$(/usr/bin/tput setaf 1)\]"
    color_green="\[$(/usr/bin/tput setaf 2)\]"
    color_yellow="\[$(/usr/bin/tput setaf 3)\]"
    color_blue="\[$(/usr/bin/tput setaf 6)\]"
    color_white="\[$(/usr/bin/tput setaf 7)\]"
    color_gray="\[$(/usr/bin/tput setaf 8)\]"
    color_off="\[$(/usr/bin/tput sgr0)\]"
    color_error="$(/usr/bin/tput setab 1)$(/usr/bin/tput setaf 7)"
    color_error_off="$(/usr/bin/tput sgr0)"
fi

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -n "$color_is_on" ]; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

#if [ "$color_prompt" = yes ]; then
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#else
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#fi
unset color_prompt force_color_prompt
# }}}

# If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#    ;;
#*)
#    ;;
#esac

# Common aliases {{{
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
# }}}

# Global completion {{{
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
# }}}

# One time C++ code compilation and run {{{
compileOnce ()
{
    local COMPILER="$CXX"
    if [ -z "$COMPILER" ];
    then
        COMPILER=/usr/bin/g++
    fi

    local LOCAL_CFLAGS="$CFLAGS"
    while [ "$#" -gt "1" ];
    do
        LOCAL_CFLAGS="$LOCAL_CFLAGS $1"
        shift
    done
    local INFILE="`mktemp --tmpdir --suffix=.cpp`"
    local OUTFILE="`mktemp --tmpdir`"
    echo "#include <iostream>" >$INFILE
    echo "#include <map>" >>$INFILE
    echo "#include <list>" >>$INFILE
    echo "#include <vector>" >>$INFILE
    echo "#include <limits>" >>$INFILE
    echo "#include <bitset>" >>$INFILE
    echo "#include <string.h>" >>$INFILE
    echo "#include <set>" >>$INFILE
    echo "#include <math.h>" >>$INFILE
    echo "#include <ctime>" >>$INFILE
    echo "#include <limits.h>" >>$INFILE
    echo "#include <unistd.h>" >>$INFILE
    echo "#include <exception>" >>$INFILE
    echo "#include <stdexcept>" >>$INFILE
    echo "#include <typeinfo>" >>$INFILE
    echo "int main(int argc, char **argv) {" >>$INFILE
    echo "$1" >>$INFILE
    echo "return 0; }" >>$INFILE
    $COMPILER -std=c++11 -O3 $LOCAL_CFLAGS -o "$OUTFILE" "$INFILE" -lrt -ldl
    $OUTFILE
    rm "$OUTFILE" "$INFILE"
}
# }}}

# VCS info methods {{{
make_vcs_status () {
    local vcs=$1
    local branch=$2
    local dirty=$3

    if [ ! -z "$branch" ];
    then
        if [ ! -z "$color_is_on" ]; then
            if [ -z "$dirty" ]; then
                echo " ($vcs: ${color_green}${branch}${color_off})"
            else
                echo " ($vcs: ${color_red}${branch}${color_off})"
            fi
        else
            echo " ($vcs: ${branch})"
        fi
    fi
}

parse_git_status () {
    # clear git variables
    local GIT_BRANCH=
    local GIT_DIRTY=

    # exit if no git found in system
    local GIT_BIN=$(which git 2>/dev/null)
    [ -z "$GIT_BIN" ] && return

    # check we are in git repo
    local CUR_DIR=$PWD
    while [ ! -d "${CUR_DIR}/.git" ] && [ ! -z "$CUR_DIR" ] && [ ! "$CUR_DIR" = "/" ]; do CUR_DIR=${CUR_DIR%/*}; done
    [ ! -d "${CUR_DIR}/.git" ] && return
    # get git branch
    GIT_BRANCH=$($GIT_BIN symbolic-ref HEAD 2>/dev/null)
    [ -z "$GIT_BRANCH" ] && return
    GIT_BRANCH=${GIT_BRANCH#refs/heads/}

    # get git status
    local GIT_STATUS=$($GIT_BIN status --porcelain 2>/dev/null)
    [ -n "$GIT_STATUS" ] && GIT_DIRTY=true

    make_vcs_status git "$GIT_BRANCH" "$GIT_DIRTY"
}

parse_hg_status () {
    local HG_BRANCH=
    local HG_DIRTY=

    local HG_BIN=$(which hg 2>/dev/null)
    [ -z "$HG_BIN" ] && return

    local HG_SUM=$(LANGUAGE=en LANG=C $HG_BIN summary 2>/dev/null)
    while read LINE;
    do
        case "$LINE" in
            branch*)
                HG_BRANCH=$(expr match "$LINE" "branch: \(.*\)\s*" 2>/dev/null)
                ;;
            bookmarks*)
                HG_BRANCH=$(expr match "$LINE" "bookmarks: \(.*\)\s*" 2>/dev/null)
                ;;
            commit*)
                expr match "$LINE" ".*(clean)" &>/dev/null \
                    && ! expr match "$LINE" ".*unknown.*" &>/dev/null \
                    || HG_DIRTY=true
                ;;
        esac
    done < <( echo "$HG_SUM" )

    make_vcs_status hg "$HG_BRANCH" "$HG_DIRTY"
}

parse_bzr_status () {
    local BZR_BIN=$(which bzr 2>/dev/null)
    [ -z "$BZR_BIN" ] && return

    local BZR_BRANCH=$($BZR_BIN nick 2>/dev/null)
    [ -n "$BZR_BRANCH" ] || return
    local BZR_DIRTY="$($BZR_BIN st 2>/dev/null)"
    
    make_vcs_status bzr "$BZR_BRANCH" "$BZR_DIRTY"
}

# }}}

# Prompt {{{
prompt_command () {
    # errno
    local RETCODE=$?
    if [ $RETCODE -eq 0 ];
    then
        RETCODE="${color_green}${RETCODE}${color_off}"
    else
        RETCODE="${color_red}${RETCODE}${color_off}"
    fi
    
    # parse VCS status
    local PS1_VCS=
    [ -z "$PS1_VCS" ] && PS1_VCS=$(parse_hg_status)
    [ -z "$PS1_VCS" ] && PS1_VCS=$(parse_git_status)
    [ -z "$PS1_VCS" ] && PS1_VCS=$(parse_bzr_status)
    
    local TIMESTAMP="[$(date +'%Y-%m-%d %H:%M:%S')]"

    local color_user=
    if $color_is_on; then
        # set user color
        case `id -u` in
            0)
                color_user=$color_red
                ;;
            *)
                color_user=$color_green
                ;;
        esac
    fi

    local UPPER_LINE="${USER}@${HOSTNAME}:${PWD}${PS1_VCS} ${TIMESTAMP}"
    local UPPER_LEN=$(printf "$UPPER_LINE" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | wc -c | tr -d " ")
    # calculate fillsize
    local fillsize=$(($COLUMNS-$UPPER_LEN-1))

    local FILL=$color_gray
    while [ $fillsize -gt 0 ]; do FILL="${FILL}─"; fillsize=$(($fillsize-1)); done
    FILL="${FILL}${color_off}"
    
    # set new color prompt
    PS1="${color_user}\u${color_off}@${color_yellow}\h${color_off}:${color_white}\w${color_off}${PS1_VCS} ${color_blue}${TIMESTAMP}${color_off} ${FILL}\n${RETCODE} ➜ "
}
PROMPT_COMMAND=prompt_command
# }}}

# vim: ts=4 sts=4 sw=4 et fdm=marker:

export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export PATH=/usr/local/bin:$PATH
source /usr/local/bin/virtualenvwrapper.sh

export EDITOR=vim.gtk


