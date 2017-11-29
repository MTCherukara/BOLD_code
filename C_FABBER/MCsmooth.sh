#!/bin/bash

# this script should take as an input the name of a NIFTI file, and perform motion correction with
# MCFLIRT, and then apply Gaussian smoothing with a kernel of FWHM=0.8493mm (using FSLMATHS), and
# return a new corrected NIFTI file with the same name appended "_mcs"

# check for a real input, or else print some helpful text
if [[ $# -eq 0 ]] ; then
    echo "  "
    echo "Usage: MCsmooth <input>"
    exit 3
fi

# pull out name of nifti
fin=$1

# if the user has added .nii.gz on the end, cut it out
fin=${fin%.n*}

# check whether the nifti of that name actually exists in the current directory
if [[ -f "${fin}.nii.gz" ]]; then
    # do motion correction
    mcflirt -in ${fin} -out tn123456

    # apply smoothing
    fslmaths tn123456 -kernel gauss 0.8493 -fmean ${fin}_mcs.nii.gz

    # remove the temporary file
    rm tn123456*
else
    echo "${fin}.nii.gz not found"
fi



