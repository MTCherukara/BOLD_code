#!/bin/csh

set patient_id = ( 'p01' 'p02' 'p03' 'p04' 'p05' 'p06' 'p07' 'p08' 'p09' )
set scan_id = ( '093' '095' '099' '100' '101' '104' '107' '108' '109' )

set viewer = 1 # view ROIs overlayed on Spin Echo

# loop through patients
set count = 3
#while ( $count <= $#scan_id )
while ( $count <= 9 )

        # make directories
        mkdir $patient_id[$count]/sess-0hrs/analysis

        # make ROIs
        foreach mask_id ( core growth contra )
                foreach pmap_id ( r2p dbv dhb )
                	fslmaths $patient_id[$count]/sess-0hrs/pmap/$patient_id[$count]_sess-0hrs_$pmap_id.nii.gz -mul \
                                $patient_id[$count]/sess-0hrs/roi/$patient_id[$count]_sess-0hrs_$mask_id.nii.gz \
                                $patient_id[$count]/sess-0hrs/analysis/$patient_id[$count]_sess-0hrs_${pmap_id}_$mask_id.nii.gz
                end
        end

        if ($viewer == 1) then

                fslview $patient_id[$count]/sess-0hrs/pmap/$patient_id[$count]_sess-0hrs_spin_echo.nii.gz \
                        $patient_id[$count]/sess-0hrs/roi/$patient_id[$count]_sess-0hrs_core.nii.gz -l Red\
                        $patient_id[$count]/sess-0hrs/roi/$patient_id[$count]_sess-0hrs_growth.nii.gz -l Blue\
                        $patient_id[$count]/sess-0hrs/roi/$patient_id[$count]_sess-0hrs_contra.nii.gz -l Green
                endif

        @ count ++

end
