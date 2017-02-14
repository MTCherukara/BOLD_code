% MTC_qASE.m

% Quantitative Asymmetric Spin Echo Sequence Simulation. Generates data to
% be used in Bayesian inference on parameters (MTC_Asymmetric_Bayes.m and
% others). Based on MTC_qBOLD.m 

% MT Cherukara
% 17 May 2016 (origin)
%
% 27 May 2016 - Changed the way the compartments are added together, which
% was apparently causing problems (I don't know why).
%
% 8 Nov 2016 (MTC) - Changed tau range to go up to 64 ms, changed some
% other constants, added saving out of data sampled at key points, with
% noise added in too.

clear; 
% close all;

% set it to 1 in order to save out ASE data
save_plot = 0;


%% Model Parameters
% noise
params.sig  = 0.02;         % -         - noise standard deviation
% constants 
params.B0   = 3.0;          % T         - static magnetic field
params.dChi = 2.64e-7;      % parts     - susceptibility difference
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
params.TR   = 3;            % s         - repetition time
params.TE   = 0.074;        % s         - echo time
params.alph = 90;           % degrees   - flip angle

% model fitting parameters
params.S0   = 1;            % a. units  - signal
params.R2t  = 6;            % 1/s       - rate constant, tissue
params.R2e  = 4;            % 1/s       - rate constant, extracellular
params.dF   = 5;            % Hz        - frequency shift
params.lam0 = 0.100;        % no units  - ISF/CSF signal contribution
params.zeta = 0.030;        % no units  - deoxygenated blood volume
params.OEF  = 0.400;        % no units  - oxygen extraction fraction
params.Hct  = 0.40;         % no units  - fractional hematocrit


%% Calculate values for remaining parameters

% relaxation rate constant of blood
params.R2bs = 14.9*params.Hct + 14.7 + (302.1*params.Hct + 41.8)*params.OEF^2;
params.R2b  = 16.4*params.Hct + 4.5  + (165.2*params.Hct + 55.7)*params.OEF^2;

% magnetisation of blood
params.mb   = MTC_BOLD_M(params.T1b,1./params.R2b,params.TR,params.TE,params.alph);

% fraction of signal expressed by blood
params.lamb = params.mb.*params.nb.*(1-params.lam0).*params.zeta;

% calculate characteristic frequency
params.dw   = (4/3)*pi*params.gam*params.dChi*params.Hct*params.OEF*params.B0;


%% Compute Model

% tau = (-16:4:64)/1000;      % for simulating data
tau = linspace(-0.016,0.064,1000); % for visualising ( tau(286) = 0 )
np = length(tau);

% compartment weightings
w_tis = 1 - params.lam0 - params.zeta;
w_csf = params.lam0;
w_bld = params.zeta;

% calculate compartments
S_tis = w_tis.*MTC_ASE_tissue(tau,params);
S_csf = w_csf.*MTC_ASE_extra(tau,params);
S_bld = w_bld.*MTC_ASE_blood(tau,params);

% add it all together:
% S_total = params.S0.*(S_tis + S_csf + S_bld);
S_total = params.S0.*(S_tis + S_bld);

% Add noise that is proportional to the maximum
% Noise = max(S_total).*params.sig.*randn(1,np);
T_sample = tau;
S_sample = S_total + max(S_total).*params.sig.*randn(1,np);

[~,int0] = find(tau>0,1);

S_norm = S_total./S_total(int0);
S_sample = S_sample./S_total(int0);

% plot figure
fig1 = figure(1); clf;
plot([0 0],[-1 2],'k--'); hold on;        % zero line
l_tis = plot(tau*1000,(1-params.zeta)*S_tis./max(S_tis),'b--','LineWidth',2);
% l_csf = plot(tau*1000,S_csf,'b:','LineWidth',2);
l_bld = plot(tau*1000,params.zeta*S_bld./max(S_bld),'r:','LineWidth',2);
l_tot = plot(tau*1000,S_norm,'k-','LineWidth',2);
% plot(T_sample*1000,S_sample,'bx','LineWidth',2);
xlabel('\pi-pulse offset \tau (ms)');
ylabel('Signal');
% title(['Asymmetric Spin Echo Signal, SNR = ',num2str(1/sigma)]);
axis([1000*min(tau), 1000*max(tau), -0.1, 1.2]);
legend([l_tot,l_tis,l_bld],'Total Signal','Tissue','Blood');
set(gca,'FontSize',16);


%% Save Figure
if save_plot == 1
    fig_dir = '/Users/mattcher/Documents/Project_1/Figures/';
    fig_title1 = strcat('ASE_signal_',date,'_');
    fig_list = dir(strcat(fig_dir,fig_title1,'*'));
    fn = length(fig_list) + 1;
    
    fig_title = strcat(fig_dir,fig_title1,num2str(fn),'.png');
    dat_title = strcat('Simulated_Data/ASE_signal_data_',date,'_',num2str(fn));
    
    save(dat_title,'T_sample','S_sample','params');
    saveas(fig1,fig_title);
end
