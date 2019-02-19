% AnovaSim.m
%
% calculates variation between simulated FABBER result datasets (or the errors
% between them and the ground truth) on a voxel-wise basis using ANOVA. Derived
% from voxelwise_anova.m
%
% MT Cherukara
% 14 February 2019
%
% Changelog:
%


clear; 
close all;
setFigureDefaults;

set0 = 7;

%% User Selected Parameters
vname = 'OEF';              % variable name
lbls = {'Linear LSQ','VB','2C Model'};

% Pick FABBER datasets
fsets = [250, 264, 271] + set0 - 1;

% Which pairs of FSETS do we want to compare?
grps = {[1,2],[1,3],[2,3]};

% Options
do_std = 1;
plot_rel = 0;


%% Basics

% Results directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_ModelFits/';

% Ground truth
gnddir = '/Users/mattcher/Documents/DPhil/Data/qboldsim_data/';

% Load ground truth data
volGnd = LoadSlice([gnddir,'ASE_Grid_50x50_',vname,'.nii.gz'],1);
vecGnd = volGnd(:);

% Threshold values
threshes = containers.Map({'R2p', 'DBV', 'OEF', 'VC', 'DF', 'lambda', 'Ax' },...
                          [ 50  ,   1  ,   1  ,  1  ,  15 ,   1     ,  30  ]);  

nsets = length(fsets);      % number of sets
ng = length(volGnd(:));     % grid size

% pull thresholds
thrV = threshes(vname);

                      
%% Pre-allocation

matData = zeros(ng,nsets);
matStd  = zeros(ng,nsets);
vecBad  = zeros(ng,1);


%% Load the Data

for ss = 1:nsets
    
    snum = fsets(ss);
       
    % Find the right directory
    fdname = dir([resdir,'fabber_',num2str(snum),'_*']);
    fabdir = strcat(resdir,fdname.name,'/'); 
    
    % Load the data
    volData = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],1);

    % Vectorize and store
    matData(:,ss) = volData(:);
    
    % Identify bad values
    vecBad = vecBad + ~isfinite(matData(:,ss)) + ( matData(:,ss) > thrV );
    
    % Process Standard deviation data
    if do_std
        volStd = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],1);
        matStd(:,ss) = volStd(:);
        
        % Idenfity bad values
        vecBad = vecBad + ( matStd(:,ss) > 2*thrV );
    end
    
end % for ss = 1:nsets


%% Analysis

% Remove bad values
vecThresh = vecBad > 0.5;
vecGnd(vecThresh) = [];
matData(vecThresh,:) = [];


% Calculate the error
matGnd = repmat(vecGnd,1,nsets);

matErr = abs(matGnd - matData);
matRel = matErr./matGnd;

% ANOVA
[~,~,statsErr] = anova2(matErr,1,'off');
compErr = multcompare(statsErr,'display','off');
pErr = MC_pvalues(compErr,grps);

if plot_rel
    [~,~,statsRel] = anova2(matRel,1,'off');
    compRel = multcompare(statsRel,'display','off');
    pRel = MC_pvalues(compRel,grps);
end

%% Plotting

disp(['(Excluded ',num2str(sum(vecThresh)),' of 2500 data points)']);


if strcmp(vname,'DBV') || strcmp(vname,'OEF') || strcmp(vname,'VC') || strcmp(vname,'lambda')
        matErr = matErr.*100;
end
    
% Maximum y-axis value based on the variable:
yMax = containers.Map({'R2p', 'DBV' , 'OEF' , 'VC', 'DF', 'lambda'}, ...
                      [ 7.5 ,   20  ,   45  , 100 ,  15 ,     100 ]);  
                  
% Pull out SNR value from name
CC = strsplit(fdname.name,'SNR_');
strSNR = CC{2};

% Plot Absolute Error
figure;
hold on; box on;
bar(1:nsets,mean(matErr),0.6);
axis([0.5,nsets+0.5,0,yMax(vname)]);
xticks(1:nsets);
ylabel(['Error in ',vname]);
xticklabels(lbls); 
title(['SNR = ',strSNR]);

% Add Significance Information
HE = sigstar(grps,pErr,1);
set(HE,'Color','k')
set(HE(:,2),'FontSize',16);

% Plot Relative Error
if plot_rel
    figure;
    hold on; box on;
    bar(1:nsets,100*mean(matRel),0.6);
    axis([0.5,nsets+0.5,0,200]);
    xticks(1:nsets);
    ylabel(['Relative Error in ',vname,' (%)']);
    xticklabels(lbls); 
    title(['SNR = ',strSNR]);

    % Add Significance Information
    HR = sigstar(grps,pRel,1);
    set(HR,'Color','k')
    set(HR(:,2),'FontSize',16);
end
