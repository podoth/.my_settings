# interactiveなとき以外(scp等)は何もしない
if [ -z "$PS1" ]; then
    return
fi
# zshが存在するときだけzsh
if [ -e /bin/zsh ]; then
    exec zsh
fi
###
### MATSUO & TSUMURA lab.
###   ~/.bash_profile template
###  feel free to edit this file at your own risk
###
### Last Modified: 2008/01/07 16:30
### Created:       2007/04/03 17:50
#
# environment variables
#
export PS1="\u@\h:\w/\$ "
export PAGER="less"
export LESS="-imqMXR -x 8"
# export LESSCOLOR=red
export EDITOR="vi"
#
export TEXMFHOME=~/texmf	# dont set TEXINPUTS
export BIBCITEDIR=${TEXMFHOME}/bibtex/bib
# export CVSROOT=/project/camp/cvs  # for camp group
export CVS_RSH=ssh

#
# aliases
#
alias ls='ls -F'
alias la='ls -A'
alias ll='ls -laB'
alias du='du -hk'

set -o noclobber		# no overwrite when redirect

# user file-creation mask
umask 022
ulimit -c 0

#
# PATH
#
case $OSTYPE in
linux-gnu*)
    export PATH=/bin:/usr/bin:/usr/X11R6/bin:/usr/local/bin
#     echo -n '[31m'
#     /usr/bin/quota -q
#     echo -n '[00m'
    ;;
solaris*)
    export LANG='ja'
    export MANPATH=/usr/man:/opt/local/man:/usr/sfw/man:/opt/csw/man:/opt/SUNWspro/man:/usr/openwin/man:/usr/dt/man:/usr/X11/man
    export PATH=/opt/local/bin:/usr/bin:/usr/sfw/bin:/opt/csw/bin:/usr/ccs/bin:/opt/SUNWspro/bin:/usr/openwin/bin:/usr/dt/bin:/usr/X11/bin
    stty erase ^h
    stty intr  ^c
    stty susp  ^z
    echo -n '[31m'
    /usr/sbin/quota
    echo -n '[00m'
    ;;
esac


#重複履歴を無視
export HISTCONTROL=ignoredups
export HISTSIZE=10000

alias rdesktopfull='rdesktop onion -g 1280x1024'

xset -b

#export PATH=/bin:/usr/bin:/usr/X11R6/bin:/usr/local/bin:/home/uchida/tmp
#export PATH=/bin:/usr/bin:/usr/X11R6/bin:/usr/local/bin:/home/uchida/tmp

# export PATH=/bin:/usr/bin:/usr/X11R6/bin:/usr/local/bin:/home/uchida/tmp
