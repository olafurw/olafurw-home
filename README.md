olafurw-home
============

Various scripts and settings I have in my home folder.

tools/qwe.sh
------------

The comnand line bookmarking tool qwe has it's own repository now. The original file is kept here for posterity.

https://github.com/olafurw/qwe

tools/extract.sh
----------------

Extracts most filetypes

```
Usage:
extract filename
```

tools/search.sh
---------------

Searches for a file from a directory or the root

```sh
Usage:
search [dir] [search_parameter]
```

bin/hist
--------

Greps the "infitite history" folder that is set in the `.bashrc` file

bin/imgur-upload.sh
-------------------

Uploads to imgur the given filename, returns the url and the delete url.

Depends on curl mostly. Check the source for more tools it uses.

bin/import-imgur
----------------

Uses the Image Magick import to create an image at a specified path, then uses `imgur-upload.sh` to upload that image to imgur.

Useful for taking a screenshot and get an imgur link with one command.

Dot Files
---------

`.Xefaults`  
Nothing fancy here, just a simple color scheme.

`.tmux.conf`  
Only interesting thing is Shift + left / Shift + right to traverse tabs in tmux

`.vimrc`  
4 space tabs setting I use for vim.
