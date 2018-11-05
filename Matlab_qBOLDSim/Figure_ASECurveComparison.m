% Figure_ASECurveComparison.m
%
% Plot a figure (for ISMRM 2019 abstract) showing a comparison of different ASE
% curves, from in vivo data, the SDR qBOLD model, and the Sharan distribution

clear;
close all;

setFigureDefaults;

% load in and slightly curate some data
load('../../Data/vesselsim_data/vs_arrays/TE84_vsData_sharan_100.mat');
load('ASE_Data/Subject_11_FLAIR_ASE_Mean.mat');

S_sharan = squeeze(S0(52,67,:))';

% Create SDR-ASE data
param = genParams('incIV',false,'incT2',false,...
                  'Model','Full','TE',TE,...
                  'OEF',0.20,'DBV',0.05);
              
% Make the data 
tmod = linspace(-16,64)./1000;
S_model = qASE_model(tmod,TE,param);
S_model = S_model./max(S_model);

% Plot them all together
figure; hold on; box on;
p1 = plot(1000*tmod,log(S_model),'-','LineWidth',3);
p2 = plot(1000*tau ,log(S_sharan),'--','LineWidth',3);
% p3 = plot(1000*taus,log(Sig_meanN),'ko','MarkerSize',10,'LineWidth',2);

% legend([p3,p1,p2],'in vivo data','SDR-qBOLD Model','Simulated Data','Location','SouthWest');
legend([p1,p2],'SDR-qBOLD Model (OEF = 20%)','Simulated Data (OEF = 40%)','Location','SouthWest');
set(gca,'FontSize',20);

xlim([-16,64]);
ylim([-0.45,0.01]);

xlabel('Spin Echo Displacement \tau (ms)');
ylabel('Log (Signal)');
