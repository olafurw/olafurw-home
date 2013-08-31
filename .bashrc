# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
PATH="$PATH:/home/olafurw/bin:/home/olafurw/eclipse"
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
alias grep='egrep --color=auto'
alias less='/usr/share/vim/vim74/macros/less.sh'

source /home/olafurw/tools/qwe.sh
source /home/olafurw/tools/search.sh
source /home/olafurw/tools/extract.sh

_git_branch() {
  git rev-parse --is-inside-work-tree 2>/dev/null 1>&2;

  if [ $? -eq 0 ] ; then
    branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d')
    if [ "${branch}" == "* master" ] ; then
      echo "* master"
    elif [ "${branch}" ] ; then
      echo "${branch}"
    else
      echo " "
    fi
  fi   
}

# Pretty PS1
PS1="\n\[\e[37;1m\]\050\[\e[34;1m\]\d\040\t\[\e[37;1m\]\051\040\076\040\050\[\e[35;1m\]\w\[\e[37;1m\]\051\050\[\e[35;1m\]\$(_git_branch)\[\e[37;1m\]\051\n\050\[\e[33;1m\]\u\040\100\040\[\e[33;1m\]\h\[\e[37;1m\]\051\040$\040\[\e[0m\]"

# Prevents unicode spaces when doing alt space by accident instead of space.
setxkbmap -option "nbsp:none"

# Infinite history with date and current directory
# Create folder .history before using this
alias _histcut='history 1 | cut -d" " -f4-'
PROMPT_COMMAND='echo "`date +%Y-%m-%d\ %k:%M:%S` -  `pwd` -  `_histcut`" >> ~/.history/$(date +%Y-%m).log;'
