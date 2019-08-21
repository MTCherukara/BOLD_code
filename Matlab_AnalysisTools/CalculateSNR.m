% function CalculateSNR(subnum)
% Matthew Cherukara

% Actively used as of 2019-02-11

clear;
close all;

% Manual selection of subject
subnum = 9;
ddir = strcat('/Users/mattcher/Documents/DPhil/Data/subject_0',num2str(subnum),'/');
dfile = 'ASE_FLAIR_82_unrung.nii.gz';

% % have the user the data file, then load it
% disp('Choose data file:');
% [dfile,ddir] = uigetfile('*.nii.gz','Choose Data File');

% Load the data
[ddata,dims] = read_avw([ddir,dfile]);

slices = 3:8;

% see if there is a 'ROI_brain' file present
try
    bmask = read_avw([ddir,'mask_new_gm_80.nii.gz']);
catch
    disp('Choose brain ROI mask');
    [bfile,bdir] = uigetfile('*.nii.gz','Choose brain ROI mask');
    bmask = read_avw([bdir,bfile]);
end

% see if there is a 'ROI_air' file present
try 
    amask = read_avw([ddir,'ROI_air.nii.gz']);
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

    if ii == 3
        data_SE = bdata;
    elseif ii == dims(4)
        data_LT = bdata;
    end

end

disp(['Average SNR  : ',round2str(mean(snr),2),' +/- ',num2str(std(snr),3)]);
% disp(['  SNR (tau=0): ',round2str(snr(3),1)]);    % if tau = -28:4:64, tau(8) = 0
% disp(['  SNR (end)  : ',round2str(snr(end),1)]);

% Calculate CNR
contr = (data_SE - data_LT)./mean(sigma);

cnr = (signal(3) - signal(end))./mean(sigma);
% cnr = (max(signal) - min(signal))./mean(sigma);
disp(['  CNR        : ',round2str(mean(contr),2),' +/- ',num2str(std(contr)/2,2)]);

% disp(snr);