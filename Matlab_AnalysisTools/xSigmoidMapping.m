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

plot_orig = 0;      % for plotting the tan shape
plot_rand = 1;      % for random plots

% choose first dataset (assuming there are 5 after it)
set1 = 521;

kappa = .47;

% define the five datasets we want
sets = set1:set1+4;
% sets = [563,538];

%% Find directories, and load ground truth data and stuff
% Data directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_ModelFits/';

% Ground truth
% OEFvals = linspace(0.21,0.70,no);
OEFvals = 0.01:0.01:1;
DBVvals = 0.01:0.02:0.09;
% DBVvals = [0.05,0.05];

no = length(OEFvals);
nd = length(sets);
mo = 0.8*max(OEFvals);

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
    estR2p(ss,:) = vecR(1:no);
    estDBV(ss,:) = vecV(1:no);
    estOEF(ss,:) = vecOEF(1:no);
   
end % for setnum = ....
   
% sname = strcat('Fabber_Results_',num2str(set1),'.mat');
% save(sname,'estR2p','estDBV');


%% Plotting original

% Plot the other way around
if plot_orig

    figure; box on; hold on; axis square; grid on;
    for ff = 1:length(sets)   
        scatter(estOEF(ff,:),100*OEFvals,[],'filled');
    %     plot(estOEF(ff,:),yy(ff,:),'--','Color',defColour(ff));
    end

    legend('DBV = 1%','DBV = 3%','DBV = 5%','DBV = 7%','DBV = 9%','Location','NorthWest')
    xlabel('Ratio R2'' / DBV');
    ylabel('Simulated OEF (%)');
    ylim([0,100*max(OEFvals)]);
end



if plot_rand
    %% Plotting R2' esimates only
    trueOEF = repmat(OEFvals,nd,1);
    trueDBV = repmat(DBVvals',1,no);

    evns = 1:1:no;

    trueR2p = 355.*trueOEF.*trueDBV;
    mR = 0.6*max(trueR2p(:));

    figure; box on; hold on; axis square; grid on;
    for ff = 1:nd
        scatter(trueR2p(ff,evns),estR2p(ff,evns),[],'filled');
    end

    % plot unity line
    plot([0,mR],[0,mR],'k-','LineWidth',1);

    % legend('DBV = 1%','DBV = 3%','DBV = 5%','DBV = 7%','DBV = 9%','Location','NorthWest')
    xlabel('True R2''');
    ylabel('Estimated R2''');
    axis([0,mR,0,mR]);


    %% Plotting original OEF estimates

    figure; box on; hold on; axis square; grid on;
    for ff = 1:nd
        scatter(trueOEF(ff,:),kappa*estOEF(ff,:)./355,[],'filled');
    end

    % plot unity line
    plot([0,mo],[0,mo],'k-','LineWidth',1);

    legend('DBV = 1%','DBV = 3%','DBV = 5%','DBV = 7%','DBV = 9%','Location','NorthWest')
    xlabel('True OEF (%)');
    ylabel('Estimated OEF (%)');
    axis([0,mo,0,mo]);

    yticks([0:0.2:0.8])
    yticklabels({'0','20','40','60','80'})
    xticklabels({'0','20','40','60','80'})

    %% Plotting corrected OEF estimates

    % % L model
    % modOEF = 0.106.*tan(0.0138*estR2p./estDBV);

    % 2C model
%     modOEF = 0.212.*tan(0.0125*estR2p./estDBV);
    
    % Kappa 2C
    modOEF = 0.145.*tan(0.00477*estR2p./estDBV);


    figure; box on; hold on; axis square; grid on;
    for ff = 1:nd
        scatter(trueOEF(ff,:),modOEF(ff,:),[],'filled');
    end

    % plot unity line
    plot([0,mo],[0,mo],'k-','LineWidth',1);

    legend('DBV = 1%','DBV = 3%','DBV = 5%','DBV = 7%','DBV = 9%','Location','NorthWest')
    xlabel('True OEF (%)');
    ylabel('Estimated OEF (%)');
    axis([0,mo,0,mo]);

    yticks([0:0.2:0.8])
    yticklabels({'0','20','40','60','80'})
    xticklabels({'0','20','40','60','80'})
end