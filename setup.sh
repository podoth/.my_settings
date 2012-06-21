#!/bin/bash -x

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
    ln -s ${PWD}/$item ${HOME}/$item
done

