#!/bin/bash

# this script should, for a given set of fabber results, create absolutize the residuals.nii.gz
#
# Matthew Cherukara, 4 October 2017

# directory of results
rdir=~/Documents/DPhil/Data/Fabber_Results

# find the name of the directory that has the specified number, if no input is specified, use the
# default-created directory "+" 
if [[ $# -eq 0 ]] ; then
    dname="+"
else
    dname=$(ls ${rdir} | grep "_$1_")
fi

# check if a set of fabber results of that number exists
if [[ -d "${rdir}/${dname}" ]] ; then
    # if it does, carry out the calculation

    fslmaths ${rdir}/${dname}/residuals.nii.gz -abs ${rdir}/${dname}/residuals_abs.nii.gz
else
    # if not, exit with an error
    echo "directory not found"
    exit 3
fi
