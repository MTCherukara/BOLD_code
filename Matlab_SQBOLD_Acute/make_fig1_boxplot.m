%% Make boxplots (Figure 1 d-e)
save_fig = 1;
remove_outliers = 1;

% Load ROIs .mat
load_rois_voxelwise

%% R2'
figure(4),hold on
boxplot([r2p_core; r2p_growth; r2p_contra],...
        [ones(size(r2p_core)); ones(size(r2p_growth)).*2; ones(size(r2p_contra)).*3],...
        'Notch','on',...
        'Labels',{'Core' 'Growth' 'Contra'})

if remove_outliers
        h = findobj(gca,'tag','Outliers');
        delete(h)
        axis auto
end

xlabel('R_2'' [s{-1}]')
format_line_plot

% Save figure
if save_fig,
        print('figure_1d.png','-dpng','-r300');
end


%% DBV
figure(5),hold on
boxplot([dbv_core; dbv_growth; dbv_contra],...
        [ones(size(dbv_core)); ones(size(dbv_growth)).*2; ones(size(dbv_contra)).*3],...
        'Notch','on',...
        'Labels',{'Core' 'Growth' 'Contra'})

if remove_outliers
        h = findobj(gca,'tag','Outliers');
        delete(h)
        axis auto
end

xlabel('DBV [%]')
format_line_plot

% Save figure
if save_fig,
        print('figure_1e.png','-dpng','-r300');
end


%% dHb
figure(6),hold on
boxplot([dhb_core; dhb_growth; dhb_contra],...
        [ones(size(dhb_core)); ones(size(dhb_growth)).*2; ones(size(dhb_contra)).*3],...
        'Notch','on',...
        'Labels',{'Core' 'Growth' 'Contra'})

if remove_outliers
        h = findobj(gca,'tag','Outliers');
        delete(h)
        axis auto
end

xlabel('[dHb] [g.dl{-1}]')
format_line_plot

if save_fig,
        print('figure_1f.png','-dpng','-r300');
end

%% Statistical testing
% anovan
%{
[p_r2p,tbl_r2p,stats_r2p] = kruskalwallis([r2p_t1_core; r2p_t1_grth; r2p_t1_allC],[ones(size(r2p_t1_core));...
    ones(size(r2p_t1_grth)).*2; ones(size(r2p_t1_allC)).*3])
c = multcompare(stats_r2p)
[p_dbv,tbl_dbv,stats_dbv] = kruskalwallis([dbv_t1_core; dbv_t1_grth; dbv_t1_allC],[ones(size(dbv_t1_core));...
    ones(size(dbv_t1_grth)).*2; ones(size(dbv_t1_allC)).*3])
c = multcompare(stats_dbv)
[p_dhb,tbl_dhb,stats_dhb] = kruskalwallis([dhb_t1_core; dhb_t1_grth; dhb_t1_allC],[ones(size(dhb_t1_core));...
    ones(size(dhb_t1_grth)).*2; ones(size(dhb_t1_allC)).*3])
c = multcompare(stats_dhb)
%}

%cd(homedir)
