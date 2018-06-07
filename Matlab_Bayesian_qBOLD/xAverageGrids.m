% xAverageGrids.m

clear;

setFigureDefaults;

sn = 1;         % set number
gs = 1000;      % grid size
ng = 5;         % number of grids

% pre-allocate array
Postr = zeros(gs,gs,ng);

% fill array
for ii = 1:ng
    
    load(strcat('Post_Set',num2str(sn),'_',num2str(ii),'.mat'));
    Postr(:,:,ii) = pos;
    
end

% average and take the exponent
Posterior = exp(mean(Postr,3));

% plot figure;
figure; hold on; box on;
surf(vals(2,:),vals(1,:),Posterior);
view(2);
shading flat;
colormap(flipud(magma));
c=colorbar;

% set axes
axis([min(vals(2,:)),max(vals(2,:)),min(vals(1,:)),max(vals(1,:))]);

% label axes
ylabel('R_2'' (s^-^1)')
xlabel('DBV (%)');
xticklabels({'1','2','3','4','5','6','7'})

% plot true values
plot3([trv(2),trv(2)],[  0, 1000],[1e20,1e20],'k-');
plot3([  0, 1000],[trv(1),trv(1)],[1e20,1e20],'k-');

% plot outline
plot3([vals(2,  1),vals(2,  1)],[vals(1,  1),vals(1,end)],[1,1],'k-','LineWidth',0.75);
plot3([vals(2,end),vals(2,end)],[vals(1,  1),vals(1,end)],[1,1],'k-','LineWidth',0.75);
plot3([vals(2,  1),vals(2,end)],[vals(1,  1),vals(1,  1)],[1,1],'k-','LineWidth',0.75);
plot3([vals(2,  1),vals(2,end)],[vals(1,end),vals(1,end)],[1,1],'k-','LineWidth',0.75);

% save stuff out
save(['Posterior_Set_',num2str(sn)],'Posterior','vals','trv');