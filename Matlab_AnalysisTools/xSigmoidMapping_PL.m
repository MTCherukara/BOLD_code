% xSigmoidMapping_PL.m
%
% Version of xSigmoidMapping.m designed to be used with pre-loaded data.
%
% Testing out the idea of taking measurements of R2' and DBV, and then mapping
% their ratio to values of OEF (probably using a sigmoid function). Script
% outline derived from Figure_R2pScatter.m
%
% MT Cherukara
% 16 April 2019
%
% Actively used as of 2019-04-16
%
% CHANGELOG:
%
% 2019-04-20 (MTC). 


clear;
close all;
setFigureDefaults;

% choose first dataset (assuming there are 5 after it)
set1 = 536;

% number of DBV values
nd = 5;

%% Load Data

% Ground truth
% OEFvals = linspace(0.21,0.70,no);
OEFvals = 0.01:0.01:1;
DBVvals = 0.01:0.02:0.09;

no = length(OEFvals);
mo = max(OEFvals);

% find file name
datadir = '../../Data/Fabber_ModelFits/';
pl_num  = strcat(datadir,'*',num2str(set1),'*');
pl_name = dir(pl_num);

% Load the Data
pl_data = load(strcat(datadir,pl_name.name));

% Pull out data:
estDBV = pl_data.estDBV;
estR2p = pl_data.estR2p;
estOEF = estR2p./estDBV;


%% Plotting

% % Plot estimates-to-truth
% figure; box on; hold on; axis square;
% for ff = 1:nd
%     scatter(estOEF(ff,:),100*OEFvals,[],'filled');
% %     plot(estOEF(ff,:),yy(ff,:),'--','Color',defColour(ff));
% end
% 
% legend('DBV = 1%','DBV = 3%','DBV = 5%','DBV = 7%','DBV = 9%','Location','NorthWest')
% xlabel('Ratio R2'' / DBV');
% ylabel('Simulated OEF (%)');
% ylim([0,100*mo]);


%% Plotting R2' esimates only
trueOEF = repmat(OEFvals,nd,1);
trueDBV = repmat([0.01:0.02:0.09]',1,no);

evns = 1:2:no;

trueR2p = 355.*trueOEF.*trueDBV;
mR = max(trueR2p(:));

figure; box on; hold on; axis square;
for ff = 1:nd
    scatter(trueR2p(ff,:),estR2p(ff,:),20,'filled');
end

% plot unity line
plot([0,mR],[0,mR],'k-','LineWidth',1);

legend('DBV = 1%','DBV = 3%','DBV = 5%','DBV = 7%','DBV = 9%','Location','NorthWest')
xlabel('True R2''');
ylabel('Estimated R2''');
axis([0,mR,0,mR]);


%% Plotting original OEF estimates

figure; box on; hold on; axis square;
for ff = 1:nd
    scatter(trueOEF(ff,:),estOEF(ff,:)./345,20,'filled');
end

% plot unity line
plot([0,mo],[0,mo],'k-','LineWidth',1);

legend('DBV = 1%','DBV = 3%','DBV = 5%','DBV = 7%','DBV = 9%','Location','NorthWest')
xlabel('True OEF');
ylabel('Estimated OEF');
axis([0,mo,0,mo]);


%% Plotting corrected OEF estimates

modOEF = 0.106.*tan(0.0138*estR2p./estDBV);

figure; box on; hold on; axis square;
for ff = 1:nd
    scatter(trueOEF(ff,:),modOEF(ff,:),20,'filled');
end

% plot unity line
plot([0,mo],[0,mo],'k-','LineWidth',1);

legend('DBV = 1%','DBV = 3%','DBV = 5%','DBV = 7%','DBV = 9%','Location','NorthWest')
xlabel('True OEF');
ylabel('Estimated OEF');
axis([0,mo,0,mo]);