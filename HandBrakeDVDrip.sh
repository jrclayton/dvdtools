#!/usr/bin/env bash

# Bash Script to Rip all audio, video and subtitle tracks from a DVD using the HandBrakeCLI
# Script based on my GUI preset 

# Check for arguments
if [[ $# -eq '0' ]] || [[ $# -eq '1' ]] || [[ $# -eq '2' ]] ||
	[[ $1 = '-a' && $# -ne '3' && $# -ne '4' ]] ||
	[[ $1 = '-s' && $# -ne '3' && $# -ne '4' ]] ||
	[[ $1 = '-i' && $# -ne '4' && $# -ne '5' ]] ||
	[[ $1 = '--iso' && $# -ne '4' && $# -ne '5' ]] ||
	[[ $1 = '-t' && $# -ne '5' && $# -ne '6' ]] ||
	[[ $1 = '-c' && $# -ne '6' && $# -ne '7' ]] ||
	[[ $1 = '-cf' && $# -ne '6' && $# -ne '7' ]]
then
	echo -e "Usage: dvdrip [switch] MOVIENAME YEAR ... \n \
	Select mode: either -a for all, -s to scan, -t for titles or -c for chapters or -i to change input source (add 'f' to merge chapters) \n \
	-a   MOVIENAME YEAR --CLIOPTIONS \n \
	-s   MOVIENAME YEAR --CLIOPTIONS \n \
	-t   MOVIENAME YEAR TITLE_START TITLE_END --CLIOPTIONS \n \
	-c   MOVIENAME YEAR TITLE START_CHAPTER END_CHAPTER --CLIOPTIONS \n \
	-cf  MOVIENAME YEAR TITLE START_CHAPTER END_CHAPTER --CLIOPTIONS \n \
	-i   /path/to/video MOVIENAME YEAR --CLIOPTIONS \n \
	-iso /path/to/video MOVIENAME YEAR --CLIOPTIONS \n"
	exit 1
fi

# identify the proper disk drive du moment
DVD=$(mount | grep udf | cut -d ' ' -f 1)

# test for a DVD
if ! [ $1 = '--iso' ] && ! [ $1 = '-i' ]
then
	if [ -z "$DVD" ]
	then
		echo "There is no disc mounted."
		exit 1
	fi
fi

# make an appropriately named folder on the desktop
# if --iso; then $3 $4
if [[ $1 = '--iso' ]]
then
	mkdir ~/Desktop/"$3"\ \($4\)
# if other than -i; then $2 $3
elif ! [[ $1 = '-i' ]] && ! [[ $1 = '-s' ]]
then
	mkdir ~/Desktop/"$2"\ \($3\)
fi
# if -i; no folder

### RIPPING OPTIONS ###

# To rip individual chapters from a single title into separate files
if [ $1 = '-c' ]
then
	# range of chapters to rip returned from $5 and $6
	for i in `seq $5 $6`
	do
		HandBrakeCLI --verbose=1 --markers --title $4 --chapters $i --min-duration 4 --format av_mkv --encoder x264 --quality 20.0 --vfr --x264-preset slow --h264-profile high --h264-level 4.0 --audio 1,2,3,4,5,6,7,8,9 --aencoder copy ffaac--audio-copy-mask aac,ac3,dtshd,dts,mp3 --audio-fallback ffac3 --arate Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto --ab 192,192,192,192,192,192,192,192,192 --decomb --loose-anamorphic --modulus 2 --subtitle scan,1,2,3,4,5,6,7,8,9,10 --native-language eng --subtitle-forced scan $7 -i $DVD -o ~/Desktop/"$2"\ \($3\)/"$2"\ \($3\)\ -\ $4-$i.mkv
	done

	# Notifications
	echo "Finished ripping chapters from title $4"
	terminal-notifier -message "Finished ripping chapters from title $4" -title "Terminal" -subtitle "dvdrip" -sound default -appIcon Documents/Personal_Documents/icons/dvdrip-2.png
	say -v Samantha "Finished ripping chapters from title $4"
	exit 0
fi

# To rip individual chapters from a single title but "fused" together in a single file
if [ $1 = '-cf' ]
then
	# range of chapters to rip returned from $5 and $6
	HandBrakeCLI --verbose=1 --markers --title $4 --chapters $5-$6  --min-duration 4 --format av_mkv --encoder x264 --quality 20.0 --vfr --x264-preset slow --h264-profile high --h264-level 4.0 --audio 1,2,3,4,5,6,7,8,9 --aencoder copy ffaac--audio-copy-mask aac,ac3,dtshd,dts,mp3 --audio-fallback ffac3 --arate Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto --ab 192,192,192,192,192,192,192,192,192 --decomb --loose-anamorphic --modulus 2 --subtitle scan,1,2,3,4,5,6,7,8,9,10 --native-language eng --subtitle-forced scan $7 -i $DVD -o ~/Desktop/"$2"\ \($3\)/"$2"\ \($3\)\ -\ $4-fused-$5-$6.mkv
	
	# Notifications
	echo "Finished ripping fused chapters from title $4"
	terminal-notifier -message "Finished ripping fused chapters from title $4" -title "Terminal" -subtitle "dvdrip" -sound default -appIcon Documents/Personal_Documents/icons/dvdrip-2.png
	say -v Samantha "Finished ripping fused chapters from title $4"
	exit 0
fi

# To rip a range of titles
if [ $1 = '-t' ]
then
	# range of titles to convert returned from $4 and $5	
	for i in `seq $4 $5`
	do 
		HandBrakeCLI --verbose=1 --markers --title $i --min-duration 4 --format av_mkv	--encoder x264 --quality 20.0 --vfr --x264-preset slow --h264-profile high --h264-level 4.0 --audio 1,2,3,4,5,6,7,8,9 --aencoder copy ffaac--audio-copy-mask aac,ac3,dtshd,dts,mp3 --audio-fallback ffac3 --arate Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto --ab 192,192,192,192,192,192,192,192,192 --decomb --loose-anamorphic --modulus 2 --subtitle scan,1,2,3,4,5,6,7,8,9,10 --native-language eng --subtitle-forced scan $6 -i $DVD -o ~/Desktop/"$2"\ \($3\)/"$2"\ \($3\)\ -\ $i.mkv
	done

	# Notifications
	echo "Finished ripping selected titles from $2"
	terminal-notifier -message "Finished ripping selected titles from $2" -title "Terminal" -subtitle "dvdrip" -sound default -appIcon Documents/Personal_Documents/icons/dvdrip-2.png
	say -v Samantha "Finished ripping selected titles from $2"
	exit 0
fi

# To convert a FILE to mkv using template settings
if [ $1 = '-i' ]; then

HandBrakeCLI --verbose=1 --markers --min-duration 4 --format av_mkv --encoder x264 --quality 20.0 --vfr --x264-preset slow --h264-profile high --h264-level 4.0 --audio 1,2,3,4,5,6,7,8,9 --aencoder copy ffaac--audio-copy-mask aac,ac3,dtshd,dts,mp3 --audio-fallback ffac3 --arate Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto --ab 192,192,192,192,192,192,192,192,192 --decomb --loose-anamorphic --modulus 2 --subtitle scan,1,2,3,4,5,6,7,8,9,10 --native-language eng --subtitle-forced scan $5 -i "$2" -o ~/Desktop/"$3"\ -\ \("$4"\).mkv

# Notifications
echo "Finished converting $3 to MKV"
terminal-notifier -message "Finished converting $3 to MKV" -title "Terminal" -subtitle "dvdrip" -sound default -appIcon Documents/Personal_Documents/icons/dvdrip-2.png
say -v Samantha "Finished converting $3 to MKV"
exit 0
fi

# The following options require a scan before ripping

# output of the scan option
if [ $1 = '-s' ]; then
    # First get the number of titles on the disk by doing a scan (HB CLI and -t 0) and send STDERR to STDIN so it can be grepped
    RAWOUT=$(HandBrakeCLI -t 0 --min-duration 4 -i $DVD 2>&1)
    # gives a nice summary of the scan including info about all streams
	echo "$RAWOUT" | sed -nE '/libhb\: scan thread found [0-9]+ valid title\(s\)/,$p' | tee ~/Desktop/"$2"-\($3\)-scan.txt
	exit 0
fi

# To rip ALL titles
if [ $1 = '-a' ]; then
    # First get the number of titles on the disk by doing a scan (HB CLI and -t 0) and send STDERR to STDIN so it can be grepped
    RAWOUT=$(HandBrakeCLI -t 0 --min-duration 4 -i $DVD 2>&1)
    # Generate numerical list of titles for loops
    TITLES=$(echo $RAWOUT | grep -Eao "\\+ title [0-9]+" | cut -d ' ' -f 3)
    # return a list of usable titles to plug into a for loop
	for i in $TITLES
	
	do 
		HandBrakeCLI --verbose=1 --markers --title $i --min-duration 4 --format av_mkv	--encoder x264 --quality 20.0 --vfr --x264-preset slow --h264-profile high --h264-level 4.0 --audio 1,2,3,4,5,6,7,8,9 --aencoder copy ffaac--audio-copy-mask aac,ac3,dtshd,dts,mp3 --audio-fallback ffac3 --arate Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto --ab 192,192,192,192,192,192,192,192,192 --decomb --loose-anamorphic --modulus 2 --subtitle scan,1,2,3,4,5,6,7,8,9,10 --native-language eng --subtitle-forced scan $4 -i $DVD -o ~/Desktop/"$2"\ \($3\)/"$2"\ \($3\)\ -\ $i.mkv
	done
	
	# Notifications
	echo "Finished ripping all streams from $2"
	terminal-notifier -message "Finished ripping all streams from $2" -title "Terminal" -subtitle "dvdrip" -sound default -appIcon Documents/Personal_Documents/icons/dvdrip-2.png
	say -v Samantha "Finished ripping all streams from $2"
	exit 0
fi

# To rip all titles from a VIDEO_TS or .ISO file
if [ $1 = '--iso' ]; then
    # First get the number of titles on the disk by doing a scan (HB CLI and -t 0) and send STDERR to STDIN so it can be grepped
    RAWOUT=$(HandBrakeCLI -t 0 --min-duration 4 -i "$2" 2>&1)
    # Generate numerical list of titles for loops
    TITLES=$(echo $RAWOUT | grep -Eao "\\+ title [0-9]+" | cut -d ' ' -f 3)
	# return a list of usable titles to plug into a for loop
	for i in $TITLES
	
	do
		HandBrakeCLI --verbose=1 --markers --title $i --min-duration 4 --format av_mkv	--encoder x264 --quality 20.0 --vfr --x264-preset slow --h264-profile high --h264-level 4.0 --audio 1,2,3,4,5,6,7,8,9 --aencoder copy ffaac--audio-copy-mask aac,ac3,dtshd,dts,mp3 --audio-fallback ffac3 --arate Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto --ab 192,192,192,192,192,192,192,192,192 --decomb --loose-anamorphic --modulus 2 --subtitle scan,1,2,3,4,5,6,7,8,9,10 --native-language eng --subtitle-forced scan $5 -i $2 -o ~/Desktop/"$3"\ \($4\)/"$3"\ \($4\)\ -\ $i.mkv
	done
	
	# Notifications
	echo "Finished ripping all streams from $3"
	terminal-notifier -message "Finished ripping all streams from $3" -title "Terminal" -subtitle "dvdrip" -sound default -appIcon Documents/Personal_Documents/icons/dvdrip-2.png
	say -v Samantha "Finished ripping all streams from $3"
	exit 0
fi
