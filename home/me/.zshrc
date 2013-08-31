#
# File: .zshrc ZSH resource file
# Author: Mike Pretzlaw <pretzlaw@gmail.com>
# Take care!
# 
# Use "chsh -s $(which zsh)" to make zsh default for current user.
#

#
# Dircolors
# http://wiki.ubuntuusers.de/dircolors
#
LS_COLORS='rs=0:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32:';
export LS_COLORS


#
# Keybindings
#

export KEYTIMEOUT=10

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
bindkey -v
typeset -g -A key

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]="^[[5~"
key[PageDown]="^[[6~"

# setup key accordingly
[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      up-line-or-history
[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    down-line-or-history
[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char

# search history that begins like the current input
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"    history-beginning-search-backward
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}"  history-beginning-search-forward

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        printf '%s' ${terminfo[smkx]}
    }
    function zle-line-finish () {
        printf '%s' ${terminfo[rmkx]}
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi

# insert sudo at beginning (CTRL+O)
insert_sudo () { zle beginning-of-line; zle -U "sudo " }
zle -N insert-sudo insert_sudo
bindkey "^O" insert-sudo


#
# Comp stuff
#
zmodload zsh/complist
autoload -Uz compinit promptinit
compinit
promptinit
zstyle :compinstall filename '${HOME}/.zshrc'

# Faster! (?)
zstyle ':completion::complete:*' use-cache 1

# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format ''
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''
#zstyle ':completion:*' completer _oldlist _expand _force_rehash _complete
zstyle ':completion:*' completer _expand _complete _approximate _ignored

zstyle ':completion:*:default' menu select=0
setopt menu_complete

# Don't complete directory we are already in (../here)
zstyle ':completion:*' ignore-parents parent pwd

#- buggy
# zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
# zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'
##-/buggy
#
# zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
#
#zstyle ':completion:*:*:kill:*' menu yes select
#zstyle ':completion:*:kill:*' force-list always
#
#zstyle ':completion:*:*:killall:*' menu yes select
#zstyle ':completion:*:killall:*' force-list always

# autocompletion of command line switches for aliases
setopt completealiases


#
# Window title
#
case $TERM in
    termite|*xterm*|rxvt|rxvt-unicode|rxvt-256color|rxvt-unicode-256color|(dt|k|E)term)
precmd () { print -Pn "\e]0;[%n@%M][%~]%#\a" }
preexec () { print -Pn "\e]0;[%n@%M][%~]%# ($1)\a" }
;;
    screen)
    precmd () {
        print -Pn "\e]83;title \"$1\"\a"
        print -Pn "\e]0;$TERM - (%L) [%n@%M]%# [%~]\a"
    }
    preexec () {
            print -Pn "\e]83;title \"$1\"\a"
            print -Pn "\e]0;$TERM - (%L) [%n@%M]%# [%~] ($1)\a"
    }
;;
esac


#
# Prompt
#

# Initialize colors.
autoload -U colors
colors

# Version control
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git cvs svn
zstyle ':vcs_info:*' actionformats '@%F{2}%b%F{3}|%F{1}%a%F{5}%f'
zstyle ':vcs_info:*' formats       '@%F{2}%b%F{5}%f'
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
precmd () { vcs_info }

# Set the prompt.
setprompt () {
    # load some modules
    autoload -U colors zsh/terminfo # Used in the colour alias below
    colors
    setopt prompt_subst
    
    # make some aliases for the colours: (coud use normal escap.seq's too)
    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    eval PR_$color='%{$fg[${(L)color}]%}'
    done
    PR_NO_COLOR="%{$terminfo[sgr0]%}"
    
    # Check if we are normal user or not
    if [[ $UID -ge 1000 ]]; then
        # normal user: username and sign green
        eval PR_USER='${PR_GREEN}%n${PR_NO_COLOR}'
        eval PR_USER_OP='${PR_GREEN}%#${PR_NO_COLOR}'
    elif [[ $UID -eq 0 ]]; then
        # root: username and sign red
        eval PR_USER='${PR_RED}%n${PR_NO_COLOR}'
        eval PR_USER_OP='${PR_RED}%#${PR_NO_COLOR}'
    fi	
    
    # Check if we are on SSH or not
    if [[ -n "$SSH_CLIENT" || -n "$SSH2_CLIENT" ]]; then
        # SSH: red host
        eval PR_HOST='${PR_RED}%m${PR_NO_COLOR}'
    else
        #no ssh: green host
        eval PR_HOST='${PR_GREEN}%m${PR_NO_COLOR}'
    fi

    # set the prompt
    PS1=$'${PR_}${PR_USER}@${PR_HOST}:%~${vcs_info_msg_0_}${PR_USER_OP} '
    PS2=$'%_> '
}
setprompt


#
# Alias definitions.
#
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
#

if [ -f ~/.aliases ]; then
    . ~/.aliases
fi
