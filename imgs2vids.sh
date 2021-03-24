#!/bin/bash
set -euo pipefail

DIR="$1"
OUTPUT="$2"

function convert_images () {
    mkdir -p /tmp/asjpg
    rm -f /tmp/asjpg/*
    cd "$1"/"$2"
    mogrify \
        -depth 8 \
        -evaluate multiply 4 \
        -format jpg \
        -path /tmp/asjpg \
        *.tiff \
        || echo "ERROR: mogrify failure --" "$1"/"$2"
}

function render_video () {
    mkdir -p "$1"
    cd /tmp/asjpg
    ffmpeg -y -hide_banner -loglevel error \
        -i "${2%_Y1}"_t%d_p0.ome.jpg \
        -r 2 \
        -c:v libx264 \
        -vf "fps=25,format=yuv420p" \
        "$1"/"$2".mp4 \
        || echo "ERROR: ffmpeg failure --" "$1"/"$2"
    rm -rf /tmp/asjpg
}

cd "$DIR"
for subdir in */; do
    convert_images "$DIR"    "${subdir%/}"
    render_video   "$OUTPUT" "${subdir%/}"
done
