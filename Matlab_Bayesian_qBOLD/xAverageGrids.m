% xAverageGrids.m

clear;

setFigureDefaults;

ng = 5;         % number of grids

% pre-allocate array
Postr = zeros(500,1000,ng);

% fill array
for ii = 1:ng
    
    load(strcat('~/Documents/DPhil/Data/GridSearches/BesselGrid_TauSet3_',num2str(ii),'.mat'));
    Postr(:,:,ii) = pos;
    
end

% set out true values
trv = [params.R2p, params.zeta];

% create values vectors
np1 = size(pos,1);
np2 = size(pos,2);

pv1 = linspace(interv(1,1),interv(1,2),np1);
pv2 = linspace(interv(2,1),interv(2,2),np2);


% average and take the exponent
Posterior = exp(mean(Postr,3));

% plot figure;
figure; hold on; box on;
surf(pv2,pv1,Posterior);
view(2);
shading flat;
colormap(flipud(magma));
c=colorbar;

% set axes
xlim(interv(2,:));
ylim([2.5,6.5]);

% label axes
ylabel('R_2'' (s^-^1)')
xlabel('DBV (%)');
xticklabels({'1','2','3','4','5','6','7'})

% plot true values
plot3([trv(2),trv(2)],[  0, 1000],[1e20,1e20],'k-');
plot3([  0, 1000],[trv(1),trv(1)],[1e20,1e20],'k-');

