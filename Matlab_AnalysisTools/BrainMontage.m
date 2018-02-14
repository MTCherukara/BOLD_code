% function montage_image = BrainMontage(inputnifti,slices,threshold)
% BrainMontage usage:
%
%       montage_image = BrainMontage(input,slices,threshold)
%
% Loads nifty data INPUTNIFTI, and creates a montage of slices specified by 
% vector SLICES. Data are thresholded to be above 0 and below scalar THRESHOLD
%
%
%       Copyright (C) University of Oxford, 2018
%
%
% Created by MT Cherukara, 31 January 2018
%
% CHANGELOG:

clear;

%         SQ-LS    SQ-VB   1C-VB   2C-VB    2C-VBI
%         '106'  , '255' , '213' , '206' , '241' ;...   % subject vs6


%% CHECK INPUTS

% Check whether a name has been specified, if not, have the user pick
if ~exist('inputnifti','var')
    [niname, nidir] = uigetfile('*.nii.gz','Select NIFTY Data File to Load...');
    inputnifti = [nidir,niname];
end

% Check whether slices have been specified, if not, default to 3:10
if ~exist('slices','var')
    slices = 3:10;
end
ns = length(slices); % number of slices

% Set threshold based on the type of variable we're looking at
% if ~exist('threshold','var')

    if strfind(lower(niname),'dbv')
        threshold = 0.15;
        cmp = magma;
    elseif strfind(lower(niname),'r2p')
        threshold = 10;
        cmp = viridis;
    elseif strfind(lower(niname),'oef')
        threshold = 0.5;
        cmp = parula;
    else
        threshold = 1;
        cmp = gray;
    end

% end


%% LOAD AND THRESHOLD DATA
[voldata, dims] = read_avw(inputnifti);

% Take absolute value of DBV data
if strfind(lower(niname),'dbv')
    voldata = abs(voldata);
end

% Threshold
voldata(voldata < 0) = 0;
voldata(voldata > threshold) = threshold;


%% SHAVE THE SIDES
% remove some of the empty voxels from around the sides, so that the brains are
% closer together in the montage

sh_sds = 12;        % sides
sh_top = 3;         % top and bottom

voldata = voldata(1+sh_sds:end-sh_sds,1+sh_top:end-sh_top,:);

% work out the new sizes
sv = size(voldata);


%% DEFINE MONTAGE MATRIX

% for 4 or fewer slices, use a single row
if ns < 5
    nrows = 1;
    ncols = ns;

% for even slices, create a 2xN grid
elseif mod(ns,2) == 0
    nrows = 2;
    ncols = ns/2;
    
% for odd multiples of 3, create a 3xN grid
elseif mod(ns,3) == 0
    nrows = 3;
    ncols = ns/3;
    
% for other numbers, use a single row
else
    nrows = 1;
    ncols = ns;
end

% pre-allocate matrix
montage_image = zeros(nrows*sv(2),ncols*sv(1));


%% FILL MONTAGE MATRIX

pos_r = 1;
pos_c = 1;

% loop through slices
for ii = slices
    
    % Fill the slice in the montage_image
    montage_image(pos_c:pos_c+sv(2)-1,pos_r:pos_r+sv(1)-1) = squeeze(voldata(:,:,ii,1))';
    
    % Move on to the next starting point
    pos_r = pos_r + sv(1);
    if pos_r > sv(1)*ncols
        pos_c = pos_c + sv(2);
        pos_r = 1;
    end
end

% flip montage_image
montage_image = fliplr(montage_image);


%% DISPLAY FIGURE

figure; hold on;
imagesc(montage_image);
colormap(cmp);
axis equal
set(gca,'Visible','off')
set(gca,'LooseInset',get(gca,'TightInset'));