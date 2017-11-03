% function AverageHistogram
% Loads histogram data, and analyses them
% MT Cherukara

clear;

hdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/Histograms/Subject_01/';

% pre-allocate data arrays
hcent = zeros(2,30);
hdata = zeros(2,30);

% load data manually this time (we don't have time to make a fancy script)
load([hdir,'Hist_DBV_FLAIR_svb.mat']);
hcent(1,:) = HC;
hdata(1,:) = HD;

% load([hdir,'Hist_DBV_noFLAIR_1TE_svb.mat']);
% hcent(2,:) = HC;
% hdata(2,:) = HD;

load([hdir,'Hist_DBV_noFLAIR_4TE_ecf.mat']);
hcent(2,:) = HC;
hdata(2,:) = HD;

clear HC HD

% now calculate means
Hv = hcent.*hdata; % weight each value by its count
mn = sum(Hv,2)./sum(hdata,2);
sd(1) = std(hcent(1,:),hdata(1,:));
sd(2) = std(hcent(2,:),hdata(2,:));

disp(['Mean Grey-Matter DBV Value (FLAIR): ',num2str(mn(1)),' +/- ',num2str(sd(1))]);
disp(['Mean Grey-Matter DBV Value (no FLAIR, 4 TEs): ',num2str(mn(2)),' +/- ',num2str(sd(2))]);