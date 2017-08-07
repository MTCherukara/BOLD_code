%% Make histograms (Figure 1 a-c)
save_fig = 1;

% Load ROIs
load_rois_voxelwise

%% R2'
r2p_lims = [-5.5 15.5 50];
[n_r2p_core,   x_r2p_core]   = hist(r2p_core,  linspace(r2p_lims(1),r2p_lims(2),r2p_lims(3)));
[n_r2p_growth, x_r2p_growth] = hist(r2p_growth,linspace(r2p_lims(1),r2p_lims(2),r2p_lims(3)));
[n_r2p_contra, x_r2p_contra] = hist(r2p_contra,linspace(r2p_lims(1),r2p_lims(2),r2p_lims(3)));

% Plot and format figure
figure(1), hold on
h = plot(x_r2p_contra,n_r2p_contra,'g'); hold on,
h = plot(x_r2p_growth,n_r2p_growth,'r');
h = plot(x_r2p_core,n_r2p_core,'b');
xlim([r2p_lims(1)+0.5 r2p_lims(2)-0.5])
ylim([0 400])

hlegend = legend({'Core' 'Growth' 'Contra'});
grid on
box on
xlabel('R_2'' [s^{-1}]')

format_line_plot

% Save figure
if save_fig,
        print('figure_1a.png','-dpng','-r300');
end


%% DBV
dbv_lims = [-0.21 0.51 35];
[n_dbv_core,   x_dbv_core]   = hist(dbv_core,  linspace(dbv_lims(1),dbv_lims(2),dbv_lims(3)));
[n_dbv_growth, x_dbv_growth] = hist(dbv_growth,linspace(dbv_lims(1),dbv_lims(2),dbv_lims(3)));
[n_dbv_contra, x_dbv_contra] = hist(dbv_contra,linspace(dbv_lims(1),dbv_lims(2),dbv_lims(3)));

% Plot and format figure
figure(2), hold on
h = plot(x_dbv_contra,n_dbv_contra,'g'); hold on,
h = plot(x_dbv_growth,n_dbv_growth,'r');
h = plot(x_dbv_core,n_dbv_core,'b');
xlim([dbv_lims(1)+0.1 dbv_lims(2)-0.1])
ylim([0 700])

hlegend = legend({'Core' 'Growth' 'Contra'});
grid on
box on
xlabel('DBV [%]')

format_line_plot

% Save figure
if save_fig,
        print('figure_1b.png','-dpng','-r300');
end


%% dHb
dhb_lims = [-4.1 10.1 50];
[n_dhb_core, x_dhb_core]     = hist(dhb_core,  linspace(dhb_lims(1),dhb_lims(2),dhb_lims(3)));
[n_dhb_growth, x_dhb_growth] = hist(dhb_growth,linspace(dhb_lims(1),dhb_lims(2),dhb_lims(3)));
[n_dhb_contra, x_dhb_contra] = hist(dhb_contra,  linspace(dhb_lims(1),dhb_lims(2),dhb_lims(3)));

% Plot and format figures
figure(3), hold on
h = plot(x_dhb_contra,n_dhb_contra,'g'); hold on,
h = plot(x_dhb_growth,n_dhb_growth,'r');
h = plot(x_dhb_core,n_dhb_core,'b');
xlim([dhb_lims(1)+0.5 dhb_lims(2)-0.5])
ylim([0 350])

hlegend = legend({'Core' 'Growth' 'Contra'});
grid on
box on
xlabel('[dHb] [g.dl{-1}]')

format_line_plot

% Save figure
if save_fig,
        print('figure_1c.png','-dpng','-r300');
end
