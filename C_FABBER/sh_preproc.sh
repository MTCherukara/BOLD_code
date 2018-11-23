#!/bin/bash
# ASE analysis pre-processing steps

# If only one input is given, do the ASE processing stuff
if [[ $# -eq 0 ]] ; then
    echo " "
    echo "Usage: preproc.sh <ASE_input> [anatomical_input]"
    echo "Must target slice-averaged ASE nifti, and be called from correct directory"
    exit 3
else
    # pull out name of nifti
    fin=$1

    # if the user has added .nii.gz on the end, cut it out
    fin=${fin%.n*}

    # temporary directory
    TDIR=killme.preproc

    # check whether the nifti of that name actually exists in the current directory
    if [ -f "${fin}.nii.gz" ] ; then
        echo " "
        echo "Pre-processing ASE data ${fin}.nii.gz"

        echo "  Correcting motion..."
        # Motion correction
        mcflirt -in ${fin} -out "${fin}_mc" -refvol 6

        # Extract spin-echo
        mkdir ${TDIR}
        fslsplit "${fin}_mc" "${TDIR}/vol_" -t 
        mv "${TDIR}/vol_0007.nii.gz" "${fin}_SE.nii.gz"

        echo "  Masking..."
        # Calculate brain mask from SE
        bet "${fin}_SE" killme.brain -m 
        mv killme.brain_mask.nii.gz "${fin}_mask.nii.gz"
        rm killme.brain*
        
        # see if there's another input, then do T1w processing
        if [[ $# -eq 2 ]] ; then
            # pull out name of anatomical
            ain=$2
            ain=${ain%.n*}

            if [ -f "${ain}.nii.gz" ] ; then
                echo "Pre-processing anatomical data ${ain}.nii.gz"

                echo "  Calculating transformation matrix..."
                # generate transformation matrix from Anatomical to ASE
                MTX=tx_high_to_low.mat
                flirt -in "${ain}" -ref "${fin}_SE" -out "killme.ttx" -omat "${MTX}"

                echo "  Segmenting..."
                # brain extract and segment Anatomical image
                bet "${ain}" "${ain}_brain"
                fast "${ain}_brain"

                echo "  Generating masks..."
                # transform CSF partial volume map into ASE space
                applywarp --in="${ain}_brain_pve_0" --ref="${fin}_SE" --out=killme.csf \
                        --premat="${MTX}" --interp=trilinear --super --superlevel=4
                
                # transform GM partial volume map into ASE space
                applywarp --in="${ain}_brain_pve_1" --ref="${fin}_SE" --out=killme.gm \
                        --premat="${MTX}" --interp=trilinear --super --superlevel=4
                
                # Generate binary 60% GM mask in ASE space
                fslmaths killme.gm -thr 0.6 -sub 1 -uthr -0.4 -add 1 mask_gm_60

                # Generate binary non-40%-CSF mask in ASE space
                fslmaths killme.csf -thr 0.4 -sub 1 -uthr -0.6 -add 1 killme.csf
                fslmaths "${fin}_mask" -sub killme.csf -thr 0 mask_ncsf_40

                # Cleanup
                rm killme.* ${ain}_brain_*

            else 
                echo "Anatomical data ${ain}.nii.gz not found"
                exit 3
            fi 
        fi
    echo "  Cleaning up..."
    # Cleanup
    rm -r ${TDIR} 
    else
        echo "ASE data ${fin}.nii.gz not found"
        exit 3
    fi 
    echo "...Done!"
fi 

