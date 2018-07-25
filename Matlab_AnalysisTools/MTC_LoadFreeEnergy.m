function [EnergyData,ResData,ModelData] = MTC_LoadFreeEnergy(fabberset,subnum,slices)
    % MTC_LoadFreeEnergy usage:
    %
    %       [EnergyData,ResData,ModelData] = MTC_LoadFreeEnergy(fabberset,subnum,slices)
    %
    % Loads the Free Energy (and Residual, and Model) data from a specific
    % volume of FABBER results designated by FABBERSET. Returns them as vectors
    % ENERGYDATA, RESDATA, and MODELDATA respectively. Requires the function 
    % LoadSlice.m to work. Derived from MTC_LoadVol.
    %
    %
    %       Copyright (C) University of Oxford, 2018
    %
    %
    % Created by MT Cherukara, 25 July 2018
    %
    % CHANGELOG:
    
% hardcoded parameters
if ~exist('slices','var')
    slices = 4:9;
end

% define thresholds for Free Energy, Residual, and the Model
thrshE = 1000;
thrshR = 50;
thrshM = 500;


% Find the right folder
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';
fdname = dir([resdir,'fabber_',num2str(fabberset),'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% Load the Data
Eslice = LoadSlice([fabdir,'freeEnergy.nii.gz'],slices);
Rslice = LoadSlice([fabdir,'residuals.nii.gz'],slices);
Mslice = LoadSlice([fabdir,'modelfit.nii.gz'],slices);

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


% Apply mask, take absolute values, vectorize
Eslice = Eslice.*Maskslice;
Eslice = abs(Eslice(:));
Rslice = Rslice.*Maskslice;
Rslice = Rslice(:); % don't take the absolute value of the residual
Mslice = Mslice.*Maskslice;
Mslice = abs(Mslice(:));

% Create a mask of values to remove
BadsliceE = (Eslice == 0) + ~isfinite(Eslice) + (Eslice > thrshE);
BadsliceR = (Rslice == 0) + ~isfinite(Rslice) + (abs(Rslice) > thrshR) + ...
            (Mslice == 0) + ~isfinite(Mslice) + (Mslice > thrshM);

% Remove bad values
Eslice(BadsliceE ~= 0) = [];
Rslice(BadsliceR ~= 0) = [];
Mslice(BadsliceR ~= 0) = [];

% Output
EnergyData = Eslice;
ResData = Rslice;
ModelData = Mslice;