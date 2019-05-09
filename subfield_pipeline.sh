#!/bash/bash

#Johnny Rao 04.29.19
#Hippocampal Subfield Segmentation Script Pipeline

RAW_DATA="/space/md18/3/data/MMILDB/EPIPROJ/EPDTI/Containers/"
FSURF_DATA="/space/md18/3/data/MMILDB/EPIPROJ/FSRECONS/"
TESTING_FOLDER="/space/syn09/1/data/MMILDB/ABALA/Hippocampal_Subfields/"

FOLDER="ls | grep $1"

if [ $FOLDER == '' ]; then
	echo "Can't find patient folder"
	exit 1
fi

cd ${RAW_DATA}${FOLDER}

SERIES=$(Rscript -e get_raw_folder.R $FOLDER)

cp -r ${RAW_DATA}${FOLDER}${SERIES} ${TESTING_FOLDER}temp/raw

cd ${TESTING_FOLDER}temp

dcm2niix raw

cp -r $FSURF_DATA$FOLDER $TESTING_FOLDER'temp'

mv *.nii.gz T2.nii.gz

template="T2.nii.gz"
t1brain=T1.mgz

antsRegistration --dimensionality 3 --float 0 \
    --output [$TESTING_FOLDER'temp'/Template_to_${sub}_, \
	$TESTING_FOLDER'temp'/pennTemplate_to_${sub}_Warped.nii.gz] \
    --interpolation Linear \
    --winsorize-image-intensities [0.005,0.995] \
    --use-histogram-matching 0 \
    --initial-moving-transform [$t1brain,$template,1] \
    --transform Rigid[0.1] \
    --metric MI[$t1brain,$template,1,32,Regular,0.25] \
    --convergence [1000x500x250x100,1e-6,10] \
    --shrink-factors 8x4x2x1 \
    --smoothing-sigmas 3x2x1x0vox \
    --transform Affine[0.1] \
    --metric MI[$t1brain,$template,1,32,Regular,0.25] \
    --convergence [1000x500x250x100,1e-6,10] \
    --shrink-factors 8x4x2x1 \
    --smoothing-sigmas 3x2x1x0vox \

cd $TESTING_FOLDER/scripts

./hippocapal_seg_script `../temp/$FOLDER` `../temp/T2.nii.gz` 'Analysis'
