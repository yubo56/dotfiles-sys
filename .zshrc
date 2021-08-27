# useful commands
#
# git remote set-url origin https://yubo56@github.com/<blah>
#
# sed -E 's/.*(<stuff>)/\1/g' replaces with captured group (can never remember
# syntax)
#

if [[ "$(hostname)" =~ BL-yubo- ]]; then
    sudo scutil --set HostName BlendNew
fi

# global exports
export LC_ALL=C
export HOMEBREW_NO_AUTO_UPDATE=1
if [[ "$(hostname)" =~ ArchTest ]]; then
    export WIFI=wlp7s0
    alias rewin='sudo efibootmgr -n 1 && sudo reboot'
else if [[ "$(hostname)" =~ YuboDesktop ]]; then
    export WIFI=wlp8s0
    alias rewin='sudo efibootmgr -n 0 && sudo reboot'
fi; fi

export _JAVA_AWT_WM_NONREPARENTING=1 # java swing hates dwm
export PYTHONUNBUFFERED=1

# config options
unsetopt beep nomatch notify
unsetopt completealiases # completes aliases too, spellcheck
# setopt print_exit_value # prints nonzero exit value

# keybindings
stty sane # fix backspace
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
    then hash tmux 2> /dev/null && {
        FIRST_SESSION=$(tmux ls -F '#{session_attached}#{session_id}' | 'grep' '0\$' | head -n 1 | cut -c 2-)
        if [[ -z $FIRST_SESSION ]]; then
            exec tmux -2;
        else
            exec tmux attach-session -t $FIRST_SESSION
        fi
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
if [[ "$(hostname)" =~ "Blend" ]]; then
    . ~/.blend_aliases
fi


# pimp out tab completion a bit
eval "$($DIRCOLORS -b)"
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'
zstyle ':completion:*' menu select eval "$($DIRCOLORS -b)"

# variables
export EDITOR="vim"
if [ $OSTYPE =~ "linux-gnu" ]; then
    export PATH="/home/yssu/.local/bin:/home/yssu/bin:$PATH"
    [[ $(sysctl kernel/unprivileged_userns_clone | grep 1) ]] ||\
        sudo sysctl kernel/unprivileged_userns_clone=1 # for brave
else
    export PATH="/opt/local/bin:/opt/local/sbin:/Users/yubo/bin:$PATH"
fi

# ibus
export XMODIFIERS="@im=ibus"
export GTK_IM_MODULE="ibus"
export QT_IM_MODULE="ibus"

# prompt
NEWLINE=$'\n'
KER1=$(uname -r | sed -E 's/-arch(.).*/-\1/g')
KER2=$(pacman -Q linux | sed -E 's/linux (.*)\.arch(.).*/\1-\2/g')
KER=$( [[ $KER1 == $KER2 ]] && echo $KER1 || echo '!!')
PROMPT1='$(git_status)[%{$fg_bold[white]%}%~%{$reset_color%}] [%B%F{cyan}%* %F{green}%n@%m%b%f (%F{white}${KER}%f)]$(brack_fmt $STY)$(brack_fmt $AWS_VAULT) %(?..(%F{red}%?%{$reset_color%}%) )'
PROMPT2='> '
PROMPT="${PROMPT1}${NEWLINE}${PROMPT2}"
setopt PROMPT_SUBST
#

# start shared ssh-agent
if [ ! -S /tmp/ssh_auth_sock ]; then
    eval "$(ssh-agent -s)" > /dev/null
    ln -sf "$SSH_AUTH_SOCK" /tmp/ssh_auth_sock
fi
export SSH_AUTH_SOCK=/tmp/ssh_auth_sock
ssh-add -l > /dev/null || ssh-add ~/.ssh/id_rsa

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
