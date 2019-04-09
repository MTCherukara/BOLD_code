% xNewModelTesting.m

% Testing a new qBOLD model using simulated Sharan data

% MT Cherukara
% 9 April 2019

clear;
close all;

setFigureDefaults;

% Load in a nice dataset
load('../../Data/vesselsim_data/vs_arrays/TE84_vsData_sharan_50.mat');

% lengths
nDBV = length(DBVvals);
nOEF = length(OEFvals);

% Extract DBV=3%, OEF=40%, to focus on
tau = tau(1:4:end);
% sig_all = squeeze(S0(10,20,1:4:end))';
sig_all = S0(:,:,1:4:end);

% define some indices
ind_SE = find(tau == 0);                % spin echo
ind_sS = find(tau >= -0.01,1,'first');  % start of short-tau regime
ind_eS = find(tau <= 0.01,1,'last');    % end of short-tau regime
ind_sL = find(tau >= 0.02,1,'first');   % start of long-tau regime

% separate out data
tau_short = tau(ind_sS:ind_eS);
tau_long = tau(ind_sL:end);

sig_short = sig_all(ind_sS:ind_eS);
log_short = log(sig_short);
sig_long = sig_all(ind_sL:end);
log_long = log(sig_long);

%% Loop around and calculate optimal short tau in each case

% pre-allocate arrays
matP1 = zeros(nDBV,nOEF);
matP2 = zeros(nDBV,nOEF);
matP3 = zeros(nDBV,nOEF);
matDBV = zeros(nDBV,nOEF);
matR2p = zeros(nDBV,nOEF);

tic;

% Loop over OEF values
for i1 = 1:nOEF
    
    % Loop over DBV values
    for i2 = 1:nDBV
        
        lOEF = OEFvals(i1);
        lDBV = DBVvals(i2);
        
        local_sig = log(squeeze(sig_all(i2,i1,ind_sS:ind_eS)));
        
        fres = fit(tau_short',local_sig,'poly2');
        
        matP1(i2,i1) = fres.p1;
        matP2(i2,i1) = fres.p2;
        matP3(i2,i1) = fres.p3;
        
        matDBV(i2,i1) = lDBV;
        matR2p(i2,i1) = 887.4*0.4*lOEF*lDBV;
        
    end % DBV loop
    
end % OEF loop

toc;


%% Visualize the Results

% surface plot of P1
figure; box on;
surf(100*DBVvals,100*OEFvals,matP1);
view(2); shading flat;
ylim([21,70]);
xlim([0.3,15]);

% surface plot of P2
figure; box on;
surf(100*DBVvals,100*OEFvals,matP2);
view(2); shading flat;
ylim([21,70]);
xlim([0.3,15]);

% surface plot of P3
figure; box on;
surf(100*DBVvals,100*OEFvals,matP3);
view(2); shading flat;
ylim([21,70]);
xlim([0.3,15]);