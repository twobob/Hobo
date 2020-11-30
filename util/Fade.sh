#!/bin/bash

# Audio + vidéo fade out at the end of mp4 files

# 2015-09-09 19:07:17.0 +0200 / Gilles Quenot
# tweaked by twobob 2020

# length of the fade out
fade_duration=3 # seconds

if [[ ! $2 ]]; then
    cat<<EOF
Usage:
    ${0##*/} <input mp4> <output mp4>
EOF
    exit 1
fi

if [[ -f "$2" ]] ; then
    echo "$2 already exists. Exiting."
    exit 1
fi


for x in bc awk ffprobe ffmpeg; do
    if ! type &>/dev/null $x; then
        echo >&2 "$x should be installed"
        ((err++))
    fi
done

((err > 0)) && exit 1

duration=$(ffprobe -select_streams v -show_streams "$1" 2>/dev/null |
    awk -F= '$1 == "duration"{print $2}')
final_cut=$(bc -l <<< "$duration - $fade_duration")
ffmpeg -n -i "$1" \
    -filter:v "fade=out:st=$final_cut:d=$fade_duration" \
    -af "afade=t=out:st=$final_cut:d=$fade_duration" \
    -c:v libx264 -c:a aac -strict experimental -shortest -pix_fmt yuv420p -preset slower "$2"
