% xMakeGridData.m

% Take a large grid of simulated ASE signals and make a smaller grid with the
% specific tau values and SNR that we want.

% Based on xSimulateGrid.m

% MT Cherukara
% 5 February 2019

clear;


%% Specify what we want
SNR = inf;
tau = (-16:8:64)./1000;    % For TE = 72ms or 108ms or 84 ms
% tau = [0,16:8:64]./1000;
% tau = (-8:4:32)./1000;
% tau = (-24:12:96)./1000;

% figure out SEind
SEind = find(tau == 0);

% Dind = 10; % which DBV index we want
RR = 23;


%% Load in the big grid
% fulldata = load(['ASE_Data/ASE_Grid_2C_100x10_TE_84.mat']);
% fulldata = load(['../../Data/vesselsim_data/vs_arrays/TE84_vsData_single_R_',num2str(RR),'.mat']);
fulldata = load('../../Data/vesselsim_data/vs_arrays/DataRND_2_TE_80_tau_64_frechet_100.mat');

% Pull values
DBVvals = fulldata.DBVvals;
OEFvals = fulldata.OEFvals;
TE = fulldata.TE;
% params = fulldata.params;

% nDBV = length(DBVvals);
% nOEF = length(OEFvals);

nDBV = 100;
nOEF = 10;

% stuff we need
% gridAll = fulldata.ase_model; % not normalized
gridAll = fulldata.S0;      % for VesselSim data
tausAll = fulldata.tau;
nt = length(tau);

% find indices of the taus we want
[~,Tind,~] = intersect(tausAll,tau);

%% Create dataset

% pull out taus
% ase_model = gridAll(:,:,Tind);
ase_model = zeros(nDBV,nOEF,1,nt);
ase_model(:,:,1,:) = gridAll(:,:,Tind);

% % For pulling out random specific DBV values
% ase_model = repmat(ase_model(Dind,:,:,:),100,1,1,1);


%% Add Noise
% Create noise
gridSigma = repmat(mean(ase_model,4)./SNR,1,1,1,nt);
gridNoise = gridSigma.*randn(size(ase_model));

% Add noise
% ase_data = ase_model + gridNoise;
ase_data = ase_model;

% Normalize to spin echo
ase_data = ase_data ./ repmat(ase_data(:,:,:,SEind),1,1,1,nt);

% remove one value
ase_data(:,:,:,[8,10]) = [];


%% Save out
% dname = strcat('ASE_Grid_Single_50x50_TE_',num2str(1000*TE),'_R_',num2str(RR));
% dname = strcat('ASE_Grid_ND_Lauwers_50x50_TE_',num2str(1000*TE));
% dname = strcat('ASE_Grid_Sharan_100_TE_',num2str(1000*TE),'_tau_',num2str(1000*tau(end)),'_DBV_',num2str(Dind-1));
% dname = strcat('ASE_Grid_RND_Frechet_1000_TE_',num2str(1000*TE),'_tau_',num2str(1000*tau(end)));
dname = strcat('ASE_Bootstrap_Frechet_1000_TE_',num2str(1000*TE),'_Long2');


% save([dname,'.mat'],'ase_data','ase_model','tau','TE','OEFvals','DBVvals','params');
save([dname,'.mat'],'ase_data','ase_model','tau','TE','OEFvals','DBVvals');
save_avw(100.*ase_data,[dname,'.nii.gz'],'f',[1,1,1,3]);
