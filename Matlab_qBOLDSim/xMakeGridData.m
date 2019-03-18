% xMakeGridData.m

% Take a large grid of simulated ASE signals and make a smaller grid with the
% specific tau values and SNR that we want.

% Based on xSimulateGrid.m

% MT Cherukara
% 5 February 2019

clear;


%% Specify what we want
SNR = 500;
tau = (-16:8:64)./1000;

% figure out SEind
SEind = find(tau == 0);


%% Load in the big grid
fulldata = load(['ASE_Data/ASE_Grid_1C_50x50_SNR_',num2str(SNR),'.mat']);
% fulldata = load('../../Data/vesselsim_data/vs_arrays/TE84_vsData_sharan_50.mat');

% Pull values
DBVvals = fulldata.DBVvals;
OEFvals = fulldata.OEFvals;
TE = fulldata.TE;
params = fulldata.params;

% stuff we need
gridAll = fulldata.ase_model; % not normalized
% gridAll = fulldata.S0;      % for VesselSim data
tausAll = fulldata.tau;
nt = length(tau);

%% Create dataset
% find indices of the taus we want
[~,Tind,~] = intersect(tausAll,tau);

% pull out those taus
ase_model = gridAll(:,:,:,Tind);
% ase_model = zeros(50,50,1,nt);
% ase_model(:,:,1,:) = gridAll(:,:,Tind);

% Create noise
gridSigma = repmat(mean(ase_model,4)./SNR,1,1,1,nt);
gridNoise = gridSigma.*randn(size(ase_model));

% Add noise
ase_data = ase_model + gridNoise;
% ase_data = ase_model;

% Normalize to spin echo
ase_data = ase_data ./ repmat(ase_data(:,:,:,SEind),1,1,1,nt);


%% Save out
dname = strcat('ASE_Grid_1C_50x50_Taus_',num2str(nt),'_SNR_',num2str(SNR));

% save([dname,'.mat'],'ase_data','ase_model','tau','TE','OEFvals','DBVvals','params');
save([dname,'.mat'],'ase_data','ase_model','tau','TE','OEFvals','DBVvals');
save_avw(100.*ase_data,[dname,'.nii.gz'],'f',[1,1,1,3]);
