% xGridErrors

% Make some RMSE plots for different qBOLD models, based on Fig. 4 in Griffeth &
% Buxton, 2011.

% MT Cherukara
% 2018-10-01

clear;


% Load in two datasets
load('../../Data/ASE_SurfData_OEFModel');
S1 = S0;
p1 = par1;
p2 = par2;

load('../../Data/ASE_SurfData_DHBModel');
S2 = S0;

% Calculate RMSE
rmse = sqrt(mean((S1 - S0).^2,3));

%Plot a figure
figure; hold on; box on;

% Plot 2D grid search results
surf(p2,p1,(rmse));
view(2); shading flat;
c=colorbar;

axis([min(p2),max(p2),min(p1),max(p1)]);
xlabel('DBV (%)');
xticklabels({'1','2','3','4','5','6','7'});
ylabel('OEF (%)');
yticks([0.2,0.3,0.4,0.5,0.6]);
yticklabels({'20','30','40','50','60'})
