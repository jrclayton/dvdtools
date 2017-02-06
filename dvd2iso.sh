#!/bin/bash

# dd will make byte for byte copies of, for example, the system disk1,
# which is the DVD/CD-ROM Drive
# This method won't work for encrypted discs, which means most movies.
# So only use this if the disc isn't copy protected
#sudo umount /dev/disk1
#dd if=/dev/disk1 of=~/Desktop/myimage.iso

# OR Mac seems to like

#sudo diskutil unmountDisk /dev/disk1

# Alternatively
# Use dvdbackup to decrypt the contents of the dvd and
# store the output in a local directory
#dvdbackup -i /dev/disk1 -o ~/Desktop -M -n DISC_NAME

#########################

# To extract the main feature only, use
#dvdbackup -i /dev/disk1 -o ~/Desktop -F -n DISC_NAME

# followed by dvdauthor to make DVD files
#export VIDEO_FORMAT=NTSC
#dvdauthor -o DISC_NAME -x ~/Desktop/dvd.xml # dvd XML file structure is not trivial


#########################

# Makes ISO fs from target directory contents
# mkisofs -V "VOLUME NAME" -dvd-video -udf -o movie.iso DISC_NAME

# To burn DVD, just use
# cdrecord -v -sao speed=1 movie.iso


### Automated version of script ###

# DvdAuthor 7 and up needs this
# export VIDEO_FORMAT=NTSC
# Change to "ntsc" if you'd like to create NTSC disks
# format="ntsc"

# Check for dependencies
missing=0
dependencies=( "dvdbackup" "dvdauthor" "mkisofs" "cdrecord" )
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

# Assign disc volume name to variable
DISC_NAME=$(df | grep /dev/disk1 | cut -d "/" -f 5)

emphasise "Making a local mirror of disc with dvdbackup"

dvdbackup -i /dev/disk1 -o ~/Desktop/temp -M -n "$DISC_NAME"
if [ $? != 0 ]
then
	emphasise "dvdbackup non-zero exit status"
	exit
fi

emphasise "Creating ISO image"

mkisofs -V "$DISC_NAME" -dvd-video -udf -o /Volumes/Multimedia/ISOs/"$DISC_NAME".iso ~/Desktop/temp/"$DISC_NAME"
if [ $? != 0 ]
then
	emphasise "mkisofs non-zero exit status"
	exit
fi

emphasise "ISO image created from backup directory"

# Everything passed. Cleanup and burn DVD
#cdrecord -v -sao speed=1 "$DISC_NAME".iso
#if [ $? != 0 ]
#then
#	emphasise "cdrecord non-zero exit status"
#	exit
#fi	
#rm -rf ~/Desktop/temp/"$DISC_NAME"
#
#
#emphasise "Success! DVD Burned!"
