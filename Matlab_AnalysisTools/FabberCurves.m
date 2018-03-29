% FabberCurves.m
% Display an averaged-out ASE curve from FABBER "modelfit" data

clear;
% close all;

save_plot = 0;
setFigureDefaults;

% identify the correct dataset
% runs = {'250', '251', '252', '253', '254', '255', '256'};       % SQ-VB
% runs = {'208', '209', '210', '211', '212', '213', '214'};       % 1C-VB
% runs = {'264', '265', '266', '267', '268', '269', '270'};       % 1C-VB-TC
% runs = {'201', '202', '203', '204', '205', '206', '207'};       % 2C-VB
% runs = {'236', '237', '238', '239', '240', '241', '242'};       % 2C-VB-I
% runs = {'309', '310', '311', '312', '313', '314', '315'};       % 2C-VB-TC-I
% runs = {'330', '331', '332', '333', '334', '335', '336'};       % 1C-S-VB
runs = {'416'};
% rawname = 'ASE_TR_3_taus_11.nii.gz';
rawname = 'MR_756_ASE_TR_3_taus_11.nii.gz';

% subject
for ss = 1



fabber = runs{ss};
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';
% rawdir = ['/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs',num2str(ss),'/'];
rawdir = '/Users/mattcher/Documents/DPhil/Data/subject_08/';
fdname = dir([resdir,'fabber_',fabber,'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% slicenum = 3:10;
slicenum = 1:6;

% Load a mask
% maskslice = LoadSlice([rawdir,'mask_gm_60.nii.gz'],slicenum);
maskslice = LoadSlice([rawdir,'mask_gm_TR_2.nii.gz'],slicenum);
% maskslice = zeros(64,64,8);
% maskslice(18526) = 1;

% Load data
resdata = read_avw([fabdir,'modelfit.nii.gz']);
rsddata = read_avw([fabdir,'residuals.nii.gz']);
% rawdata = read_avw([rawdir,'sub0',num2str(ss),'_ASE_FLAIR_av_mc.nii.gz']);
rawdata = read_avw([rawdir,rawname]);

% Select slices
resdata = resdata(:,:,slicenum,:);
rawdata = rawdata(:,:,slicenum,:);
rsddata = rsddata(:,:,slicenum,:);
mdims = size(resdata);

% Apply mask
rawdata = rawdata.*repmat(maskslice,1,1,1,mdims(4));


% pre-allocate
volsignal = zeros(1,mdims(4));
rawsignal = zeros(1,mdims(4));
volresid  = zeros(1,mdims(4));

% Loop through volumes and average over grey matter
for ii = 1:mdims(4)
    
    % extract volume and apply mask
    resvector = resdata(:,:,:,ii).*maskslice;
    
    % vectorize
    resvector = resvector(:);
    
    %  remove zeros
    resvector(resvector == 0) = [];
        
    % remove extremely high values
    resvector(resvector > quantile(resvector,0.95)) = [];
    
    % remove extremely low values
    resvector(resvector < quantile(resvector,0.05)) = [];
    
    % average
    volsignal(ii) = nanmean(resvector);
    
    % same again, but for the raw data
    
    % extract volume and apply mask
    rawvector = rawdata(:,:,:,ii).*maskslice;
    
    % vectorize
    rawvector = rawvector(:);
    
    %  remove zeros
    rawvector(rawvector == 0) = [];
    
    % remove extremely high
    rawvector(rawvector > quantile(rawvector,0.95)) = [];
    
    % remove extremely low values
    rawvector(rawvector < quantile(resvector,0.05)) = [];
    
    % average
    rawsignal(ii) = nanmean(rawvector);
    
    % same again, for residuals
    
    % extract volume and apply mask
    rsdvector = rsddata(:,:,:,ii).*maskslice;
    
    % vectorize
    rsdvector = rsdvector(:);
    
    %  remove zeros
    rsdvector(rsdvector == 0) = [];
        
    % remove extremely high values
    rsdvector(rsdvector > quantile(rsdvector,0.95)) = [];
    
    % remove extremely low values
    rsdvector(rsdvector < quantile(rsdvector,0.05)) = [];
    
    % average
    volresid(ii) = nanmean(abs(rsdvector));
    
end

% tau values
% taus = [0, 16:4:64]./1000; % linear
% taus = (-28:4:64)./1000; % standard
taus = ([0, 2, 4,  6,  8, 10, 20, 30, 40, 50, 60])./1000;
% taus = ([0, 3, 6,  9, 20, 40, 60])./1000;
% taus = ([-12, -8, -4, 0, 4, 8, 12, 16, 24, 32, 40, 48, 56, 64])./1000; % spread
% taus = (-16:8:64)./1000;
tauA = linspace(taus(1),taus(end));

% scale both datasets to have the same mean
% volsignal = log(volsignal)./mean(log(volsignal));
% rawsignal = log(rawsignal)./mean(log(rawsignal));

% ssd = sum((volsignal-rawsignal).^2);
% disp(['Subject ',num2str(ss),' difference: ',num2str(1000*ssd)]);


%% Plot results
figure; hold on; box on;
plot(1000*taus,log(volsignal),'kx');
plot(1000*taus,log(rawsignal),'ro');
plot(1000*taus,log(volsignal+volresid),'bx');
xlabel('Spin-Echo Offset \tau (ms)');
ylabel('Log (Signal)');
title(['Grey Matter Average - Subject ',num2str(ss)]);
legend('FABBER Model Fit','Raw ASE Data','Location','NorthEast');
% xlim([-32,68]);
xlim([-4,64]); % spread
% ylim([0.975, 1.015]);


if save_plot
    export_fig(strcat('GM_Average_Subject_',num2str(ss),'.pdf'));
end

end
