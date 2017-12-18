% FabberCurves.m
% Display an averaged-out ASE curve from FABBER "modelfit" data

clear;

% subject
ss = 7;

% identify the correct dataset
runs = {'222', '223', '224', '225', '226', '227', '228'};
fabber = runs{ss};
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';
fdname = dir([resdir,'fabber_',fabber,'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% fabber = '17';
% resdir = '/Users/mattcher/Documents/DPhil/Data/validation_sqbold/results/';
% fdname = dir([resdir,'res_',fabber,'_*']);
% fabdir = strcat(resdir,fdname.name,'/');

slicenum = 3:10;

% Load a mask
maskslice = LoadSlice(['/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs',num2str(ss),'/mask_gm_60.nii.gz'],slicenum);

% Load data
[modeldata,~,~,~] = read_avw([fabdir,'modelfit.nii.gz']);

% Select slices
modeldata = modeldata(:,:,slicenum,:);
mdims = size(modeldata);

% Apply mask
modeldata = modeldata.*repmat(maskslice,1,1,1,mdims(4));

% Identify extreme points and mask those out too
%%% Will do this later

% pre-allocate
volsignal = zeros(1,mdims(4));

% Loop through volumes and average over grey matter
for ii = 1:mdims(4)
    
    voldata = modeldata(:,:,:,ii);
    voldata = voldata(:);
    
    % remove extreme values
    vl = quantile(voldata,0.9995);
    voldata(voldata > vl) = [];
    
    % remove zeros
    voldata(voldata == 0) = [];
    
    % average
    volsignal(ii) = mean(voldata);
end

% tau values
taus = [0, 16:4:64]./1000;
tauA = linspace(taus(1),taus(end));

% These are the inferred parameter values
S0  = [148, 145, 128, 153, 188, 165, 188];
R2p = [3.65, 4.48, 3.55, 4.07, 3.87, 3.99, 3.29];
DBV = [5.28, 7.80, 5.29, 7.17, 7.54, 6.23, 5.44]./100;

% Calculate signal based on inferred R2', DBV, and S0
anatsignal = S0(ss).*exp(DBV(ss) - (R2p(ss).*tauA));

% Plot results
% figure('WindowStyle','Docked');
% hold on; box on;
% set(gca,'FontSize',18);
% plot(1000*tauA,log(anatsignal),'-','LineWidth',2);
% plot(1000*taus,log(volsignal),'kx','LineWidth',2);
% xlabel('Spin-Echo Offset \tau (ms)');
% ylabel('Log(Signal)');
% xlim([-8,68]);
disp(volsignal)


    
    