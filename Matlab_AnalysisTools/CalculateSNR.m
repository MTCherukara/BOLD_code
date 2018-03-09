% CalculateSNR.m
% Matthew Cherukara

% have the user the data file, then load it
disp('Choose data file:');
[dfile,ddir] = uigetfile('*.nii.gz','Choose Data File');
[ddata,dims] = read_avw([ddir,dfile]);

% see if there is a 'ROI_brain' file present
try
    bmask = read_avw([ddir,'ROI_brain.nii.gz']);
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

% loop through volumes
for ii = 1:dims(4)
    
    % pull out the specific volume
    bdata = squeeze(ddata(:,:,:,ii));
    
    % apply the air mask
    adata = bdata(amask==1);
    
    % apply the brain mask
    bdata = bdata(bmask==1);
    
    % calculate mean in brain masked area
    signal = mean(bdata(:));
    
    % caluclate std in the air masked area
    sigma = std(adata(:));
    
    % calculate SNR
    snr(ii) = 0.655*(signal./sigma);
    
    % print out result
    disp(['  SNR of Volume ',num2str(ii),' of ',num2str(dims(4)),': ',num2str(snr(ii),4)]);
end

disp(['Average SNR: ',num2str(mean(snr),4)]);
    
    