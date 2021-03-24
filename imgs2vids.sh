#!/bin/bash
set -euo pipefail

NAME="63x_2020-10-21_141235"
cd "/media/hff/My Passport/Eva K/191021_C2_DIV2_cort_neurons_F4/${NAME}"
mkdir -p /tmp/asjpg
rm /tmp/asjpg/*
mogrify -path /tmp/asjpg -format jpg -depth 8 -evaluate multiply 4 *.tiff
cd /tmp/asjpg
ffmpeg -y -r 2 -i ${NAME}_t%d_p0.ome.jpg -c:v libx264 -vf "fps=25,format=yuv420p" /tmp/$NAME.mp4
