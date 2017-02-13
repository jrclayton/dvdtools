#!/usr/bin/env bash

# Some commands to convert VOB to mp4 or mkv with ffmpeg

# mount an ISO
#hdiutil mount filename.iso

# Navigate to the VIDEO_TS directory
#cd VIDEO_TS

# Combine VOB files into full length movie

# Stream copy VOB and repackage as MPEG - no quality loss or compression
#ffmpeg -i input.vob -c:v copy -c:a copy output.mpg

# Encode mp4 with the H.264 video codec (better than default quality, 18 vs. 23)
# Encodes with the AAC audio codec and a constant bit rate, adjustable
#ffmpeg -i input.vob -c:v libx264 -crf 18 -b:a 384k -c:a aac -strict -2 output.mp4

# Single line solution that copies all audio tracks and all video tracks
#ffmpeg -i concat:VTS_01_1.VOB\|VTS_01_2.VOB\|VTS_01_3.VOB\|VTS_01_4.VOB -c:a aac -b:a 192k -strict -2 -preset slow ~/Desktop/output.mp4

###

# To Do: Rewrite the script to take as arguments the number of the titleset
# and the number of files comprising it as inputs

###



# Check we have enough command line arguments
if [ $# -lt 1 ]
then
    echo "Usage: $0 <input file 1 ... input file n>"
    exit
fi

# Check for dependencies
missing=0
dependencies=( "ffmpeg" "dvdauthor" "mkisofs" )
for command in ${dependencies[@]}
do
    if ! command -v $command &>/dev/null
    then
        echo "$command not found"
        missing=1
    fi
done

if [ $missing = 1 ]
then
    echo "Please install the missing applications and try again"
    exit
fi

function emphasise() {
    echo ""
    echo "********** $1 **********"
    echo ""
}

# Check the files exists
for var in "$@"
do
    if [ ! -e "$var" ]
    then
        echo "File $var not found"
        exit
    fi
done

emphasise "Converting to VOBs to mp4"

# concat and convert each titleset
for var in "$@"
do
	ffmpeg -i concat:"List|Of|Files" -c:a aac -b:a 192k -strict -2 -preset slow ~/Desktop/output.mp4
    if [ $? != 0 ]
    then
        emphasise "Conversion failed"
        exit
    fi
done
