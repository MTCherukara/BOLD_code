
% Subject List
patient_list = { 'p01' 'p02' 'p03' 'p04' 'p05' 'p06' 'p07' 'p08' 'p09' };

for patient_id = 3:length(patient_list)

        % R2'
        r2p_core    = read_avw(sprintf('%s/sess-0hrs/analysis/%s_sess-0hrs_r2p_core.nii.gz', patient_list{patient_id}, patient_list{patient_id}));
        r2p_growth  = read_avw(sprintf('%s/sess-0hrs/analysis/%s_sess-0hrs_r2p_growth.nii.gz', patient_list{patient_id}, patient_list{patient_id}));
        r2p_contra  = read_avw(sprintf('%s/sess-0hrs/analysis/%s_sess-0hrs_r2p_contra.nii.gz', patient_list{patient_id}, patient_list{patient_id}));

        % DBV
        dbv_core    = read_avw(sprintf('%s/sess-0hrs/analysis/%s_sess-0hrs_dbv_core.nii.gz', patient_list{patient_id}, patient_list{patient_id}));
        dbv_growth  = read_avw(sprintf('%s/sess-0hrs/analysis/%s_sess-0hrs_dbv_growth.nii.gz', patient_list{patient_id}, patient_list{patient_id}));
        dbv_contra  = read_avw(sprintf('%s/sess-0hrs/analysis/%s_sess-0hrs_dbv_contra.nii.gz', patient_list{patient_id}, patient_list{patient_id}));

        % dHb
        dhb_core    = read_avw(sprintf('%s/sess-0hrs/analysis/%s_sess-0hrs_dhb_core.nii.gz', patient_list{patient_id}, patient_list{patient_id}));
        dhb_growth  = read_avw(sprintf('%s/sess-0hrs/analysis/%s_sess-0hrs_dhb_growth.nii.gz', patient_list{patient_id}, patient_list{patient_id}));
        dhb_contra  = read_avw(sprintf('%s/sess-0hrs/analysis/%s_sess-0hrs_dhb_contra.nii.gz', patient_list{patient_id}, patient_list{patient_id}));

        save(sprintf('%s/sess-0hrs/analysis/%s.mat',patient_list{patient_id}, patient_list{patient_id}))

        clear r2p_core r2p_growth r2p_contra dbv_core dbv_growth dbv_contra dhb_core dhb_growth dhb_contra

end
