#!/bin/bash -x

# require
# ruby,migemo,c/migemo,ruby-gnome2,uncrusitfy,git,xmonad,zsh

if [ ! -d .emacs.d/var ]
then
    mkdir .emacs.d/var
fi

for item in .bashrc .emacs .emacs.d .Xmodmap .gitconfig .gnomerc .vimperator .vimperatorrc .xinitrc .xmonad .zshrc .uncrusitfy .Xresources
do
    if [ ! -L ${HOME}/${item} ]
    then
	mv ${HOME}/$item ${HOME}/${item}.mybak
    fi
    rm ${HOME}/$item
    ln -s ${PWD}/$item ${HOME}/$item
done

sudo ln -s ${PWD}/emacs-mark.rb /usr/bin/emacs-mark.rb
sudo ln -s ${PWD}/emacs-mark.server /usr/lib/bonobo/servers/emacs-mark.server
