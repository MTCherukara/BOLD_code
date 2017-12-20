% FabberCurves.m
% Display an averaged-out ASE curve from FABBER "modelfit" data

clear;

% subject
ss = 4;

% identify the correct dataset
% runs = {'222', '223', '224', '225', '226', '227', '228'};
runs = {'201', '202', '203', '204', '205', '206', '207'};
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
modeldata = read_avw([fabdir,'modelfit.nii.gz']);
rawdata   = read_avw( ['/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs',num2str(ss),'/sub0',num2str(ss),'_ASE_FLAIR_av_mc.nii.gz']);

% Select slices
modeldata = modeldata(:,:,slicenum,:);
rawdata = rawdata(:,:,slicenum,:);
mdims = size(modeldata);

% Apply mask
modeldata = modeldata.*repmat(maskslice,1,1,1,mdims(4));
rawdata = rawdata.*repmat(maskslice,1,1,1,mdims(4));

% Identify extreme points and mask those out too
%%% Will do this later

% pre-allocate
volsignal = zeros(1,mdims(4));
rawsignal = zeros(1,mdims(4));

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
    
    % same again, but for the raw data
    voldata = rawdata(:,:,:,ii);
    voldata = voldata(:);
    
    % remove extreme values
    vl = quantile(voldata,0.9995);
    voldata(voldata > vl) = [];
    
    % remove zeros
    voldata(voldata == 0) = [];
    
    % average
    rawsignal(ii) = mean(voldata);
end

% tau values
% taus = [0, 16:4:64]./1000;
taus = (-28:4:64)./1000;
tauA = linspace(taus(1),taus(end));

% These are the inferred parameter values
S0  = [148, 145, 128, 153, 188, 165, 188];
R2p = [3.65, 4.48, 3.55, 4.07, 3.87, 3.99, 3.29];
DBV = [5.28, 7.80, 5.29, 7.17, 7.54, 6.23, 5.44]./100;

% Calculate signal based on inferred R2', DBV, and S0
anatsignal = S0(ss).*exp(DBV(ss) - (R2p(ss).*abs(tauA)));

tc = DBV(ss)./R2p(ss);
tau_shrt = linspace(-tc,tc,100);
tau_long = linspace(tc,0.064,100);

% for curve-fitting
T_shrt = taus(5:11);
S_shrt = log(rawsignal(5:11));

T_long = taus(12:end);
S_long = log(rawsignal(12:end));

P_shrt = polyfit(T_shrt,S_shrt,2);
P_long = polyfit(T_long,S_long,1);

Fit_shrt = (P_shrt(1).*(tau_shrt.^2)) + (P_shrt(2).*tau_shrt) + P_shrt(3);
Fit_long = (P_long(1).*tau_long) + P_long(2);

% Plot results
figure('WindowStyle','Docked');
hold on; box on;
set(gca,'FontSize',18);
plot(1000*tauA,log(anatsignal),'-','LineWidth',2);
plot(1000*[tau_shrt,tau_long],[Fit_shrt,Fit_long],'-','LineWidth',2);
plot(1000*taus,log(volsignal),'kx','LineWidth',2);
plot(1000*taus,log(rawsignal),'ro','LineWidth',2);
xlabel('Spin-Echo Offset \tau (ms)');
ylabel('Log(Signal)');
title(['Subject ',num2str(ss)]);
legend('Fabber Analytical','LLS Analytical','Fabber Modelfit','Raw Data','Location','NorthEast');
xlim([-32,68]);

% Print results
disp(['R2'' (LLS): ',num2str(-P_long(1))]);
disp(['R2'' (FABBER): ',num2str(R2p(ss))]);
disp(['DBV (LLS): ',num2str(P_long(2)-P_shrt(3))]);
disp(['DBV (FABBER): ',num2str(DBV(ss))]);

% save(['Temp_Volsig_',num2str(ss),'.mat'],'volsignal');

    
    