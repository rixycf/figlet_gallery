#!/bin/bash

OLDIFS=$IFS
IFS='
'
echo "generatedFigList = ["
for f in `find "$*" -type f -name "*.flf"` ; do
    # ffmpeg -i "$f" -acodec libmp3lame -ab 256k "${f%.*}.mp3"
    echo "\"\"\""
    # figlet -f $f "HAL" | sed 's@\\@\\\\@g' | sed 's@\"@\\\"@g' 
    # figlet -f $f "HAL" | sed 's@\\@\\\\@g' | sed 's@\"@\\\"@g' | perl -pe 's/\n/&#13;&#10;/g'
    figlet -f $f "HAL" | sed 's@\\@\\\\@g' | sed 's@\"@\\\"@g' | perl -pe 's/\n/<br>/g'
    echo "\"\"\""
    echo ","

done
echo "]"

IFS=$OLDIFS
