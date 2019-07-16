% Anova_LoadAllSubs.m
%
% Loads FABBER data from all subjects for a single parameter and condition, and
% saves them out in a vector, which can be compared later using ANOVA
%
% MT Cherukara
% 18 June 2019
%
% CHANGELOG:

clear;

%% INITIALIZATION

% Parameter name
pnames = {'R2p';'DBV';'OEF'};

% number of subjects
nsub = 5;

% Set number
fset = 801;

% Results directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';

% Slices
slicenum = 2:8;

% Mask name
% maskname = 'mask_new_gm_95.nii.gz';
maskname = 'mask_csf_gm_20.nii.gz';

%% PRE-ALLOCATE

% Threshold values
threshes = containers.Map({'R2p', 'DBV', 'OEF', 'VC', 'DF', 'lambda', 'Ax' , 'R2'},...
                          [ 30  ,  1   ,  1   ,  1  ,  15 ,   1     ,  30  ,  50 ]);  

defaults = containers.Map({'R2p', 'DBV', 'OEF', 'VC', 'DF', 'lambda', 'Ax' , 'R2'},...
                          [ 2.6 , 0.036, 0.4  , 0.01,  15 ,   1     ,  30  ,  50 ]);  

% empty array
vecAllData = [];


%% LOAD THE DATA

% loop through Subjects
for ss = 1:nsub
    
    snum = fset + ss - 1;
    
    % Find the right directory
    fdname = dir([resdir,'fabber_',num2str(snum),'_*']);
    fabdir = strcat(resdir,fdname.name,'/'); 
    
    % Identify subject for the mask
    CC = strsplit(fabdir,'_s');
    subnum = CC{2}(1:2);
    maskdir = ['/Users/mattcher/Documents/DPhil/Data/subject_',subnum,'/'];
    
    % Load the mask
    volMask = LoadSlice([maskdir,maskname],slicenum);
    
    % Number of voxels
    nmsk = sum(volMask(:));
    
    % Pre-allocate
    matSubData = zeros(3,int64(nmsk));
    
    % Loop through Parameters
    for pp = 1:length(pnames)
        
        vname = pnames{pp};
        
        % Pull out threshold and default values
        thrsh = threshes(vname);
        dflt = defaults(vname);
    
        % Load the data
        volRaw = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],slicenum);

        % Apply mask
        volData = abs(volRaw(:).*volMask(:));
        
        % Calculate difference difference
        volDiff = abs(volData - dflt);
        
        % Create vector of bad data, to remove
        badData = (volData <= 0) + ~isfinite(volData) + (volData > thrsh) + (volDiff < 0.0001);

        % Remove bad values
        volData(badData > 0) = [];

        % Store out
        matSubData(pp,1:length(volData) ) = volData;
    end
    
    % Store out
    vecAllData = [vecAllData, matSubData];
    
end % for ss = 1:nsub

% Cut any row with all zeros
vecAllData(:,sum(vecAllData,1) == 0) = [];

%% SAVE OUT
% save(['Fabber_Data/AllSub_Data_CSF_20_',num2str(fset),'.mat'],'vecAllData');
    
    
