#!/bin/bash

OLDIFS=$IFS
IFS='
'
echo "figlet = ["
for f in `find "$*" -type f -name "*.flf"` ; do
    # ffmpeg -i "$f" -acodec libmp3lame -ab 256k "${f%.*}.mp3"
    echo "\"\"\""
    figlet -f $f "HAL" | sed 's@\\@\\\\@g' | sed 's@\"@\\\"@g'
    echo "\"\"\""
    echo ","

done
echo "]"

IFS=$OLDIFS
