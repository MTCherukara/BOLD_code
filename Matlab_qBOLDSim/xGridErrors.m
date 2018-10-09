% xGridErrors

% Make some RMSE plots for different qBOLD models, based on Fig. 4 in Griffeth &
% Buxton, 2011.

% MT Cherukara
% 2018-10-01

clear;
setFigureDefaults;

% Load in two datasets
load('../../Data/vesselsim_data/simulated_data/ASE_SurfData_OEFModel.mat');
S1 = S0;
p1 = par1;
p2 = par2;

load('../../Data/vesselsim_data/vs_arrays/vsData_sharan_10.mat');
S2 = S0;

% Calculate RMSE
rmse = sqrt(mean((S1 - S0).^2,3));


%% Plotting
% % Plot a figure
% figure; hold on; box on;
% 
% % Plot 2D grid search results
% surf(p2,p1,(rmse));
% view(2); shading flat;
% c=colorbar;
% 
% axis([min(p2),max(p2),min(p1),max(p1)]);
% xlabel('DBV (%)');
% xticks(0.01:0.01:0.07);
% xticklabels({'1','2','3','4','5','6','7'});
% ylabel('OEF (%)');
% yticks(0.2:0.1:0.6);
% yticklabels({'20','30','40','50','60'})
% title('RMS Difference in Signal Magnitude');


%% Compare Models

figure;

pickOEF = 34;
pickDBV = 34;

plot(1000*tau,squeeze(S1(pickDBV,pickOEF,:)));
hold on; grid on; axis square;
plot(1000*tau,squeeze(S0(pickDBV,pickOEF,:)));

axis([-28,64,0.8,1.02]);

xlabel('Spin Echo Displacement \tau');
ylabel('Signal (a.u.)');
title(['OEF = ',num2str(OEFvals(pickOEF)),', DBV = ',num2str(DBVvals(pickDBV))]);
legend('Static Dephasing Model','Frechet Distribution','Location','SouthWest');
