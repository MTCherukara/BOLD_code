function [volData,volStd] = MTC_LoadVol(fabberset,subnum,varname,slices)
    % MTC_LoadVol usage:
    %
    %       [volData,volStd] = MTC_LoadVol(fabberset,subnum,varname)
    %
    % Loads data from a specific volume of FABBER results designated by
    % FABBERSET and VARNAME, and applies a subject-specific grey-matter mask
    % based no SUBNUM. Returns the volume data as a vector VOLDATA and its
    % standard devations (calculated by FABBER) as VOLSTD. Requires the function
    % LoadSlice.m in order to work. 
    %
    % VARNAME must be one of: 'R2p', 'DBV', 'OEF', 'VC', 'DF', 'lambda'
    %
    %
    %       Copyright (C) University of Oxford, 2018
    %
    %
    % Created by MT Cherukara, 2 July 2018
    %
    % CHANGELOG:
    
% hardcoded parameters
if ~exist('slices','var')
    slices = 3:10;
end

threshes = containers.Map({'R2p', 'DBV', 'OEF', 'VC', 'DF', 'lambda', 'Ax' },...
                          [ 20  ,   1  ,   1  ,  1  ,  15 ,   1     ,  30  ]);  


% Find the right folder
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';
fdname = dir([resdir,'fabber_',num2str(fabberset),'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% Load the Data
Dataslice = LoadSlice([fabdir,'mean_',varname,'.nii.gz'],slices);

% Determine which type of mask to load and load it
if strfind(fdname.name,'_vs')
    
    % Load Mask from VS set
    Maskslice = LoadSlice(['/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs',...
                            num2str(subnum),'/mask_gm_60.nii.gz'],slices);

else
    
    % Load Mask from CSF set
    Maskslice = LoadSlice(['/Users/mattcher/Documents/DPhil/Data/subject_0',...
                            num2str(subnum),'/mask_FLAIR_GM.nii.gz'],slices);
    
end

% Load Standard Deviation Data
% Stdslice = LoadSlice([fabdir,'std_',varname,'.nii.gz'],slices);

% Define threshold
thrsh = threshes(varname);
                    
% Apply mask, take absolute values, vectorize
Dataslice = Dataslice.*Maskslice;
Dataslice = abs(Dataslice(:));
% Stdslice = Stdslice.*Maskslice;
% Stdslice = Stdslice(:);

% Create a mask of values to remove
Badslice = (Dataslice == 0) + ~isfinite(Dataslice) + (Dataslice > thrsh);
% Badslice = Badslice + ~isfinite(Stdslice) + (Stdslice > thrsh) + (Stdslice < (thrsh.*1e-3));

% Remove bad values
Dataslice(Badslice ~= 0) = [];
% Stdslice(Badslice ~= 0) = [];

% % Apply upper threshold
% Dataslice(Dataslice > thrsh) = thrsh;

% Output
volData = Dataslice;
% volStd  = Stdslice;
volStd = [];
