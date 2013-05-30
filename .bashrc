# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
PATH="$PATH:/home/olafurw/bin:/home/olafurw/eclipse:/home/olafurw/bin/p4v/bin"
PATH="$PATH:/home/olafurw/tools"

alias l1='ls -1'
alias ll='ls -ahl'
alias lr='ls -lart'
alias ..='cd ..'
alias ...='cd ../..'
alias .='pwd'
alias yum='sudo yum'
alias mkdir='mkdir -pv'
alias diff='colordiff'
alias path='echo -e ${PATH//:/\\n}'
alias rm='rm -I --preserve-root'

source /home/olafurw/tools/qwe.sh
source /home/olafurw/tools/search.sh
source /home/olafurw/tools/extract.sh

# Pretty PS1
PS1="\n\[\e[37;1m\]\050\[\e[34;1m\]\d\040\t\[\e[37;1m\]\051\040\076\040\050\[\e[35;1m\]\w\[\e[37;1m\]\051\n\050\[\e[33;1m\]\u\040\100\040\[\e[33;1m\]\h\[\e[37;1m\]\051\040$\040\[\e[0m\]"

# Prevents unicode spaces when doing alt space by accident instead of space.
setxkbmap -option "nbsp:none"

# Infinite history with date and current directory
# Create folder .history before using this
alias _histcut='history 1 | cut -d" " -f4-'
PROMPT_COMMAND='echo "`date +%Y-%m-%d\ %k:%M:%S` -  `pwd` -  `_histcut`" >> ~/.history/$(date +%Y-%m).log;'

export P4CLIENT="waage_1337"

source ~/.schroots
QTDIR=/usr/lib/qt-3.3
