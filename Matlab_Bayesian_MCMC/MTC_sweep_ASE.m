% MTC_sweep_ASE.m

% Quantitative Asymmetric Spin Echo Sequence Simulation, sweeping through
% multiple parameter values

% MT Cherukara
% 17 May 2016


clear; close all;

%% Model Parameters
% constants 
params.B0   = 3.0;          % T         - static magnetic field
params.dChi = 0.264e-6;     % parts     - susceptibility difference
params.gam  = 2.67513e8;    % rad/s/T   - gyromagnetic ratio
params.di   = [1 1 1].*1e-3;% m         - voxel length (assume square)
params.Gi   = [0 1.0e-5 0]; % T/m       - magnetic field gradient (based on vessels)
params.nHb  = 5.5e-6;       % M/mL      - intracellular Hb concentration
params.nb   = 0.66;         % no units  - blood hemoglobin concentration (fraction)
params.T1b  = 1.627;        % s         - T1 of blood
params.T1t  = 1.331;        % s         - T1 of grey matter (tissue)
params.T1e  = 4.163;        % s         - T1 of CSF (extracellular)
params.dHb  = 9.7e-6;       % M         - conc(deoxyhaemoglobin)
params.DR2  = 2.5;          % 1/s       - D/(R^2)

% scan parameters 
params.TR   = 5;            % s         - repetition time
params.TE   = 0.060;        % s         - echo time
params.alph = 90;           % degrees   - flip angle

% model fitting parameters
params.S0   = 1;            % a. units  - signal
params.R2t  = 15;           % 1/s       - rate constant, tissue
params.R2e  = 5;            % 1/s       - rate constant, extracellular
params.dF   = 5;            % Hz        - frequency shift
params.lam0 = 0.100;        % no units  - ISF/CSF signal contribution
params.zeta = 0.050;        % no units  - deoxygenated blood volume
params.OEF  = 0.500;        % no units  - oxygen extraction fraction
params.Hct  = 0.40;         % no units  - fractional hematocrit

np = 100;
tau = linspace(-0.01,0.03,np);

% intialise figure
figure(1); hold on;
% plot([0 0],[0 1],'k--'); hold on;
xlabel('\pi-pulse offset \tau (ms)');
ylabel('Signal (a.u.)');
% axis([-10 30 0 1]);
set(gca,'FontSize',16);

figure(2); hold on;
% plot([0 0],[0 1],'k--'); hold on;
xlabel('\pi-pulse offset \tau (ms)');
ylabel('Signal (a.u.)');
% axis([-10 30 0 1]);
set(gca,'FontSize',16);

% variables to sweep
OEF = [0.3, 0.4, 0.5, 0.6, 0.7];
lam = [0.02 0.05 0.08 0.11 0.14];
zet = [0.01 0.02 0.03 0.04 0.05];
R2t = [10   15   20   25   30];
dF  = [3,   4,   5,   6,   7];
R2e = [2,   4,   6,   8,   10];

S_all = zeros(5,np);
S_ext = zeros(5,np);

for ii = 1:5
    params.R2t = R2t(ii);

    % relaxation rate constant of blood
    params.R2b  = 14.9*params.Hct + 14.7 + (302.1*params.Hct + 41.8)*params.OEF^2;
    params.R2bs = 16.4*params.Hct + 4.5  + (165.2*params.Hct + 55.7)*params.OEF^2;

    % magnetisation of blood
    params.mb   = MTC_BOLD_M(params.T1b,1./params.R2b,params.TR,params.TE,params.alph);

    % fraction of signal expressed by blood
    params.lamb = params.mb.*params.nb.*(1-params.lam0).*params.zeta;

    % calculate characteristic frequency
    params.dw   = (4/3)*pi*params.gam*params.dChi*params.Hct*params.OEF*params.B0;

    % compartment weightings
    w_tis = 1 - params.lam0 - params.zeta;
    w_csf = params.lam0;
    w_bld = params.zeta;
    
    % calculate compartments
    S_tis = w_tis.*MTC_ASE_tissue(tau,params);
    S_csf = w_csf.*MTC_ASE_extra(tau,params);
    S_bld = w_bld.*MTC_ASE_blood(tau,params);

%     % normalize
%     S_tis = S_tis./max(S_tis);
%     S_csf = S_csf./max(S_csf);
%     S_bld = S_bld./max(S_bld);

    % add it all together:
%     S_total = ((1 - params.lam0 - params.zeta).*S_tis) + (params.lam0.*S_csf) .* (params.zeta.*S_bld);
    S_total = S_tis + S_csf + S_bld;
    S_all(ii,:) = S_total;  % save out total signal
    S_ext(ii,:) = S_csf;    % save out CSF signal

    % plot figure
    figure(1);
    plot(tau*1000,S_total,'-','LineWidth',2);
    plot(tau*1000,S_tis,'--','LineWidth',2);
    
    figure(2);
    plot(tau*1000,S_csf,'LineWidth',2);
end