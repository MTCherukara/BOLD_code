#!/bin/bash

# this script should take as an input the name of a folder containing results from fabber and
# create a new .nii.gz file which will be a map of OEF, caluclated by dividing the mean_R2p map
# by mean_DBV (multiplied by 301.74, which is dw given our other parameters)
#
# Matthew Cherukara, 3 October 2017

# directory of results
rdir=~/Documents/DPhil/Data/Fabber_Results

# find the name of the directory that has the specified number, if no input is specified, use the
# default-created directory "+" 
if [[ $# -eq 0 ]] ; then
    dname="+"
else
    dname=$(ls ${rdir} | grep "$1")
fi

# check if a set of fabber results of that number exists
if [[ -d "${rdir}/${dname}" ]] ; then
    # if it does, carry out the calculation

    # for the DBV file, first take the absolute value
    #                   then threshold all values above 1 to 1
    #                   then multiply by 301, and save to temporary file
    fslmaths ${rdir}/${dname}/mean_DBV.nii.gz -abs -sub 1 -uthr 0 -add 1 -mul 301.74 temp_DBV.nii.gz

    # for the R2p file, first take the absolute value
    #                   then divide by the temporary DBV file, and save to OEF
    fslmaths ${rdir}/${dname}/mean_R2p.nii.gz -abs -div temp_DBV.nii.gz ${rdir}/${dname}/mean_OEF.nii.gz 
    rm temp_DBV.nii.gz 
else
    # if not, exit with an error
    echo "directory not found"
    exit 3
fi
