#!/bin/bash


OLDIFS=$IFS
IFS='
'
for f in `find "$*" -type f -name "*.flf"` ; do
    # ffmpeg -i "$f" -acodec libmp3lame -ab 256k "${f%.*}.mp3"
    echo "\"$f\"" >> elmfontlist.elm
done

IFS=$OLDIFS


#
# for f in `ls`; do
#     echo $f
#     # echo "\"$f\"" >> fontlist.elm
# done
