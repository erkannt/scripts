#!/bin/bash

# Convert folders of 16bit tiffs to mp4 videos
#
# Given `input_root_dir` and `output_root_dir`:
# - convert each folder of tiffs int a folder of jpgs in /tmp
# - go from 16bit to 8bit images, multiplying the brightness by IMAGE_VALUE_MULTIPLIER
# - convert to mp4
# - save video into `output_root_dir` under the name of the folder containing the tiffs
#
# Requires: imagemagick and ffmpeg

set -euo pipefail

input_root_dir="$1"
output_root_dir="$2"

IMAGE_VALUE_MULTIPLIER=4

function convert_images () {
    root_dir="$1"
    sub_dir="$2"

    mkdir -p /tmp/asjpg
    rm -f /tmp/asjpg/*

    cd "$root_dir"/"$sub_dir"
    mogrify \
        -depth 8 \
        -evaluate multiply ${IMAGE_VALUE_MULTIPLIER} \
        -format jpg \
        -path /tmp/asjpg \
        *.tiff \
        || echo "ERROR: mogrify failure --" "$root_dir"/"$sub_dir"
}


function render_video () {
    output_dir="$1"
    input_name="$2"
    input_img_name_fragment="${2%_Y1}"

    mkdir -p "$output_dir"
    cd /tmp/asjpg

    ffmpeg -y -hide_banner -loglevel error \
        -i "$input_img_name_fragment"_t%d_p0.ome.jpg \
        -r 2 \
        -c:v libx264 \
        -vf "fps=25,format=yuv420p" \
        "$output_dir"/"$input_name".mp4 \
        || echo "ERROR: ffmpeg failure --" "$output_dir"/"$input_name"

    rm -rf /tmp/asjpg
}


cd "$input_root_dir"
for subdir in */; do
    convert_images "$input_root_dir" "${subdir%/}"
    render_video "$output_root_dir" "${subdir%/}"
done
