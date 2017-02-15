# DVD Tools

This repository represents a collection of scripts I have put together while in the process of digitizing my DVD collection. It contains tools for automation of the ripping and transcoding process

## Getting Started

All files are simple shell scripts written on a Mac OSX (10.12.3) and Bash 3.2 

### Dependencies

What things you need to install the software and how to install them

```
dvd2iso.sh
	- dvdbackup
	- dvdauthor
	- mkisofs
	- cdrecord

HandBrakeDVDrip.sh
	- HandBrakeCLI
	- terminal-notifier # (Mac OSX) --> Linux has many
	- say # (Mac OSX) --> espeak for Linux

video2dvdiso.sh
	- ffmpeg
	- dvdauthor
	- mkisofs

vob2mp4.sh
	- ffmpeg
	- dvdauthor
	- mkisofs

vobsub2srt.sh
	- mkvextract
	- tesseract
	- tesseract-eng # plus whichever other languages you need
	- vobsub2srt
```


### Installing

A step by step series of examples that tell you have to get a development env running

First, clone this repository to your local machine

```
git clone https://github.com/jrclayton/dvdtools.git
```

Next, change the permissions to make executable

```
chmod -R 755 /path/to/dvdtools
```

Then make a symbolic link to the script in the dvdtools directory so it is in your PATH. For me, that's usually /usr/local/bin

```
ln -s /path/to/dvdtools/script.sh /usr/local/bin/script
```

Scripts should now be usable.

## Authors

* **John R. Clayton** - *Initial work* - [jrclayton](https://github.com/jrclayton)

## Acknowledgments

* I stole some of this code from other github users before I made my own repositories. I'll come back to this and give them credit once I figure out who it was. Will just nead to search around a bit.
* Thanks to **julienXX** for terminal-notifier [julienXX](https://github.com/julienXX/terminal-notifier)
