#!/bin/bash

#Johnny Rao 04.08.19
#bash script to run freesurfer hippocampal segementation on T1 with T2 scan

export SUBJECTS_DIR="../data"

echo "\nSpecify prefix of T2 scan for subjects: "
read T2Scan
echo "\nSpecify analysis ID: "
read ID
echo "\nSpecify number of threads to use: "
read Threads
echo "\n"

failCount=0

for subject in "../data/" ; do

	#Running recon-all subject by subject in the directory
	"recon-all -s $subject -hippocampal-subfields-T1T2 $T2Scan*.nii $ID \
		-itkthreads $Threads"

	#Keeping track of how many failed runs
	if [ $? -ne 0 ]; then

		failCount=$failCount + 1
		echo "Subject: $subject failed \n" >> ../data/log.txt

	fi

done

#Print out the number of failed runs and a list of the subject that failed
echo "$failCount subject(s) failed"
if [ $failCount != 0 ]; then

	echo "Here are the subject(s) that failed: \n"
	cat "../data/log.txt"

fi
