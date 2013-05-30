search () {
        if [ -n "$1" ]; then
                if [ -n "$2" ]; then
                        find $1 -iname *$2* 2> /dev/null
                else
                        find / -iname *$1* 2> /dev/null
                fi
        else
                echo "Usage: search [dir] [partial_file_name]"
        fi
}
