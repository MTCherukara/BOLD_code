function [voldata,filename] = LoadVolume(filename,volnum)
% LoadSlice usage:
%
%       [voldata,filename] = LoadVolume(filename,volnum)
%
% Loads the data from a specific volume VOLNUM of a 3D or 4D NIFTI file 
% specified by FILENAME (both inputs optional), and returns that volume and
% the name of the chosen file (this is basically just a wrapper for
% read_avw) that allows some user input.
%
%
%       Copyright (C) University of Oxford, 2017
%
%
% Created by MT Cherukara, 4 October 2017
%
% CHANGELOG:
    
% Check whether a name has been specified, if not, have the user pick
if ~exist('filename','var')
    [niname, nidir] = uigetfile('*.nii.gz','Select NIFTY Data File to Load...');
    filename = [nidir,niname];
end

% Load the selected NIFTY into dataset
[dataset,dims,~,~,~] = read_avw(filename);

% Check whether the dataset is 3D, and if so, return it unmolested
if dims(4) == 1
    voldata = dataset;
    
% If not, see whether the user has specified a volume number, otherwise,
% have him/her pick one:
else
    if ~exist('volnum','var')
        volnum = inputdlg(['Enter a number between 1 and ',num2str(dims(4))],'Choose a Volume',1);
    end
    
    voldata = squeeze(dataset(:,:,:,volnum));
end
