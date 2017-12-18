% FabberCurves.m
% Display an averaged-out ASE curve from FABBER "modelfit" data

clear;

% select a fabber run
fabber = '222';
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';
fdname = dir([resdir,'fabber_',fabber,'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% fabber = '17';
% resdir = '/Users/mattcher/Documents/DPhil/Data/validation_sqbold/results/';
% fdname = dir([resdir,'res_',fabber,'_*']);
% fabdir = strcat(resdir,fdname.name,'/');

slicenum = 3:10;

% Load a mask
maskslice = LoadSlice('/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs1/mask_gm_60.nii.gz',slicenum);

% Load data
[modeldata,~,~,~] = read_avw([fabdir,'modelfit.nii.gz']);

% Select slices
modeldata = modeldata(:,:,slicenum,:);
mdims = size(modeldata);

% Apply mask
modeldata = modeldata.*repmat(maskslice,1,1,1,mdims(4));

% Identify extreme points and mask those out too
%%% Will do this later

% Loop through volumes and average over grey matter
for ii = 1:mdims(4)
    
    voldata = modeldata(:,:,:,ii);
    voldata = voldata(:);
    
    