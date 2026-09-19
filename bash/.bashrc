# ~/.bashrc: executed by bash(1) for interactive non-login shells.

# Stop here for non-interactive shells.
case $- in
    *i*) ;;
      *) return ;;
esac

# Keep useful history without storing duplicate commands or commands prefixed
# with a space.
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend
shopt -s checkwinsize

# Make less handle compressed and other non-text inputs when lesspipe exists.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Include the current chroot name in the prompt when applicable.
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes ;;
esac

if [ -n "${force_color_prompt:-}" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "${color_prompt:-}" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# Set the terminal title to user@host:directory.
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
esac

# Enable colors and the preferred listing behavior.
if [ -x /usr/bin/dircolors ]; then
    test -r "$HOME/.dircolors" && eval "$(dircolors -b "$HOME/.dircolors")" || eval "$(dircolors -b)"
    alias ls='ls --color=auto -hF'
    alias grep='grep --color=auto -E'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -al'
alias la='ls -a'
alias cman='LANG=zh_CN.UTF-8 man'

# Show a desktop notification after a long command: sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

if [ -f "$HOME/.bash_aliases" ]; then
    . "$HOME/.bash_aliases"
fi

# Enable programmable completion unless Bash is running in POSIX mode.
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Move a directory to the front of PATH without accumulating duplicates in
# nested shells. Missing optional tool directories are ignored.
path_remove() {
    PATH=":$PATH:"
    PATH=${PATH//:"$1":/:}
    PATH=${PATH#:}
    PATH=${PATH%:}
}

path_prepend() {
    [ -d "$1" ] || return 0
    path_remove "$1"
    PATH="$1${PATH:+:$PATH}"
}

path_append() {
    [ -d "$1" ] || return 0
    path_remove "$1"
    PATH="${PATH:+$PATH:}$1"
}

# Remove duplicate and stale directories left by vendor setup scripts.
path_cleanup() {
    local entry clean_path=
    local -a path_entries
    local -A seen
    IFS=: read -r -a path_entries <<< "$PATH"
    for entry in "${path_entries[@]}"; do
        [ -n "$entry" ] || continue
        [ -d "$entry" ] || continue
        [ -z "${seen[$entry]+present}" ] || continue
        seen[$entry]=1
        clean_path="${clean_path:+$clean_path:}$entry"
    done
    PATH=$clean_path
}

source_if_readable() {
    [ -r "$1" ] && . "$1"
}

# Initialize the local Anaconda installation. This retains the current Conda
# auto-activation preference while avoiding errors on machines without it.
if [ -x "$HOME/anaconda3/bin/conda" ]; then
    if __conda_setup=$("$HOME/anaconda3/bin/conda" shell.bash hook 2>/dev/null); then
        eval "$__conda_setup"
    else
        source_if_readable "$HOME/anaconda3/etc/profile.d/conda.sh"
    fi
    unset __conda_setup
fi

# YSYX/NJU digital-design workspace.
YSYX_WORKBENCH="$HOME/1-ysyx/ysyx-workbench"
if [ -d "$YSYX_WORKBENCH" ]; then
    export NEMU_HOME="$YSYX_WORKBENCH/nemu"
    export AM_HOME="$YSYX_WORKBENCH/abstract-machine"
    export NPC_HOME="$YSYX_WORKBENCH/npc"
    export NVBOARD_HOME="$YSYX_WORKBENCH/nvboard"
fi

# Opt in to the bundled OSS CAD toolchain only when working on YSYX projects;
# the system Verilator remains the default in normal shells.
ysyx_env() {
    path_prepend "$HOME/1-ysyx/oss-cad-suite/bin"
    export PATH
    command -v verilator
}

# AMD/Xilinx 2023.2 tools. The guard prevents duplicate PATH entries in nested
# shells while keeping Vivado, Vitis, HLS, Model Composer, and DocNav available.
if [ -z "${XILINX_VIVADO:-}" ]; then
    source_if_readable "$HOME/tools/Xilinx/Vivado/2023.2/settings64.sh"
    source_if_readable "$HOME/tools/Xilinx/Vitis/2023.2/settings64.sh"
    source_if_readable "$HOME/tools/Xilinx/Vitis_HLS/2023.2/settings64.sh"
    source_if_readable "$HOME/tools/Xilinx/Model_Composer/2023.2/settings64.sh"
fi
path_append "$HOME/tools/Xilinx/DocNav"

# User-level command line tools. Codex is installed through npm in
# ~/.npm-global; Claude Code and mise use ~/.local/bin.
path_prepend /opt/riscv/bin
path_prepend /usr/lib/ccache
path_prepend "$HOME/.kimi-code/bin"
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.npm-global/bin"
export PATH

if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash)"
fi

if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi

path_cleanup
export PATH
unset -f path_cleanup

# Define the offline tldr helper only when both the client and data exist.
if command -v tldr >/dev/null 2>&1 && [ -d "$HOME/tldr-offline" ]; then
    how() {
        tldr "$@" --repository "$HOME/tldr-offline" --language zh
    }
fi

# Connect to the Oracle ARM host through its single allowed mosh UDP port.
mosh-oracle-arm() {
    mosh --server="mosh-server new -p 60000" -p 60000 oracle-arm
}

# Require repeated Ctrl-D to exit and prevent accidental overwrite via >.
set -o ignoreeof
set -o noclobber

# Directory stack shortcuts.
alias d='dirs -v'
alias p='pushd'
alias pop='popd'
