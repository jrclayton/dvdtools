#!/usr/bin/env bash

# Bash Script to Rip all audio, video and subtitle tracks from a DVD using the HandBrakeCLI
# Script based on my GUI preset 

# Check for arguments
if [[ $# -eq '0' ]] || [[ $# -eq '1' ]] || [[ $# -eq '2' ]] ||
   [[ $1 = '-a' && $# -ne '3' && $# -ne '4' ]] ||
   [[ $1 = '-i' && $# -ne '4' && $# -ne '5' ]] ||
   [[ $1 = '-t' && $# -ne '5' && $# -ne '6' ]] ||
   [[ $1 = '-c' && $# -ne '6' && $# -ne '7' ]] ||
   [[ $1 = '-cf' && $# -ne '6' && $# -ne '7' ]]
then
	echo -e "Usage: dvdrip [switch] MOVIENAME YEAR ... \n \
Select mode: either -a for all, -t for titles or -c for chapters or -i to change input source (add 'f' to merge chapters) \n \
-a  MOVIENAME YEAR --CLIOPTIONS \n \
-t  MOVIENAME YEAR TITLE_START TITLE_END --CLIOPTIONS \n \
-c  MOVIENAME YEAR TITLE START_CHAPTER END_CHAPTER --CLIOPTIONS \n \
-cf MOVIENAME YEAR TITLE START_CHAPTER END_CHAPTER --CLIOPTIONS \n \
-i  /path/to/video MOVIENAME YEAR --CLIOPTIONS \n"
    exit 1
fi

# make an appropriately named folder on the desktop
if ! [[ $1 = '-i' ]]; then
    mkdir ~/Desktop/"$2"\ \($3\)
fi

# identify the proper disk drive du moment
DVD=$(mount | grep udf | cut -d ' ' -f 1)

# To rip individual chapters from a single title
if [ $1 = '-c' ]
then
	for i in `seq $5 $6`
	do
	# set --title $4
	# set --chapters $i
	HandBrakeCLI --verbose=1 --markers --title $4 --chapters $i --min-duration 4 --format av_mkv --encoder x264 --quality 20.0 --vfr --x264-preset slow --h264-profile high --h264-level 4.0 --audio 1,2,3,4,5,6,7,8,9 --aencoder copy ffaac--audio-copy-mask aac,ac3,dtshd,dts,mp3 --audio-fallback ffac3 --arate Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto --ab 192,192,192,192,192,192,192,192,192 --decomb --loose-anamorphic --modulus 2 --subtitle scan,1,2,3,4,5,6,7,8,9,10 --native-language eng --subtitle-forced scan $7 -i $DVD -o ~/Desktop/"$2"\ \($3\)/"$2"\ \($3\)\ -\ $4-$i.mkv
	done
    echo "Finished ripping chapters from title $4"
	terminal-notifier -message "Finished ripping chapters from title $4" -title "Terminal" -subtitle "dvdrip" -sound default -appIcon Documents/Personal_Documents/icons/dvdrip-2.png
	say -v Samantha "Finished ripping chapters from title $4"
	exit 0
fi

# To rip individual chapters from a single title
if [ $1 = '-cf' ]
then
    HandBrakeCLI --verbose=1 --markers --title $4 --chapters $5-$6  --min-duration 4 --format av_mkv --encoder x264 --quality 20.0 --vfr --x264-preset slow --h264-profile high --h264-level 4.0 --audio 1,2,3,4,5,6,7,8,9 --aencoder copy ffaac--audio-copy-mask aac,ac3,dtshd,dts,mp3 --audio-fallback ffac3 --arate Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto --ab 192,192,192,192,192,192,192,192,192 --decomb --loose-anamorphic --modulus 2 --subtitle scan,1,2,3,4,5,6,7,8,9,10 --native-language eng --subtitle-forced scan $7 -i $DVD -o ~/Desktop/"$2"\ \($3\)/"$2"\ \($3\)\ -\ $4-fused-$5-$6.mkv
    echo "Finished ripping fused chapters from title $4"
    terminal-notifier -message "Finished ripping fused chapters from title $4" -title "Terminal" -subtitle "dvdrip" -sound default -appIcon Documents/Personal_Documents/icons/dvdrip-2.png
    say -v Samantha "Finished ripping fused chapters from title $4"
    exit 0
fi

# To rip a range of titles
if [ $1 = '-t' ]
then
	# return a list of usable titles to plug into a for loop	
	for i in `seq $4 $5`
	do 
	HandBrakeCLI --verbose=1 --markers --title $i --min-duration 4 --format av_mkv	--encoder x264 --quality 20.0 --vfr --x264-preset slow --h264-profile high --h264-level 4.0 --audio 1,2,3,4,5,6,7,8,9 --aencoder copy ffaac--audio-copy-mask aac,ac3,dtshd,dts,mp3 --audio-fallback ffac3 --arate Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto --ab 192,192,192,192,192,192,192,192,192 --decomb --loose-anamorphic --modulus 2 --subtitle scan,1,2,3,4,5,6,7,8,9,10 --native-language eng --subtitle-forced scan $6 -i $DVD -o ~/Desktop/"$2"\ \($3\)/"$2"\ \($3\)\ -\ $i.mkv
	done	
    echo "Finished ripping selected titles from $2"
	terminal-notifier -message "Finished ripping selected titles from $2" -title "Terminal" -subtitle "dvdrip" -sound default -appIcon Documents/Personal_Documents/icons/dvdrip-2.png
	say -v Samantha "Finished ripping selected titles from $2"
	exit 0
fi

# To process in batch, first get the number of titles on the disk by using HB CLI and -t 0

# To rip all titles
if [ $1 = '-a' ]
then
	RAWOUT=$(HandBrakeCLI -t 0 --min-duration 4 -i $DVD -o ~/Desktop/temp.mkv 2>&1 >/dev/null)
	# return a list of usable titles to plug into a for loop	
	for i in `echo $RAWOUT | grep -Eao "\\+ title [0-9]+" | cut -d ' ' -f 3`
	do 
	HandBrakeCLI --verbose=1 --markers --title $i --min-duration 4 --format av_mkv	--encoder x264 --quality 20.0 --vfr --x264-preset slow --h264-profile high --h264-level 4.0 --audio 1,2,3,4,5,6,7,8,9 --aencoder copy ffaac--audio-copy-mask aac,ac3,dtshd,dts,mp3 --audio-fallback ffac3 --arate Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto --ab 192,192,192,192,192,192,192,192,192 --decomb --loose-anamorphic --modulus 2 --subtitle scan,1,2,3,4,5,6,7,8,9,10 --native-language eng --subtitle-forced scan $4 -i $DVD -o ~/Desktop/"$2"\ \($3\)/"$2"\ \($3\)\ -\ $i.mkv
	done
    echo "Finished ripping all streams from $2"
	terminal-notifier -message "Finished ripping all streams from $2" -title "Terminal" -subtitle "dvdrip" -sound default -appIcon Documents/Personal_Documents/icons/dvdrip-2.png
	say -v Samantha "Finished ripping all streams from $2"
	exit 0
fi

# To convert a file to mkv using template settings
if [ $1 = '-i' ]
then
	HandBrakeCLI --verbose=1 --markers --title 1 --min-duration 4 --format av_mkv --encoder x264 --quality 20.0 --vfr --x264-preset slow --h264-profile high --h264-level 4.0 --audio 1,2,3,4,5,6,7,8,9 --aencoder copy ffaac--audio-copy-mask aac,ac3,dtshd,dts,mp3 --audio-fallback ffac3 --arate Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto,Auto --ab 192,192,192,192,192,192,192,192,192 --decomb --loose-anamorphic --modulus 2 --subtitle scan,1,2,3,4,5,6,7,8,9,10 --native-language eng --subtitle-forced scan $5 -i "$2" -o ~/Desktop/"$3"\ -\ "$4".mkv
    echo "Finished converting $3 to MKV"
	terminal-notifier -message "Finished converting $3 to MKV" -title "Terminal" -subtitle "dvdrip" -sound default -appIcon Documents/Personal_Documents/icons/dvdrip-2.png
	say -v Samantha "Finished converting $3 to MKV"
	exit 0
fi
