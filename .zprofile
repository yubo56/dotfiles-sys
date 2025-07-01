# login script

# TODO - command to put all native, explicitly installed packages into pkglist.txt
#        do not run for now since many packages will be unneeded
# pacman -Qqen > ~/dotfiles/.setup/pkglist.txt

if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi
