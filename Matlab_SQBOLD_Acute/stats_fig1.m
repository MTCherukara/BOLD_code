%% Statistical testing Figure 1

% Load ROIs .mat
load_rois_voxelwise

% R2'
fprintf('Displaying Voxel-wise Statistics for R2''\n')
[p_r2p, tbl_r2p, stats_r2p] = kruskalwallis(...
        [r2p_core; r2p_growth; r2p_contra], ...
        [ones(size(r2p_core)); ones(size(r2p_growth)).*2; ones(size(r2p_contra)).*3])

c_r2p = multcompare(stats_r2p)

% DBV
fprintf('\n\n\n\n\n Displaying Voxel-wise Statistics for DBV \n')
[p_dbv, tbl_dbv, stats_dbv] = kruskalwallis(...
        [dbv_core; dbv_growth; dbv_contra], ...
        [ones(size(dbv_core)); ones(size(dbv_growth)).*2; ones(size(dbv_contra)).*3])

c_dbv = multcompare(stats_dbv)

% dHb
fprintf('\n\n\n\n\n Displaying Voxel-wise Statistics for [dHb] \n')
[p_dhb, tbl_dhb, stats_dhb] = kruskalwallis(...
        [dhb_core; dhb_growth; dhb_contra], ...
        [ones(size(dhb_core)); ones(size(dhb_growth)).*2; ones(size(dhb_contra)).*3])

c_dhb = multcompare(stats_dhb)
