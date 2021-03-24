#!/bin/bash
set -euo pipefail

DIR="$1"

function convert_images () {
    mkdir -p /tmp/asjpg
    rm -f /tmp/asjpg/*
    cd "$1"/"$2"
    mogrify -path /tmp/asjpg -format jpg -depth 8 -evaluate multiply 4 *.tiff
}

function render_video () {
    mkdir -p /tmp/eva_calcium_vids
    cd /tmp/asjpg
    ffmpeg -y -hide_banner -loglevel error -r 2 -i "$1"_t%d_p0.ome.jpg -c:v libx264 -vf "fps=25,format=yuv420p" /tmp/eva_calcium_vids/"$1".mp4
    rm -rf /tmp/asjpg
}

cd "$DIR"
for subdir in */; do
    echo ${subdir%/}
    convert_images "$DIR" "${subdir%/}"
    render_video "${subdir%/}"
done

