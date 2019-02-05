#!/bin/bash

# this script should take as an input the name of a folder containing results from fabber and
# create a new .nii.gz file which will be a map of OEF, caluclated by dividing the mean_R2p map
# by mean_DBV (multiplied by 301.74, which is dw given our other parameters)
#
# Matthew Cherukara, 3 October 2017

# directory of results
rdir=~/Documents/DPhil/Data/Fabber_Results
#rdir=~/Documents/DPhil/Data/Fabber_ModelFits

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

    # for the DBV file, first take the absolute value
    #                   then threshold all values above 1 to 1
    #                   then threshold all values below 0.01 to 0.01 (avoids singular problems)
    #                   then multiply by 301.74, and save to temporary file
    #fslmaths ${rdir}/${dname}/mean_DBV.nii.gz -mul 301.74 temp_DBV.nii.gz
    #fslmaths ${rdir}/${dname}/mean_DBV.nii.gz -abs -sub 1 -uthr 0 -add 0.99 -thr 0 -add 0.01 -mul 301.74 temp_DBV.nii.gz
    fslmaths ${rdir}/${dname}/mean_DBV.nii.gz -abs -sub 1 -uthr 0 -add 0.999 -thr 0 -add 0.001 -mul 301.74 temp_DBV.nii.gz

    # for the R2p file, first take the absolute value
    #                   then divide by the temporary DBV file, and save to OEF
    fslmaths ${rdir}/${dname}/mean_R2p.nii.gz -abs -div temp_DBV.nii.gz ${rdir}/${dname}/mean_OEF.nii.gz 

    # now generate a standard deviation map for OEF too, first by splitting up the MVN file
    fslsplit ${rdir}/${dname}/finalMVN temp_MVN_ -t 

    # assume that temp_MVN_0001 is the covariance of R2p and DBV (it should always be)
    fslmaths ${rdir}/${dname}/std_R2p -div ${rdir}/${dname}/mean_R2p -sqr temp_R2p_err
    fslmaths ${rdir}/${dname}/std_DBV -div ${rdir}/${dname}/mean_DBV -sqr temp_DBV_err
    fslmaths temp_MVN_0001 -div ${rdir}/${dname}/mean_R2p -div ${rdir}/${dname}/mean_DBV temp_cov
    fslmaths temp_R2p_err -add temp_DBV_err -sub temp_cov -sqrt -mul ${rdir}/${dname}/mean_OEF ${rdir}/${dname}/std_OEF

    # clear temp files
    rm temp_*.nii.gz
else
    # if not, exit with an error
    echo "directory not found"
    exit 3
fi
