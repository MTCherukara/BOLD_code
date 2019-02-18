% FabberCurves.m
% Display an averaged-out ASE curve from FABBER "modelfit" data, or from other
% 4D ASE-type datasets (designed for use with the VS dataset)
%
% MT Cherukara
% 
% Actively used as of 2019-02-12
%
% Changelog:
%
% 2019-02-12 (MTC). Adapted this specifically to use simulated grid data. Will
%       eventually have to apply this to brain data (which will require also
%       loading a mask and stuff like that), but for now, this only works in
%       simulated data. 

clear;
% close all;

setFigureDefaults;

% User Choices:
slices = 1;
setnum = 241;

% signal threshold
thrsh = 1000;

% specify which OEF and DBV values we want
pickOEF = 41;
pickDBV = 3;

% options
plot_av = 1;        % plot the average across all voxels


%% Load the Data

resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_ModelFits/';
fdname = dir([resdir,'fabber_',num2str(setnum),'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% Load modelfit data
volFit = LoadSlice([fabdir,'modelfit.nii.gz'],slices);

% also load the ground truth
gnddir = '/Users/mattcher/Documents/DPhil/Data/qboldsim_data/';
% volGnd = LoadSlice([gnddir,'ASE_Grid_2C_50x50_Taus_24_SNR_500.nii.gz'],1);
volGnd = LoadSlice([gnddir,'ASE_Grid_Sharan_50x50_Taus_11_SNR_200.nii.gz'],1);

% info
nt = size(volFit,3);


%% Prepare for displaying

% vectorize the rest, so that we can remove bad values
vecFit = shiftdim(volFit,2);
vecFit = reshape(vecFit,nt,[]);

% vectorize the ground truth data
vecGnd = shiftdim(volGnd,2);
vecGnd = reshape(vecGnd,nt,[]);

% find bad values
badData = any(vecFit == 0,1) + any(~isfinite(vecFit),1) + any(vecFit > thrsh,1);

% remove bad values
vecFit(:,badData ~= 0) = [];
vecGnd(:,badData ~= 0) = [];

% take the mean
meanFit = mean(vecFit,2);
meanGnd = mean(vecGnd,2);


% tau values (which we assume, at this stage)
% tau = -28:4:64;     % in ms, for ease of plotting
tau = -16:8:64;


%% Plot average
if plot_av
    figure; box on;
    plot(tau,meanGnd); hold on;
    plot(tau,meanFit); 
    xlabel('Spin echo displacement \tau (ms)')
    ylabel('ASE Signal');
    legend('Ground Truth','Fitted Signal');
    title('Average across all OEF-DBV values');
    xlim([-32,68]);
    % ylim([57,103]);
end


%% Plot a specific OEF-DBV pair

% for a 50x50 grid (dimensions: OEF, DBV)
OEFvals = 0.21:0.01:0.7;
DBVvals = 0.003:0.003:0.15;

% find the indices of those values
indOEF = find(100.*OEFvals >= pickOEF,1);
indDBV = find(100.*DBVvals >= pickDBV,1);

% pull out the signals (OEF, DBV)
sigPick = squeeze(volFit(indOEF,indDBV,:));
sigGnd  = squeeze(volGnd(indOEF,indDBV,:));

% find what the results were on that voxel
volOEF = LoadSlice([fabdir,'mean_OEF.nii.gz'],slices);
volDBV = LoadSlice([fabdir,'mean_DBV.nii.gz'],slices);
volS0  = LoadSlice([fabdir,'mean_S0.nii.gz'],slices);

resOEF = 100*volOEF(indOEF,indDBV);
resDBV = 100*volDBV(indOEF,indDBV);
resS0  = volS0(indOEF,indDBV);

% display those
disp(['True OEF = ',num2str(pickOEF),', Actual OEF = ',num2str(resOEF)]);
disp(['True DBV = ',num2str(pickDBV),', Actual DBV = ',num2str(resDBV)]);
disp(['True S0  = ',num2str(100) ,', Actual S0  = ',num2str(resS0)]);

figure; box on;
plot(tau,sigGnd); hold on;
plot(tau,sigPick);
xlim([-32,68]);
% ylim([57,103]);
xlabel('Spin echo displacement \tau (ms)')
ylabel('ASE Signal');
legend('Ground Truth','Fitted Signal');
title(['OEF = ',num2str(pickOEF),'%, DBV = ',num2str(pickDBV),'%']);