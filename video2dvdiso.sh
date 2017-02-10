#!/bin/bash
# AVI or any video 2 DVD iso Script
# DvdAuthor 7 and up needs this
export VIDEO_FORMAT=NTSC
# Change to "ntsc" if you'd like to create NTSC disks
format="ntsc"

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

emphasise "Converting to MPG"

for var in "$@"
do
    ffmpeg -i "$var" -filter:v "scale='if(gt(a,720/480),720,-1)':'if(gt(a,720/480),-1,480)',pad=w=720:h=480:x=(ow-iw)/2:y=(oh-ih)/2" -y -target ${format}-dvd "$var.mpg"
    if [ $? != 0 ]
    then
        emphasise "Conversion failed"
        exit
    fi
done

emphasise "Creating XML file"

echo "<dvdauthor>
<vmgm />
<titleset>
<titles>
<pgc>" > dvd.xml

for var in "$@"
do
    echo "<vob file=\"$var.mpg\" />" >> dvd.xml
done

echo "</pgc>
</titles>
</titleset>
</dvdauthor>" >> dvd.xml

emphasise "Creating DVD contents"

dvdauthor -o dvd -x dvd.xml

if [ $? != 0 ]
then
    emphasise "DVD Creation failed"
    exit
fi

emphasise "Creating ISO image"

mkisofs -dvd-video -udf -o movie.iso dvd

if [ $? != 0 ]
then
    emphasise "ISO Creation failed"
    exit
fi

# Everything passed. Cleanup
for var in "$@"
do
    rm -f "$var.mpg"
done
rm -rf dvd/
rm -f dvd.xml

emphasise "Success: dvd.iso image created"

# To burn DVD, just use
cdrecord -v -sao speed=1 movie.iso

if [ $? != 0 ]
then
    emphasise "DVD Burn failed"
    exit
fi

emphasise "Success! DVD Burned!"