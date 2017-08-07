%% Make barcharts (Figure 2 a-c)
save_fig = 1;

% Load ROIs .mat
load_rois_subjectwise

% Calculate Summary
r2p = [ r2p_core(:,1), r2p_growth(:,1), r2p_contra(:,1) ];
dbv = [ dbv_core(:,1), dbv_growth(:,1), dbv_contra(:,1) ]*100;
dhb = [ dhb_core(:,1), dhb_growth(:,1), dhb_contra(:,1) ];

% Plot figures

% R2'
figure(7), xlabel('R_2'''), hold on
%bar(mean(r2p)), errorbar(1:3,mean(r2p),zeros(size(mean(r2p))),std(r2p),'.k')
mean_r2p = mean(r2p);
bar(1,mean_r2p(1),'b'), hold on,
bar(2,mean_r2p(2),'r')
bar(3,mean_r2p(3),'g')
errorbar(1:3,mean(r2p),zeros(size(mean_r2p)),std(r2p),'.k')
set(gca,'Xtick',1:3,'XTickLabel',{'Core' 'Growth' 'Contra'})
ylabel('[s^{-1}]')
if save_fig,
        print('figure_2a.png','-dpng','-r300');
end

% DBV
figure(8), xlabel('DBV'), hold on
mean_dbv = mean(dbv);
bar(1,mean_dbv(1),'b'), hold on,
bar(2,mean_dbv(2),'r')
bar(3,mean_dbv(3),'g')
errorbar(1:3,mean(dbv),zeros(size(mean(dbv))),std(dbv),'.k')
set(gca,'Xtick',1:3,'XTickLabel',{'Core' 'Growth' 'Contra'})
ylabel('[%]')
if save_fig,
        print('figure_2b.png','-dpng','-r300');
end

% [dHb]
figure(9), xlabel('[dHb]'), hold on
mean_dhb = mean(dhb);
bar(1,mean_dhb(1),'b'), hold on,
bar(2,mean_dhb(2),'r')
bar(3,mean_dhb(3),'g')
errorbar(1:3,mean(dhb),zeros(size(mean(dhb))),std(dhb),'.k')
set(gca,'Xtick',1:3,'XTickLabel',{'Core' 'Growth' 'Contra'})
ylabel('[g.dl^{-1}]')
if save_fig,
        print('figure_2c.png','-dpng','-r300');
end
