function [slicedata,slicenum,filename,vtype] = LoadSlice(filename,slicenum)
% LoadSlice usage:
%
%       [slicedata,slicenum,filename,vtype] = LoadSlice(filename,slicenum)
%
% Loads the data from a specific slice (or slices) SLICENUM of a NIFTY file
% into a matrix and returns it, along with some other potentially useful
% information.
%
%
%       Copyright (C) University of Oxford, 2017
%
%
% Created by MT Cherukara, 15 August 2017 (as part of SliceHistogram.m)
%
% CHANGELOG:
%
% 2017-10-04 (MTC). Made this function into a separate thing.
    
% Check whether a name has been specified, if not, have the user pick
if ~exist('filename','var')
    [niname, nidir] = uigetfile('*.nii.gz','Select NIFTY Data File to Load...');
    filename = [nidir,niname];
else
    niname = 'blank';
end

if ~exist('slicenum','var')
    slicenum = 5:8;
end

% Determine the type of variable we are looking at
if strfind(lower(niname),'oef')
    vtype = 'OEF';
elseif strfind(lower(niname),'dbv')
    vtype = 'DBV';
elseif strfind(lower(niname),'R2p')
    vtype = 'R2 prime';
else
    vtype = 'other';
end

% Load the selected NIFTY into dataset
[dataset,dims,~,~,~] = read_avw(filename);

% Record the number of slices
nsl = dims(3);

% for now
slicedata = squeeze(dataset(:,:,slicenum,:));
