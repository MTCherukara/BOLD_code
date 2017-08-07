%% Statistical testing Figure 2

% Load ROIs .mat
load_rois_subjectwise

%% ANOVA-N

% R2'
fprintf('Displaying Patient-wise Statistics (ANOVA-N) for R2''\n')
[p_r2p, tbl_r2p, stats_r2p] = anovan(...
        [r2p_core(:,1); r2p_growth(:,1); r2p_contra(:,1)], ...
        [ones(size(r2p_core(:,1))); ones(size(r2p_growth(:,1))).*2; ones(size(r2p_contra(:,1))).*3]);

p_r2p

c_anovan_r2p = multcompare(stats_r2p);

% DBV
fprintf('\n\n\n\n\n Displaying Patient-wise Statistics (ANOVA-N) for DBV \n')
[p_dbv, tbl_dbv, stats_dbv] = anovan(...
        [dbv_core(:,1); dbv_growth(:,1); dbv_contra(:,1)], ...
        [ones(size(dbv_core(:,1))); ones(size(dbv_growth(:,1))).*2; ones(size(dbv_contra(:,1))).*3]);

p_dbv

c_anovan_dbv = multcompare(stats_dbv);

% dHb
fprintf('\n\n\n\n\n Displaying Patient-wise Statistics (ANOVA-N) for [dHb] \n')
[p_dhb, tbl_dhb, stats_dhb] = anovan(...
        [dhb_core(:,1); dhb_growth(:,1); dhb_contra(:,1)], ...
        [ones(size(dhb_core(:,1))); ones(size(dhb_growth(:,1))).*2; ones(size(dhb_contra(:,1))).*3]);

p_dhb

c_anovan_dhb = multcompare(stats_dhb);


%% Kruskal-Wallis

% R2'
fprintf('\n\n\n\n\n Displaying Patient-wise Statistics (Kruskal-Wallis) for R2''\n')
[p_r2p, tbl_r2p, stats_r2p] = kruskalwallis(...
        [r2p_core(:,1); r2p_growth(:,1); r2p_contra(:,1)], ...
        [ones(size(r2p_core(:,1))); ones(size(r2p_growth(:,1))).*2; ones(size(r2p_contra(:,1))).*3]);

p_r2p

c_kwallis_r2p = multcompare(stats_r2p);

% DBV
fprintf('\n\n\n\n\n Displaying Patient-wise Statistics (Kruskal-Wallis) for DBV \n')
[p_dbv, tbl_dbv, stats_dbv] = kruskalwallis(...
        [dbv_core(:,1); dbv_growth(:,1); dbv_contra(:,1)], ...
        [ones(size(dbv_core(:,1))); ones(size(dbv_growth(:,1))).*2; ones(size(dbv_contra(:,1))).*3]);

p_dbv

c_kwallis_dbv = multcompare(stats_dbv);

% dHb
fprintf('\n\n\n\n\n Displaying Patient-wise Statistics (Kruskal-Wallis) for dHb \n')
[p_dhb, tbl_dhb, stats_dhb] = kruskalwallis(...
        [dhb_core(:,1); dhb_growth(:,1); dhb_contra(:,1)], ...
        [ones(size(dhb_core(:,1))); ones(size(dhb_growth(:,1))).*2; ones(size(dhb_contra(:,1))).*3]);

p_dhb

c_kwallis_dhb = multcompare(stats_dhb);
