% CalculateSNR.m
% Matthew Cherukara

% Actively used as of 2019-02-11

clear;
close all;

% Manual selection of subject
subnum = 7;
ddir = strcat('/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs',num2str(subnum),'/');
dfile = 'ASE_FLAIR_av_mc.nii.gz';

% % have the user the data file, then load it
% disp('Choose data file:');
% [dfile,ddir] = uigetfile('*.nii.gz','Choose Data File');

% Load the data
[ddata,dims] = read_avw([ddir,dfile]);

slices = 4:9;

% see if there is a 'ROI_brain' file present
try
    bmask = read_avw([ddir,'mask_gm.nii.gz']);
catch
    disp('Choose brain ROI mask');
    [bfile,bdir] = uigetfile('*.nii.gz','Choose brain ROI mask');
    bmask = read_avw([bdir,bfile]);
end

% see if there is a 'ROI_air' file present
try 
    amask = read_avw([ddir,'mask_air.nii.gz']);
catch
    disp('Choose air ROI mask');
    [afile,adir] = uigetfile('*.nii.gz','Choose air ROI mask');
    amask = read_avw([adir,afile]);
end

% resize masks to the right slices
amask = amask(:,:,slices);
bmask = bmask(:,:,slices);

% resize data to the right slices;
ddata = ddata(:,:,slices,:);

% preallocate arrays
snr    = zeros(1,dims(4));
signal = zeros(1,dims(4));
sigma  = zeros(1,dims(4));

% loop through volumes
for ii = 1:dims(4)
    
    % pull out the specific volume
    bdata = squeeze(ddata(:,:,:,ii));
    
    
    % apply the air mask
    adata = bdata(amask==1);
    
    % apply the brain mask
    bdata = bdata(bmask==1);
    
    % calculate mean in brain masked area
    signal(ii) = mean(bdata(:));
    
    % background signal
    backs = mean(adata(:));
    
    % caluclate std in the air masked area
    sigma(ii) = std(adata(:));
    
    % calculate SNR
    snr(ii) = 0.655*((signal(ii)-backs)./sigma(ii));
    
    % print out result
%     disp(['  SNR of Volume ',num2str(ii),' of ',num2str(dims(4)),': ',round2str(snr(ii),2)]);
end

disp(['Average SNR  : ',round2str(mean(snr),1)]);
disp(['  SNR (tau=0): ',round2str(snr(8),1)]);    % if tau = -28:4:64, tau(8) = 0
disp(['  SNR (end)  : ',round2str(snr(end),1)]);

% Calculate CNR
cnr = (signal(8) - signal(end))./mean(sigma);
disp(['  CNR        : ',round2str(cnr,1)]);