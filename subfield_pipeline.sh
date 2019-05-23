#!/bin/bash

#Johnny Rao 04.29.19
#Hippocampal Subfield Segmentation Script Pipeline

RAW_DATA="/space/md18/3/data/MMILDB/EPIPROJ/EPDTI/Containers/"
FSURF_DATA="/space/md18/3/data/MMILDB/EPIPROJ/FSRECONS/"
TESTING_FOLDER=$FSURF_DATA
SCRIPT_FOLDER=${TESTING_FOLDER}/scripts/

echo $1

[ $(ls $RAW_DATA | grep -c $1) -gt 1 ] &&
	(echo "Multiple matches found! Exiting..." && exit 1)

FOLDER=$(ls $RAW_DATA | grep $1)

echo $FOLDER
if [ -z "$FOLDER" ]; then
	echo "Can't find patient folder"
	exit 1
fi

cd ${RAW_DATA}${FOLDER}

SERIES=$(Rscript ${SCRIPT_FOLDER}/get_folder.R ${RAW_DATA}${FOLDER}/SeriesInfo.csv)

echo "T2 dicoms folder is: $FOLDER/$SERIES"

# make all the folders
fsurf_dir=FSURF_${FOLDER#MRIRAW_}
mkdir -p ${TESTING_FOLDER}/${fsurf_dir}/temp/raw

# copy dcms
echo "Copying T2 dicoms..."
rsync -rL ${RAW_DATA}/${FOLDER}/${SERIES}/* ${fsurf_dir}/temp/raw

#echo "Copying FSRECON..."
# copy freesurfer stuff
#rsync -rL ${FSURF_DATA}/FSURF_${FOLDER#MRIRAW_}/* ${TESTING_FOLDER}/data/temp

cd ${fsurf_dir}

echo "Converting dicom to nifti..."
# convert T2 dicoms to nifti (gz)
dcm2niix -f "%p" -z i raw

mv $(ls raw/FSE_T2_GOOD.nii.gz) raw/T2.nii.gz

echo "Skull stripping T2..."
# run robex
cd raw
${HOME}/Desktop/ROBEX/runROBEX.sh T2.nii.gz T2_stripped.nii.gz T2_mask.nii.gz
mri_convert --in_orientation LSP --out_orientation LIA T2_stripped.nii.gz T2_stripped.nii.gz
mri_convert --in_orientation LIA --out_orientation LIA ../mri/brainmask.mgz brainmask.nii.gz

template=${fsurf_dir}/temp/raw/T2_stripped.nii.gz
t1brain=${fsurf_dir}/temp/raw/brainmask.nii.gz

printf "MOVING: %s\n" $template
printf "REFERENCE: %s\n" $t1brain

flirt -in $template\
	-ref $t1brain\
	-out ${template%_stripped.nii.gz}_deformed.nii.gz\
	-noresample\
	-omat ${fsurf_dir}/temp/t2_to_t1.mat\
	-usesqform\
	-cost mutualinfo\
	-searchcost mutualinfo

cd $SCRIPT_FOLDER

./hippocampal_seg_script.sh temp ${fsurf_dir}/temp/raw/T2_deformed.nii.gz T1T2 20
#./hippocampal_seg_scriptT2.sh temp ${TESTING_FOLDER}/data/temp/raw/T2_stripped.nii.gz T2 30
