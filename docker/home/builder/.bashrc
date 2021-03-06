# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples


# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000
HISTFILE=/opt/uml/@@BUILD_DIR@@/.builder_bash_history

# for getting aliases to expand in non-interactive shells
shopt -s expand_aliases

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# Set up utf-8 locale
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# | (gnome-terminal:131): WARNING **: Couldn't connect to accessibility bus
export NO_AT_BRIDGE=1

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[00m\]@\[\033[01;33m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
  . ~/.bitbake_bash_completion
fi

export BUILD_DIR="@@BUILD_DIR@@"
export SOURCE_DIR="@@SOURCE_DIR@@"
export LM_KERNEL_SOURCE_URL="@@LM_KERNEL_SOURCE_URL@@"
export LM_UBOOT_SOURCE_URL="@@LM_UBOOT_SOURCE_URL@@"
export LM_KERNEL_SOURCE_DIR="@@LM_KERNEL_SOURCE_DIR@@"
export LM_UBOOT_SOURCE_DIR="@@LM_UBOOT_SOURCE_DIR@@"
export LM_TOOLSCHAIN_URL="@@LM_TOOLSCHAIN_URL@@"

if shopt -q login_shell; then
  rm $BUILD_DIR/kernel-src -rf
  rm $BUILD_DIR/uboot-src -rf

  if [ $LM_KERNEL_SOURCE_DIR ];then
    echo -e "\033[34mLink $BUILD_DIR/kernel-src --> $LM_KERNEL_SOURCE_DIR\033[0m"
    ln -s $LM_KERNEL_SOURCE_DIR $BUILD_DIR/kernel-src
  fi
  if [ $LM_UBOOT_SOURCE_DIR ];then
    echo -e "\033[34mLink $BUILD_DIR/uboot-src --> $LM_UBOOT_SOURCE_DIR\033[0m"
    ln -s $LM_UBOOT_SOURCE_DIR $BUILD_DIR/uboot-src
  fi
  cd $BUILD_DIR
  chown -R builder: $BUILD_DIR
  export PATH=$LM_TOOLSCHAIN_URL/bin:$PATH:/sbin:/usr/sbin
  export ARCH=arm
  export CROSS_COMPILE=arm-none-linux-gnueabi
fi
