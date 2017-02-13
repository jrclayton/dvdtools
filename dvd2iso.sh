#!/usr/bin/env bash

### dd will make byte for byte copies
### This method won't work for encrypted discs, which means most movies.
### So only use this if the disc isn't copy protected
#dd if=/dev/diskX of=~/Desktop/myimage.iso

### Mac OS X seems to prefer
#sudo diskutil unmountDisk /dev/diskX

### For copy-protected discs
### Use dvdbackup to decrypt the contents of the dvd and
### store the output in a local directory
#dvdbackup -i /dev/diskX -o ~/Desktop -M -n DISC_NAME

### To extract the main feature only, use
#dvdbackup -i /dev/diskX -o ~/Desktop -F -n DISC_NAME

### followed by dvdauthor to make DVD files
#export VIDEO_FORMAT=NTSC
#dvdauthor -o DISC_NAME -x ~/Desktop/dvd.xml # dvd XML file structure is not trivial

### Makes ISO fs from target directory contents
# mkisofs -V "VOLUME NAME" -dvd-video -udf -o movie.iso DISC_NAME

### To burn DVD, just use
# cdrecord -v -sao speed=1 movie.iso

### Automated version of script ###

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
    exit 1
fi

function emphasise() {
    echo ""
    echo "********** $1 **********"
    echo ""
}

# Assign disc volume name to variable
DISC_NAME=$(basename `mount | grep udf | cut -d ' ' -f 3`)
DVD=$(mount | grep udf | cut -d ' ' -f 1)

emphasise "Making a local mirror of disc with dvdbackup"

# Make a local decrypted copy of the disc
dvdbackup -i $DVD -o ~/Desktop/temp -M -n "$DISC_NAME"

if [ $? != 0 ]
then
	emphasise "dvdbackup non-zero exit status"
	exit 2
fi

emphasise "Creating ISO image"

mkisofs -V "$DISC_NAME" -dvd-video -udf -o /Volumes/Multimedia/ISOs/"$DISC_NAME".iso ~/Desktop/temp/"$DISC_NAME"

if [ $? != 0 ]
then
	emphasise "mkisofs non-zero exit status"
	exit 3
fi

emphasise "ISO image created from backup directory"

### Everything passed. Cleanup and burn DVD
cdrecord -v -sao speed=1 "$DISC_NAME".iso
if [ $? != 0 ]
then
	emphasise "cdrecord non-zero exit status"
exit 4
fi

# Cleanup
rm -rf ~/Desktop/temp/"$DISC_NAME"

emphasise "Success! DVD Burned!"
