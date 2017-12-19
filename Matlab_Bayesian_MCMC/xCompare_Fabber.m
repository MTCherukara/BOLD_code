% xCompare_Fabber.m
% for comparing fabber results with the analytical model

clear; 

% select subject
ss = 1;

% load FABBER result data
load('ASE_Data/Fabber_VS_24t_2C.mat');

% % FABBER data: 14 taus, 1 compartment, SVB
% fS0  = [148, 145, 128, 153, 188, 165, 188];
% fR2p = [3.65, 4.48, 3.55, 4.07, 3.87, 3.99, 3.29];
% fDBV = [5.28, 7.80, 5.29, 7.17, 7.54, 6.23, 5.44]./100;

% FABBER data: 24 taus, 2 compartments, VB
fS0  = [351, 340, 301, 363, 443, 386, 442];
fR2p = [3.73, 4.35, 3.82, 3.96, 3.72, 4.52, 3.49];
% fDBV = [7.12, 9.72, 7.68, 7.29, 7.00, 10.19, 7.93]./100;
fDBV = [4.52, 6.55, 4.70, 4.56, 5.11, 5.68, 4.71]./100;

% Constants
params.B0   = 3.0;          % T         - static magnetic field
params.dChi = 2.64e-7;      % parts     - susceptibility difference
params.gam  = 2.67513e8;    % rad/s/T   - gyromagnetic ratio
params.TE   = 0.074;        % s         - echo time
params.R2t  = 11.5;         % 1/s       - rate constant, tissue
params.R2e  = 4.0;          % 1/s       - rate constant, extracellular
params.dF   = 5;            % Hz        - frequency shift
params.lam0 = 0.000;        % no units  - ISF/CSF signal contribution
params.Hct  = 0.340;        % no units  - fractional hematocrit

% FABBER-related variables
params.S0 = fS0(ss);
params.zeta = fDBV(ss);
params.OEF = fR2p(ss)./(301.74.*fDBV(ss));
params.dw = fR2p(ss)./fDBV(ss);

% tau ranges
% tauF = [0, 16:4:64]/1000;   % 14 taus
tauF = (-28:4:64)/1000;     % 24 taus
tauA = linspace(-28,64,100)/1000;

% calculate qASE model
S_fab = voldata(ss,:);
% S_ana = params.S0.*MTC_ASE_bessel(tauA,params.TE,params);
% S_asy = params.S0.*MTC_ASE_tissue(tauA,params.TE,params);
S_ana = MTC_qASE_model(tauA,params.TE,params);

% plot results
figure;
set(gcf,'WindowStyle','docked');
hold on; box on;

plot(1000*tauA,log(S_ana),'-','LineWidth',2);
% plot(1000*tauA,log(S_asy),'--','LineWidth',2);
plot(1000*tauF,log(S_fab),'kx','LineWidth',2);

xlabel('Spin-Echo Offset \tau (ms)');
ylabel('Log(Signal)');
set(gca,'FontSize',18);



