#!/bin/bash

read -p "youtube url: " pl_url
read -p "artist name: " ar_nam
read -p "music album: " al_nam
read -p "music gener: " ms_gen
read -p "album cover: " cv_url
read -p "folder  dst: " fd_dst

mkdir -p "$fd_dst"; cd "$fd_dst"

echo "downloading album cover, please wait.."
wget -O "cover.jpg" "$cv_url" > /dev/null 2>&1

echo "downloading song(s) please wait.."
yt-dlp -f bestaudio[ext=m4a] -o "%(timestamp)s.%(ext)s" "$pl_url" > /dev/null 2>&1

echo "changing metadata, please wait ..."
for file_ in *.m4a; do
    exiftool -overwrite_original -Title="$file_" -Album="$al_nam" -Artist="$ar_nam" -Genre="$ms_gen" "$file_" > /dev/null 2>&1
    exiftool -overwrite_original "-CoverArt<=cover.jpg" "$file_" > /dev/null 2>&1
done

rm -rf cover.jpg
echo -e "ok, everything is fine"
