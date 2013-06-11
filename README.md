olafurw-home
============

Various scripts and settings I have in my home folder.

tools/qwe.sh
------------

A tool to bookmark the current folder you are in. Stores a list of folders in a dot file in your home directory. You bookmark the folder by giving it a short tag, then you can travel to it by using the tag. Just add "source qwe.sh" to your .bashrc or other profile dot-files to make it work.

Usage:
qwe name : Traverse to directory tagged name
qwe -h : Help
qwe -l : List of saved tags
qwe -a name : Add a tag called name with the current folder
qwe -d name : Remove a tag called name
qwe -p name : Print the directory tagged with name

tools/extract.sh
----------------

Extracts most filetypes

Usage:
extract filename

tools/search.sh
---------------

Searches for a file from a directory or the root

Usage:
search [dir] [search_parameter]


bin/hist
--------

Greps the "infitite history" folder that is set in the .bashrc file

bin/imgur-upload.sh
-------------------

Uploads to imgur the given filename, returns the url and the delete url.

Depends on curl mostly. Check the source for more tools it uses.

bin/import-imgur
----------------

Uses the Image Magick import to create an image at a specified path, then uses imgur-upload.sh to upload that image to imgur.

Useful for taking a screenshot and get an imgur link with one command.

Dot Files
---------

.Xefaults
Nothing fancy here, just a simple color scheme.

.tmux.conf
Only interesting thing is Shift + left / Shift + right to traverse tabs in tmux

.vimrc
4 space tabs setting I use for vim.
