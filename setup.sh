#!/bin/bash -x

if [ ! -d .emacs.d/var ]
then
    mkdir .emacs.d/var
fi

for item in .bashrc .emacs .emacs.d
do
    rm -r ${HOME}/$item
    ln -s ${PWD}/$item ${HOME}/$item
done

