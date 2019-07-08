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
fset = 831;

% Results directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';

% Slices
slicenum = 2:8;

% Mask name
% maskname = 'mask_new_gm_95.nii.gz';
maskname = 'mask_csf_gm_20.nii.gz';

%% PRE-ALLOCATE

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
    
        % Load the data
        volRaw = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],slicenum);

        % Apply mask
        volData = abs(volRaw(:).*volMask(:));

        % Remove bad values
        volData(volData == 0) = [];

        % Store out
        matSubData(pp,:) = volData;
    end
    
    % Store out
    vecAllData = [vecAllData, matSubData];
    
end % for ss = 1:nsub


%% SAVE OUT
save(['Fabber_Data/AllSub_Data_CSF_20_',num2str(fset),'.mat'],'vecAllData');
    
    
