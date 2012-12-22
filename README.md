olafurw-home
============

Various scripts and settings I have in my home folder.

tools/qwe.sh
------------

A tool to bookmark the current folder you are in. Stores a list of folders in a dot file in your home directory. You bookmark the folder by giving it a short tag, then you can travel to it by using the tag. Just add "source qwe.sh" to your .bashrc or other profile dot-files to make it work.

qwe -a test
Adds the current folder to the list with the tag test

qwe test
Travels to the folder with the tag test

qwe -l
Shows a list of all tags

Dot Files
---------

.Xefaults
Nothing fancy here, just a simple color scheme.

.tmux.conf
Only interesting thing is Shift + left / Shift + right to traverse tabs in tmux

.vimrc
4 space tabs setting I use for vim.
