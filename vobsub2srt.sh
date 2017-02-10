#!/bin/bash

# My little script to convert VOBSUB image-based subtitle streams from an mov file
# into srt output (e.g. for YouTube or Plex)

# Information on stream or “track” number can be found with mkvinfo from this package

# To create an .idx and .sub file for a subtitle stream
mkvextract tracks video.mkv 10:ita

# To extract an AC3 audio track
mkvextract tracks video.mkv 4:fre.ac3

# For subs, next run the binary vobsub2srt
# which depends on tesseract
# make sure to install the appropriate language training
# package for the tesseract OCR engine (e.g. tesseract-eng)

#cd to <Directory_with_sub_idx_files>
vobsub2srt eng eng.srt