#!/bin/bash

########################################################
#  @kid  2018/08/06
#  mp4ファイルをmp3に変換するスクリプト
#  
#  Usage:
#       /path/to/convert_mp4to3_impr.sh DIR_NAME
#
#  example:
#       ./convert_mp4to3_impr.sh ~/Music/ELLEGARDEN/ELLEGARDEN\ BEST\ (1999-2008)
#  
########################################################


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
