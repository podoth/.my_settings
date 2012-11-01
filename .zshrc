# interactiveなとき以外(scp等)は何もしない
if [ -z "$PS1" ]; then
    return
fi

export SHELL=/bin/zsh

autoload -U compinit
compinit
autoload colors
colors
zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
zstyle ':zle:*' word-chars " -~()/:@+|"
zstyle ':zle:*' word-style unspecified

autoload -Uz select-word-style
select-word-style bash

# 単語単位での区切り
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
bindkey ";5C" forward-word
bindkey "5C" forward-word
bindkey ";5D" backward-word
bindkey "5D" backward-word

# prompt setting
#export    PROMPT="%n@"$'%{\e[$[41]m%}'"$HOST"$'\e[m'":%~/$ "
#export PROMPT="%B%n%b@${HOST%%.*}:%/%{%}/$ "
export PROMPT="%n%b@%m:%~/$ "
export SPROMPT="%B%{${fg[gray]}%}%r is correct? [n,y,a,e]:%{${reset_color}%}%b "

# environment variables
export LANG=ja_JP.UTF-8
# export LSCOLORS=exfxcxdxbxegedabagacad
# export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
#eval `dircolors`

## 補完候補の色づけ
eval `dircolors`
export ZLS_COLORS=$LS_COLORS
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
# export JAVA_HOME='/usr/lib/jvm/java-1.6.0-openjdk'


# encolor with kill complete
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([%0-9]#)*=0=01;31'



# history
HISTFILE=~/.zsh_history
HISTSIZE=10000000
SAVEHIST=10000000
setopt hist_ignore_all_dups     # ignore duplication command history list
setopt hist_ignore_dups     # ignore duplication command history list
setopt share_history        # share command history data
setopt share_history         # コマンド履歴ファイルを共有する
setopt append_history        # 履歴を追加 (毎回 .zsh_history を作るのではなく)
setopt inc_append_history    # 履歴をインクリメンタルに追加
setopt hist_no_store         # historyコマンドは履歴に登録しない
setopt hist_reduce_blanks    # 余分な空白は詰めて記録


# emacs like
bindkey -e

# history with C-p C-n
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# move with directory name
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt auto_menu
setopt magic_equal_subst
setopt print_eight_bit


# other...
setopt correct
setopt list_packed
setopt nolistbeep
autoload math functions
setopt complete_aliases

# user file-creation mask
umask 022
ulimit -c 0

#
# PATH
#
case $OSTYPE in
linux-gnu*)
    export PATH=/bin:/usr/bin:/usr/X11R6/bin:/usr/local/bin
    alias ls='ls -F --color=auto'
    # echo -n '[31m'
    # /usr/bin/quota -q
    # echo -n '[00m'
    ;;
solaris*)
    export LANG='ja'
    export MANPATH=/usr/man:/opt/local/man:/usr/sfw/man:/opt/csw/man:/opt/SUNWspro/man:/usr/openwin/man:/usr/dt/man:/usr/X11/man
    export PATH=/opt/local/bin:/usr/bin:/usr/sfw/bin:/opt/csw/bin:/usr/ccs/bin:/opt/SUNWspro/bin:/usr/openwin/bin:/usr/dt/bin:/usr/X11/bin
    alias ls='ls -F'
    stty erase ^h
    stty intr  ^c
    stty susp  ^z
    echo -n '[31m'
    /usr/sbin/quota
    echo -n '[00m'
    ;;
esac

# alias

alias la='ls -A'
alias ll='ls -laBh'
alias du='du -hk'
alias less='less -M'
#alias rdesktopfull='rdesktop onion -g 1280x1024'
alias rdesktoponion='rdesktop onion -K -g 1900x1100+0-0'
alias rdesktoponionslow='rdesktop onion -K -g 800x600+0-0 -x modem -z'
alias rdesktoppersil='rdesktop persil -K -g 1900x1100'
alias rdesktopbasilic='rdesktop basilic -K -g 1900x1100+0-0'

xset -b

#openofficeでuimが使えるように
# export GTK_IM_MODULE=uim
# export QT_IM_MODULE=uim

# 補完の時に大文字小文字を区別しない (但し、大文字を打った場合は小文字に変換しない)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'


#shutdown,reboot無効化
alias shutdown=ls
alias reboot=ls
#sudo時もaliasが効くように
alias sudo='sudo '

setopt list_packed

#xmonad with gnome 専用のログアウト命令
alias super_logout='gnome-session-save --logout-dialog --gui'

#別のPCでfirefoxを開くときに
alias firefox-remote='firefox -no-remote -p'

## 内部コマンド jobs の出力をデフォルトで jobs -l にする
setopt long_list_jobs
## 補完候補一覧でファイルの種別をマーク表示
setopt list_types
## 補完候補のカーソル選択を有効に
zstyle ':completion:*:default' menu select=1

## colorgccを使用（あれば
if [ -e /usr/bin/colorgcc ]; then
    export CC="colorgcc"
    alias gcc='colorgcc'
fi

#容量がでかいのを表示
alias filesumcurrent='du -sk * | sort -nr | head -n 10'

# zsh版 sshopt -s dotglob
setopt dotglob

#scim+GTKには必要
export GTK_IM_MODULE=scim-bridge

#emacsclientを使用。serverの立ち上げはgnomeの設定で
# alias emacs="${HOME}/.emacs.d/emacsclient.sh"
# alias emacs='emacsclient -c'
alias e='emacsclient --alternate-editor="" -c'

alias ack='ack-grep'
alias gitwebtmp='git instaweb --httpd=webrick'
alias lv='lv -c'
