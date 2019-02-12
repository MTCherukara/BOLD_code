% xSimulatedSNR
% Calcuate the actual SNR of the simulated grid data, just to check that we were
% simulating SNR correctly. Also calculate CNR in order to compare that with the
% VS dataset

% MT Cherukara
% 11 February 2019

clear;
clc;

% Load in the dataset
nomSNR = 500;    % nominal SNR
load(['/Users/mattcher/Documents/DPhil/Code/Matlab_qBOLDSim/ASE_Data/ASE_Grid_2C_50x50_SNR_',num2str(nomSNR),'.mat']);

% Spin echo point
SEind = 2;      % for tau=-16:8:64
nt = length(tau);

% Normalize the non-noised ASE model data
SEgrid = repmat(ase_model(:,:,:,SEind),1,1,1,nt);
ase_model = ase_model./SEgrid;

% Vectorize, and put them both together
matData = [ase_data(:), ase_model(:)];

% % Calculate SNR by standard deviation of two images
% matMean = mean(matData,2);
% matStdv = std(matData,[],2);
% 
% stdSNR = mean(matMean./matStdv);

% Calculate SNR by difference
matSum = mean(sum(matData,2));
matDif = std(abs(matData(:,1) - matData(:,2)));

diffSNR = matSum./(sqrt(2).*matDif);

% Calculate CNR
tauDiff = squeeze(ase_data(:,:,:,2) - ase_data(:,:,:,end));
tauNoise = squeeze(ase_data(:,:,:,end) - ase_model(:,:,:,end));

CNR = mean(tauDiff(:))./std(tauNoise(:));

% Print out answers
disp(['Nominal SNR : ',num2str(nomSNR)]);
% disp(['  SNR (std) : ',round2str(stdSNR,0)]);
% disp(['  SNR (diff): ',round2str(diffSNR,0)]);
disp(['  CNR       : ',round2str(CNR,1)]);