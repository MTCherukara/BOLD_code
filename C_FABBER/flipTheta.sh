#!/bin/bash

# this script should take as an input the name of a folder containing results from a FABBER fit of
# a biexponential T2 model, with a file called mean_theta.nii.gz (the ratio of the 2 compartments)
# and create a map of 1-theta (called mean_itheta.nii.gz), in the case where the original theta
# shows the non-CSF compartment (which will happen by chance around half of the time, I guess).
#
# Matthew Cherukara, 26 October 2017

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

    # first, parse the logfile to find the MASK used
    

    # for the DBV file, first take the absolute value
    #                   then threshold all values above 1 to 1
    #                   then threshold all values below 0.01 to 0.01 (avoids singular problems)
    #                   then multiply by 301.74, and save to temporary file
    fslmaths ${rdir}/${dname}/mean_DBV.nii.gz -abs -sub 1 -uthr 0 -add 0.99 -thr 0 -add 0.01 -mul 301.74 temp_DBV.nii.gz

    # for the R2p file, first take the absolute value
    #                   then divide by the temporary DBV file, and save to OEF
    fslmaths ${rdir}/${dname}/mean_R2p.nii.gz -abs -div temp_DBV.nii.gz ${rdir}/${dname}/mean_OEF.nii.gz 
    rm temp_DBV.nii.gz 
else
    # if not, exit with an error
    echo "directory not found"
    exit 3
fi
