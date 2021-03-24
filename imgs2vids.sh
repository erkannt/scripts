#!/bin/bash
set -euo pipefail

NAME="63x_2020-10-21_141235"

function convert_images () {
    mkdir -p /tmp/asjpg
    rm /tmp/asjpg/*
    cd "/media/hff/My Passport/Eva K/191021_C2_DIV2_cort_neurons_F4/${1}"
    mogrify -path /tmp/asjpg -format jpg -depth 8 -evaluate multiply 4 *.tiff
}

function render_video () {
    mkdir -p /tmp/eva_calcium_vids
    cd /tmp/asjpg
    ffmpeg -y -r 2 -i ${1}_t%d_p0.ome.jpg -c:v libx264 -vf "fps=25,format=yuv420p" /tmp/eva_calcium_vids/${1}.mp4
}

convert_images $NAME
render_video $NAME
