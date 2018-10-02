# login script

# TODO - command to put all native, explicitly installed packages into pkglist.txt
#        do not run for now since many packages will be unneeded
# pacman -Qqen > ~/dotfiles/.setup/pkglist.txt

if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi

echo 'running'
[[ -f /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh
[[ -f ~/blend/venv/bin/aws_zsh_completer.sh ]] && source ~/blend/venv/bin/aws_zsh_completer.sh
