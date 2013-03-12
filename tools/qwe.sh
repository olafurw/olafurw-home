qwe () {
    dataFile=$HOME/.qwe.data
    currentDirectory=$(pwd)
    touch $dataFile

    harg=""
    if [ $# == 0 ]; then
        harg="-h"
    elif [ $# == 1 -a $1 == "-h" ]; then
        harg="-h"
    fi

    if [ "$harg" == "-h" ]; then
        echo "Usage:"
        echo "qwe name : Traverse to directory tagged name"
        echo "qwe -h : Help"
        echo "qwe -l : List of saved tags"
        echo "qwe -a name : Add a tag called name with the current folder"
        echo "qwe -d name : Remove a tag called name"
        echo "qwe -p name : Print the directory tagged with name"
    elif [ $1 == "-a" -a $# == 2 ]; then
        touch $dataFile
        echo -e $2"\t"$currentDirectory >> $dataFile
    elif [ $1 == "-l" -a $# == 1 ]; then
        cat $dataFile
    elif [ $1 == "-d" -a $# == 2 ]; then
        data=$(cat $dataFile)
        tagList=$(echo "$data"|sed 's/[ \t].*//')
        lineNumberInfo=$(echo "$tagList"|grep -ne "^$2$")

        dataCount=$(echo "$lineNumberInfo"|wc -m)

        if [ $dataCount -gt 1 ]; then
            lineNumber=$(echo $lineNumberInfo|cut -d ":" -f1)

            sed -i -e "$lineNumber"'d' $dataFile
        else
            echo "Tag $2 not found"
        fi
    elif [ $1 == "-p" -a $# == 2 ]; then
        data=$(cat $dataFile)
        tagList=$(echo "$data"|sed 's/[ \t].*//')
        lineNumberInfo=$(echo "$tagList"|grep -ne "^$2$")

        dataCount=$(echo "$lineNumberInfo"|wc -m)

        if [ $dataCount -gt 1 ]; then
            lineNumber=$(echo $lineNumberInfo|cut -d ":" -f1)
            line=$(head -$lineNumber $dataFile|tail -1)
            directory=$(echo $line|sed 's/^[a-zA-Z0-9\.-]*\ *//'|sed 's/ /\\ /g')

            echo $directory
         else
            echo "Tag $2 not found"
         fi
    elif [ $# == 1 ]; then
        data=$(cat $dataFile)
        tagList=$(echo "$data"|sed 's/[ \t].*//')
        lineNumberInfo=$(echo "$tagList"|grep -ne "^$1$")

        dataCount=$(echo "$lineNumberInfo"|wc -m)

        if [ $dataCount -gt 1 ]; then
            lineNumber=$(echo $lineNumberInfo|cut -d ":" -f1)
            line=$(head -$lineNumber $dataFile|tail -1)
            directory=$(echo $line|sed 's/^[a-zA-Z0-9\.-]*\ *//'|sed 's/ /\\ /g')

            eval cd $directory
        else
            echo "Tag $1 not found"
        fi
    fi
}
