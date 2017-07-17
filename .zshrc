# useful commands
#
# git remote set-url origin https://yubo56@github.com/<blah>
#
# sed -E 's/.*(<stuff>)/\1/g' replaces with captured group (can never remember
# syntax)
#

# global exports
if [[ "$(hostname)" =~ ArchTest ]]; then
    export WIFI=wlp7s0
    export brightfile='/sys/class/backlight/intel_backlight/brightness'
    export brightmax='/sys/class/backlight/intel_backlight/max_brightness'
else
    export WIFI=wlp4s0
    export brightfile='/sys/class/backlight/gmux_backlight/brightness'
    export brightmax='/sys/class/backlight/gmux_backlight/max_brightness'
fi

export _JAVA_AWT_WM_NONREPARENTING=1 # java swing hates dwm

# config options
unsetopt beep nomatch notify
setopt completealiases correct # completes aliases too, spellcheck
setopt print_exit_value # prints nonzero exit value

# keybindings
stty erase '^?' # fix backspace
bindkey -e # emacsmode :( (-v is vim mode)
bindkey -r '^J' # unbind ^J to be able to use tmux

# infocmp -L1 [-I] is your friend
# function keys are no longer our friends! currently disabled:
#       - F8 (vim C-w), F9 (zsh C-u), F10 (zsh C-k), F11 (tmux C-j)
# bindkey '^B' backward-word
# bindkey '^F' forward-word
bindkey '^U' backward-kill-line # bash-like
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line
bindkey "${terminfo[kdch1]}" delete-char
bindkey "${terminfo[kpp]}" up-line-or-history
bindkey "${terminfo[knp]}" down-line-or-history
bindkey "${terminfo[kcbt]}" reverse-menu-complete
# bindkey "${terminfo[kf9]}" backward-kill-line
# bindkey "${terminfo[kf10]}" kill-line

# if term is xterm (and not login shell) then
# if tmux exists then either
#   - try to start main (and fail if already existing) in OS X
#   - start tmux without name in otherwise
if [ "$TERM" =~ "xterm" ] || [ "$TERM" =~ "rxvt" ]
    then [[ -n $(command -v tmux) ]] && {
        [[ $OSTYPE =~ "linux-gnu" ]] && exec tmux -2 ||
        tmux -2 new-session -s 'main/'
    }
fi

# history
setopt appendhistory autocd extendedglob
HISTFILE=~/.zshist
HISTSIZE=1000
SAVEHIST=1000

# coloring, autocompletion
### CODY MADE EDITS DOCUMENTED WITH ###
### autoloaded select-word-style
autoload -U colors compinit select-word-style
colors
# source selections only after compinit completes, supresses "compdef not found"
compinit && . ~/.zsh_compdefs
### and chose BASH style
select-word-style bash

# pimp out tab completion a bit
eval `dircolors -b`
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'
zstyle ':completion:*' menu select eval "$(dircolors -b)"

# report time for >5s processes
REPORTTIME=5

# cdr configuration
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

# time formatting
TIMEFMT=$'real\t%E\nMaxMem\t%M'

# aliases
if [ -e ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi
if [ -e ~/.zsh_functions ]; then
    . ~/.zsh_functions
fi
if [[ "$(hostname)" != "ArchTest" ]]; then
    . ~/.blend_aliases
fi

# variables
export EDITOR="vim"
export PATH=/home/yssu/bin:$PATH

# ibus
export XMODIFIERS="@im=ibus"
export GTK_IM_MODULE="ibus"
export QT_IM_MODULE="ibus"

# prompt
setopt PROMPT_SUBST
PS1='$(git_status)%~\$ '

# start ssh-agent
eval "$(ssh-agent -s)" > /dev/null

# trigger any venv stuff
cd .

# colors
# black | 0
# red | 1
# green | 2
# yellow | 3
# blue | 4
# magenta | 5
# cyan | 6
# white | 7
