% xCompare_Fabber.m
% for comparing fabber results with the analytical model

clear; close all;

% select subject
ss = 2;

% load FABBER result data
load('ASE_Data/Fabber_VS_14t_1C.mat');

% other FABBER data
fS0  = [148, 145, 128, 153, 188, 165, 188];
fR2p = [3.65, 4.48, 3.55, 4.07, 3.87, 3.99, 3.29];
fDBV = [5.28, 7.80, 5.29, 7.17, 7.54, 6.23, 5.44]./100;

% Constants
params.B0   = 3.0;          % T         - static magnetic field
params.dChi = 2.64e-7;      % parts     - susceptibility difference
params.gam  = 2.67513e8;    % rad/s/T   - gyromagnetic ratio
params.TE   = 0.074;        % s         - echo time
params.R2t  = 0;            % 1/s       - rate constant, tissue
params.R2e  = 0;            % 1/s       - rate constant, extracellular
params.dF   = 5;            % Hz        - frequency shift
params.lam0 = 0.000;        % no units  - ISF/CSF signal contribution
params.Hct  = 0.340;        % no units  - fractional hematocrit

% FABBER-related variables
params.S0 = fS0(ss);
params.zeta = fDBV(ss);
params.OEF = fR2p(ss)./(301.74.*fDBV(ss));

% tau ranges
tauF = [0, 16:4:64]/1000;
tauA = linspace(-16,64,1000)/1000;

% calculate qASE model
S_fab = voldata(ss,:);
[S_ana,params] = MTC_qASE_model(tauA,params.TE,params);

% plot results
figure(2);
set(gcf,'WindowStyle','docked');
hold on; box on;

plot(1000*tauA,log(S_ana),'-','LineWidth',2);
plot(1000*tauF,log(S_fab),'kx','LineWidth',2);

xlabel('Spin-Echo Offset \tau (ms)');
ylabel('Log(Signal)');
set(gca,'FontSize',18);



