% FabberCurves.m
% Display an averaged-out ASE curve from FABBER "modelfit" data

clear;
% close all;

save_plot = 0;
setFigureDefaults;

% subject
% ss = 1;

for ss = 4

% identify the correct dataset
% runs = {'208', '209', '210', '211', '212', '213', '214'};       % 1C-VB
% runs = {'201', '202', '203', '204', '205', '206', '207'};       % 2C-VB
% runs = {'236', '237', '238', '239', '240', '241', '242'};       % 2C-VB-I
runs = {'316', '317', '318', '319', '320', '321', '322'};       % 2C-VB-I-2

fabber = runs{ss};
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';
rawdir = ['/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs',num2str(ss),'/'];
fdname = dir([resdir,'fabber_',fabber,'_*']);
fabdir = strcat(resdir,fdname.name,'/');

slicenum = 3:10;

% Load a mask
maskslice = LoadSlice([rawdir,'mask_gm_60.nii.gz'],slicenum);

% Load data
resdata = read_avw([fabdir,'modelfit.nii.gz']);
rawdata = read_avw([rawdir,'sub0',num2str(ss),'_ASE_FLAIR_av_mc.nii.gz']);

% Select slices
resdata = resdata(:,:,slicenum,:);
rawdata = rawdata(:,:,slicenum,:);
mdims = size(resdata);

% Apply mask
rawdata = rawdata.*repmat(maskslice,1,1,1,mdims(4));


% pre-allocate
volsignal = zeros(1,mdims(4));
rawsignal = zeros(1,mdims(4));

% Loop through volumes and average over grey matter
for ii = 1:mdims(4)
    
    % extract volume and apply mask
    resvector = resdata(:,:,:,ii).*maskslice;
    
    % vectorize
    resvector = resvector(:);
    
    %  remove zeros
    resvector(resvector == 0) = [];
    
    % remove extremely high values
    resvector(resvector > quantile(resvector,0.99)) = [];
    
    % remove extremely low values
    resvector(resvector < quantile(resvector,0.01)) = [];
    
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
    rawvector(rawvector > quantile(rawvector,0.99)) = [];
    
    % remove extremely low values
    rawvector(rawvector < quantile(resvector,0.01)) = [];
    
    % average
    rawsignal(ii) = nanmean(rawvector);
end

% tau values
% taus = [0, 16:4:64]./1000;
taus = (-28:4:64)./1000;
tauA = linspace(taus(1),taus(end));

% scale both datasets to have the same mean
volsignal = log(volsignal)./mean(log(volsignal));
rawsignal = log(rawsignal)./mean(log(rawsignal));

ssd = sum((volsignal-rawsignal).^2);
disp(['Subject ',num2str(ss),' difference: ',num2str(1000*ssd)]);


%% Plot results
figure; hold on; box on;
plot(1000*taus,(volsignal),'kx');
plot(1000*taus,(rawsignal),'ro');
xlabel('Spin-Echo Offset \tau (ms)');
ylabel('Log (Signal)');
title(['Grey Matter Average - Subject ',num2str(ss)]);
legend('FABBER Model Fit','Raw ASE Data','Location','NorthEast');
xlim([-32,68]);
% ylim([0.97, 1.005]);


if save_plot
    export_fig(strcat('GM_Average_Subject_',num2str(ss),'.pdf'));
end

end
