% Figure_ASECurveComparison.m
%
% Plot a figure (for ISMRM 2019 abstract) showing a comparison of different ASE
% curves, from in vivo data, the SDR qBOLD model, and the Sharan distribution

clear;
% close all;

setFigureDefaults;

% load in and slightly curate some data
load('../../Data/vesselsim_data/vs_arrays/TE84_vsData_sharan_50.mat');
load('ASE_Data/Subject_11_FLAIR_ASE_Mean.mat');

% set spin echno signal to 1
Sig_meanN(3) = 1;
Sig_medN(3) = 1;

S_sharan = squeeze(S0(14,20,:))';

% Create SDR-ASE data
param = genParams('incIV',true,'incT2',true,...
                  'Model','Full','TE',TE,...
                  'OEF',0.40,'DBV',0.042);
              
% Make the data 
tmod = linspace(-16,64)./1000;
S_model = qASE_model(tmod,TE,param);
S_model = S_model./max(S_model);

% Plot them all together
figure; hold on; box on;
p1 = plot(1000*tmod,log(S_model),'-','LineWidth',2);
p2 = plot(1000*tau(1:4:end) ,log(S_sharan(1:4:end)),'--','LineWidth',2);
p3 = plot(1000*taus,log(Sig_medN),'ko','MarkerSize',9,'LineWidth',2);

legend([p3,p1,p2],'in vivo Data','SDR-qBOLD Model','Simulated Data','Location','SouthWest');
% legend([p3,p1],'in vivo data','SDR-qBOLD Model','Location','SouthWest');
% legend([p1,p2],'SDR-qBOLD Model (OEF = 20%)','Simulated Data (OEF = 40%)','Location','SouthWest');
% set(gca,'FontSize',14);

xlim([-16,64]);
ylim([-0.4,0.025]);
yticks([0]);
yticklabels({'S_0'});

xlabel('Spin Echo Displacement \tau (ms)');
ylabel('Log (Signal)');
