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
setFigureDefaults;

% slices = 4;

% SQ-LS    SQ-VB   1C-VBS  1C-VBTC 1C-VBI  1C-VB-TCI  2C-VB   2C-VBI  2C-VB-TC  2C-VB-TCI
% '101'  , '250' , '330' , '264' , '257' , '316'    , '201' , '236' , '281'   , '309' ;...   % subject vs1


%% CHECK INPUTS

% Check whether a name has been specified, if not, have the user pick
if ~exist('inputnifti','var')
    [niname, nidir] = uigetfile('*.nii.gz','Select NIFTY Data File to Load...');
    inputnifti = [nidir,niname];
end

% Check whether slices have been specified, if not, default to 3:10
if ~exist('slices','var')
%     slices = 3:10;       % VS
%     slices = 3:14;       % CSF
    slices = 2:6;       % s11 FLAIR
end
ns = length(slices); % number of slices

% Set threshold based on the type of variable we're looking at
if strfind(lower(niname),'dbv')
    threshold = 0.25;
    cmp = magma;
elseif strfind(lower(niname),'r2p')
    threshold = 10;
    cmp = viridis;
elseif strfind(lower(niname),'oef')
    threshold = 0.6;
    cmp = parula;
elseif strfind(lower(niname),'df')
    threshold = 15;
    cmp = inferno;
else
    threshold = 1;
    cmp = gray;
end


%% LOAD AND THRESHOLD DATA
[inputdata, dims] = read_avw(inputnifti);

% Take absolute value of DBV data
% if strfind(lower(niname),'dbv')
    voldata = abs(inputdata);
% end

% Threshold
voldata(voldata < 0) = 0;
voldata(voldata > threshold) = threshold;


% % TEMP - multiply by the grey matter mask
% maskslice = LoadSlice('/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs3/mask_gm_60.nii.gz',1:10);
% voldata = voldata.*repmat(maskslice,[1,1,1,17]);


%% SHAVE THE SIDES
% remove some of the empty voxels from around the sides, so that the brains are
% closer together in the montage

if length(slices) == 1
    sh_sds = 0;
    sh_top = 0;
    sh_bot = 0;
else
    sh_sds = 15;        % sides
    sh_top = 5;         % top and bottom
    sh_bot = 5;
end


voldata = voldata(1+sh_sds:end-sh_sds,1+sh_bot:end-sh_top,:);

% work out the new sizes
sv = size(voldata);


%% DEFINE MONTAGE MATRIX

% for even slices, create a 2xN grid
if mod(ns,2) == 0
    nrows = 2;
    ncols = ns/2;

% for 4 or fewer slices, use a single row
elseif ns < 5
    nrows = 1;
    ncols = ns;

    
% for odd multiples of 3, create a 3xN grid
elseif mod(ns,3) == 0
    nrows = 3;
    ncols = ns/3;
    
% for other numbers, use a single row
else
    nrows = 1;
    ncols = ns;
end

% nrows = 1;
% ncols = ns;

% pre-allocate matrix
montage_image = zeros(nrows*sv(2),ncols*sv(1));


%% FILL MONTAGE MATRIX

pos_r = 1;
pos_c = 1;

% loop through slices
for ii = slices
    
    % Fill the slice in the montage_image
    montage_image(pos_c:pos_c+sv(2)-1,pos_r:pos_r+sv(1)-1) = (squeeze(voldata(:,:,ii,1))');
    
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

cmp(1,:) = [0,0,0];

figure; hold on;
imagesc(montage_image,[0,threshold]);
colormap(cmp);


% colorbar;
set(gca,'Visible','off')
set(gca,'LooseInset',get(gca,'TightInset'));
axis equal

%% Special display for Grid Search figures

% OEFvals = 100*(0.21:0.01:0.70);
% DBVvals = 100*(0.003:0.003:0.15);
% 
% % orient properly
% montage_image = flipud(montage_image');
% 
% figure; hold on;
% imagesc(DBVvals,OEFvals,montage_image,[0,threshold]);
% colormap(cmp);
% axis([0.3,15,21,70]);
% set(gca,'FontSize',20);
% ylabel('OEF (%)');
% xlabel('DBV (%)');
% yticks([25,35,45,55,65]);

% For a 2x3 grid, plot 30 lines high, and up to this point: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Five-row CSF maps up to here: %%%%%%%%%%%%%%%%%%%%%%%%%%%%