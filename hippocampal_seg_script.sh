#!/bin/bash

#Johnny Rao 04.29.19
#bash script to run freesurfer hippocampal segementation on T1 with T2 scan

#export SUBJECTS_DIR=$(readlink -f ../data)

if [ -z "$1" ]; then

	echo " ./hippocamp_seg_script <T2 file> <SUbject ID> <Optional Threads count>

		subject - file of the subject in data directory
		T2 Scan - is the name of the T2 scan
		Analysis ID - is the ID assigned to this test
		Threads count - (Optional) Number of threads to use with multithreading"
	exit 1

fi

subject=$1

if [ -z "$2" ]; then

	echo " ./hippocamp_seg_script <T2 file> <SUbject ID> <Optional Threads count>\n\n

		subject - file of the subject in data directory\n
		T2 Scan - is the name of the T2 scan\n
		Analysis ID - is the ID assigned to this test\n
		Threads count - (Optional) Number of threads to use with multithreading\n\n"
	exit 1

fi
T2Scan=$2

if [ -z "$3" ]; then

	echo " ./hippocamp_seg_script <T2 file> <SUbject ID> <Optional Threads count>\n\n

		subject - file of the subject in data directory\n
		T2 Scan - is the name of the T2 scan\n
		Analysis ID - is the ID assigned to this test\n
		Threads count - (Optional) Number of threads to use with multithreading\n\n"
	exit 1

fi
ID=$3

Threads=$4
if [ -z "$Threads" ]; then

	echo " Threads count will be set to 4 (default)\n"
	Threads=4

fi

if [ $# -gt 4 ]; then

	echo " ./hippocamp_seg_script <T2 file> <SUbject ID> <Optional Threads count>\n\n

		subject - file of the subject in data directory\n
		T2 Scan - is the name of the T2 scan\n
		Analysis ID - is the ID assigned to this test\n
		Threads count - (Optional) Number of threads to use with multithreading\n\n"
	exit 1

fi



#Running recon-all subject by subject in the directory
recon-all -s $subject -hippocampal-subfields-T1T2 $T2Scan $ID \
	-itkthreads $Threads
