# flac2mp3.rb
A ruby script to convert flac files to mp3 files.

This is a ruby script to convert flac files to mp3 files,
using flac and lame.
It controls multiple processes for speeding up.

# Settings

## cmd varilable

Please modify the path of lame command and flac command.
Also, please modify the bit rate of mp3 etc. as you like.

## maxProcNum variable

The maximum number of processes that can be launched at the same time.

## dstDir variable

Destination path of mp3 files.

# Usage

## Without command line argument

It convers all flac files to mp3 files in the current directory.

## With command line argument

The first argument is taken as the output destination of the mp3 files.
After that, please enter the names of flac files to convert line by line from STDIN.
Finally, enter "." to start the conversion process.
