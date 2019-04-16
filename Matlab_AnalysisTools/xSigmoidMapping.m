% xSigmoidMapping.m
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


clear;
close all;
setFigureDefaults;

% choose first dataset (assuming there are 5 after it)
set1 = 521;

% define the five datasets we want
sets = set1:set1+4;


%% Find directories, and load ground truth data and stuff
% Data directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_ModelFits/';

% number of OEF points
no = 100;

% Ground truth
% OEFvals = linspace(0.21,0.70,no);
OEFvals = linspace(0.01,1,no);
DBVvals = 0.01:0.02:0.09;


% Pre-allocate
estR2p = zeros(length(sets),no);
estDBV = zeros(length(sets),no);
estOEF = zeros(length(sets),no);


%% Loop through Datasets
for ss = 1:length(sets)
    
    % Figure out the results directory we want to load from
    fdname = dir([resdir,'fabber_',num2str(sets(ss)),'_*']);
    fabdir = strcat(resdir,fdname.name,'/');
    
    % Load the data
    volR = LoadSlice([fabdir,'mean_R2p.nii.gz'],1);
    volV = LoadSlice([fabdir,'mean_DBV.nii.gz'],1);

    % Average
    vecR = mean(volR,1);
    vecV = mean(volV,1);
        
    % Calculate Ratio
    vecOEF = vecR./vecV;
    
    % Store Results
    estR2p(ss,:) = vecR;
    estDBV(ss,:) = vecV;
    estOEF(ss,:) = vecOEF;
   
end % for setnum = ....
   


%% Plotting

% % Plot Ratio
% figure; box on; hold on; axis square;
% for ff = 1:length(sets)   
%     scatter(100*OEFvals,estOEF(ff,:),[],'filled');
% end
% 
% legend('DBV = 1%','DBV = 3%','DBV = 5%','DBV = 7%','DBV = 9%','Location','NorthWest')
% ylabel('Ratio R2'' / DBV');
% xlabel('Simulated OEF (%)');
% xlim([0,100]);

% Plot the other way around
figure; box on; hold on; axis square;
for ff = 1:length(sets)   
    scatter(estOEF(ff,:),100*OEFvals,[],'filled');
end

legend('DBV = 1%','DBV = 3%','DBV = 5%','DBV = 7%','DBV = 9%','Location','NorthWest')
xlabel('Ratio R2'' / DBV');
ylabel('Simulated OEF (%)');
ylim([0,100]);