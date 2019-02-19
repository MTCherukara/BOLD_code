% voxelwise_anova.m
%
% calculates variation between fabber data-sets, on a voxel-wise basis using
% ANOVA. Derived from FabberAverages.m
%
% MT Cherukara
% 2 July 2018
%
% Changelog:
%
% 2019-02-14 (MTC). Added functionality for simulated grids. This now works, but
%       it doesn't actually do the thing we want it to do, because we want to do
%       an ANOVA test of the errors, not the raw parameter values.       
%
% 2019-02-04 (MTC). Re-written, based on FabberAverages, to be better in a bunch
%       of ways.


clear; 
% close all;
setFigureDefaults;

set0 = 1;

%% User Selected Parameters
vname = 'R2p';              % variable name
setname = 'VS';
lbls = {'L Model','1C Model','2C Model'};

% Pick FABBER datasets
fsets = [855, 901, 915] + set0 - 1;

% Which pairs of FSETS do we want to compare?
grps = {[1,2];[1,3]};


%% Basics
nsets = length(fsets);      % number of sets

% Results directory
if strcmp(setname,'SIM')
    resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_ModelFits/';
else
    resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';
end

% Look at the first dataset in order to figure out which mask to load
set1 = fsets(1);
fdname = dir([resdir,'fabber_',num2str(set1),'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% Figure out subject and mask number, and such
switch setname
    
    case 'VS'
        
        slicenum = 4:9;
        maskname = 'mask_gm.nii.gz';
        CC = strsplit(fabdir,'_vs');
        subnum = CC{2}(1);
        maskdir = ['/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs',subnum,'/'];
       
    case 'AMICI'
        
        slicenum = 3:8;
        maskname = 'mask_GM.nii.gz';
        CC = strsplit(fabdir,'_p');     % need a 3-digit subject number
        subnum = CC{2}(1:3);            
        C2 = strsplit(CC{2},'ses');     % also need a Session Number (1,5)
        sesnum = C2{2}(1);
        maskdir = ['/Users/mattcher/Documents/BIDS_Data/qbold_stroke/sourcedata/sub-',...
                   subnum,'/ses-00',sesnum,'/func-ase/'];
               
    case 'CSF'
        
        slicenum = 3:8;
        maskname = 'mask_new_gm_50.nii.gz';
        CC = strsplit(fabdir,'_s');     % need a 2-digit subject number
        subnum = CC{2}(1:2);
        maskdir = ['/Users/mattcher/Documents/DPhil/Data/subject_',subnum,'/'];
               
    case 'genF'
        
        slicenum = 1:6;     % new AMICI protocol FLAIR
        maskname = 'mask_gm_80_FLAIR.nii.gz';
        CC = strsplit(fabdir,'_s');     % need a 2-digit subject number
        subnum = CC{2}(1:2);
        maskdir = ['/Users/mattcher/Documents/DPhil/Data/subject_',subnum,'/'];
        
    case 'SIM'
        
        slicenum = 1;
        subnum = 0;
        
    otherwise 
        
        slicenum = 5:10;    % new AMICI protocol nonFLAIR
        maskname = 'mask_gm_80_nonFLAIR.nii.gz';
        CC = strsplit(fabdir,'_s');     % need a 2-digit subject number
        subnum = CC{2}(1:2);
        maskdir = ['/Users/mattcher/Documents/DPhil/Data/subject_',subnum,'/'];
        
end

% Threshold values
threshes = containers.Map({'R2p', 'DBV', 'OEF', 'VC', 'DF', 'lambda', 'Ax' },...
                          [ 30  ,   1  ,   1  ,  1  ,  15 ,   1     ,  30  ]);  

% Load mask data
if strcmp(setname,'SIM')
    mskData = ones(50,50);
else
    mskData = LoadSlice([maskdir,maskname],slicenum);
end


%% Pre-allocation
% Pre-allocate some arrays for Data and Variances
        % this is deliberately too big, but since the exact number of data
        % points may vary between sets, we will do it like this, then cut it
        % down to the length of the largest set, and then deal with the extra
        % zeros later
matData = zeros(5000,nsets);

% pre-assign the max and min lengths, which will be replaced in the loop
maxLength = 1; 
minLength = 1e5;



%% Loop Through Subjects

for ss = 1:nsets
    
    snum = fsets(ss);
       
    % Find the right directory
    fdname = dir([resdir,'fabber_',num2str(snum),'_*']);
    fabdir = strcat(resdir,fdname.name,'/'); 
    
    % Load the data
    volData = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],slicenum);

    % Apply mask
    volData = abs(volData(:).*mskData(:));
    
    % Remove bad values
    volData(volData == 0) = [];
    
    % pull out the length of the data
    dataLength = length(volData);
    
    % decide what the length of the longest and shortest datasets are
    maxLength = max(maxLength,dataLength);
    minLength = min(minLength,dataLength);
    
    % assign data into the pre-allocated array
    matData(1:dataLength,ss) = volData;
    
end


%% Analysis

% Pull out threshold value
thrsh = threshes(vname);

% cut off excess zeros in the data array
matData = matData(1:minLength,:);    

% Now remove some bad values from the matrix
matBad = (matData > thrsh) + ~isfinite(matData);
badrows = sum(matBad,2);
matData(badrows > 0,:) = [];
    
% Average
aData = mean(matData);

% ANOVA
[~,~,daStats] = anova2(matData,1,'off');
daC = multcompare(daStats,'display','off');

% Pull out p-values
pvls = MC_pvalues(daC,grps);


%% Plotting

if strcmp(vname,'DBV') || strcmp(vname,'OEF') || strcmp(vname,'VC') || strcmp(vname,'lambda')
        aData = aData.*100;
end
    
% Maximum y-axis value based on the variable:
yMax = containers.Map({'R2p', 'DBV' , 'OEF' , 'VC', 'DF', 'lambda'}, ...
                      [ 5.6 ,  10.5 ,  32   ,  1  ,  15 ,   1     ]);  

% Plot Bar Chart
figure;
hold on; box on;
bar(1:nsets,aData,0.6);

% Set Axes
axis([0.5,nsets+0.5,0,yMax(vname)]);
xticks(1:nsets);
ylabel(vname);
title(['Subject ',subnum]);
xticklabels(lbls); 

% Add Significance Information
HD = sigstar(grps,pvls,1);
set(HD,'Color','k')
set(HD(:,2),'FontSize',16);

