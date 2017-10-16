% MTC_qASE.m
%
% Quantitative Asymmetric Spin Echo Sequence Simulation. Generates data to
% be used in Bayesian inference on parameters (MTC_Asymmetric_Bayes.m and
% others). Based on MTC_qBOLD.m 
%
% 
%       Copyright (C) University of Oxford, 2016-2017
%
% 
% Created by MT Cherukara, 17 May 2016
%
% CHANGELOG:
%
% 2017-08-07 (MTC). Added a call to MTC_qASE_model, rather than repeating
%       its contents here, so that the whole thing is more modular. Removed
%       the automatic saving of the plot, as it's kind of unnecessary
%
% 2017-04-04 (MTC). Modified the plotting parameters, removed a bunch of
%       unnecessary variables from the params struct.
%
% 2016-11-08 (MTC). Changed tau range to go up to 64 ms, changed some
%       other constants, added saving out of data sampled at key points,
%       with noise added in too.
%
% 2016-05-27 (MTC). Changed the way the compartments are added together,
%       which was apparently causing problems (I don't know why).

clear; 
% close all;

plot_fig = 0;       
save_data = 1;      % set to 1 in order to save out ASE data


%% Model Parameters
% noise
SNR = 1000;
params.sig  = 1/SNR;         % -         - noise standard deviation
% constants 
params.B0   = 3.0;          % T         - static magnetic field
params.dChi = 2.64e-7;      % parts     - susceptibility difference
params.gam  = 2.67513e8;    % rad/s/T   - gyromagnetic ratio

% scan parameters 
params.TE   = 0.074;        % s         - echo time

% model fitting parameters
params.S0   = 1;            % a. units  - signal
params.R2t  = 1/0.110;      % 1/s       - rate constant, tissue
params.R2e  = 4;            % 1/s       - rate constant, extracellular
params.dF   = 5;            % Hz        - frequency shift
params.lam0 = 0.050;        % no units  - ISF/CSF signal contribution
params.zeta = 0.050;        % no units  - deoxygenated blood volume
params.OEF  = 0.400;        % no units  - oxygen extraction fraction
params.Hct  = 0.340;        % no units  - fractional hematocrit


%% Compute Model

% define tau values that we want to simulate
% tau = (-16:8:64)/1000;      % for simulating data

% tau = (-8:2:8)/1000;
% tau = linspace(-0.016,0.064,1000); % for visualising ( tau(286) = 0 )

tau = [-16, -8,  0,  8, 16, 32, 48, 64,  0,   0,   0,   0]./1000;
TE  = [ 80, 80, 80, 80, 80, 80, 80, 80, 40, 120, 200, 280]./1000;

np = length(tau);

% call MTC_qASE_model
[S_total,params] = MTC_qASE_model(tau,TE,params);


%% Add Noise
% Add noise that is proportional to the maximum
% Noise = max(S_total).*params.sig.*randn(1,np);
T_sample = tau;
S_sample = S_total + max(S_total).*params.sig.*randn(1,np);

[~,int0] = find(tau>=0,1);


%% plot figure
if plot_fig
    
    % create a figure
    fig1 = figure('WindowStyle','docked');
    hold on; box on;
    
    % plot some lines
%     plot([0 0],[-1 2],'k--','LineWidth',2);
    
    % plot the signal
    S_log = (S_total);
    l.s = plot(1000*tau,S_log,'-','LineWidth',3);
    
    % labels on axes
    xlabel('Spin Echo Displacement \tau (ms)');
    ylabel('Signal');
    title('qBOLD Signal Measured Using ASE');
%     axis([1000*min(tau), 1000*max(tau), -1, -0.6]);
    set(gca,'FontSize',18);
    
end % if plot_fig

% Save Figure
if save_data
    % Check how many datasets have been saved with the same date
    dat_dir = '/Users/mattcher/Documents/DPhil/Code/Matlab_Bayesian_MCMC';
    dat_title1 = strcat('ASE_signal_',date,'_');
    dat_list = dir(strcat(dat_dir,dat_title1,'*'));
    fn = length(dat_list) + 1;
    
    % Assign the correct title
    dat_title = strcat(dat_title1,num2str(fn));
    
    if length(TE) ~= length(tau)
        TE_sample(1:length(tau)) = params.TE;
    else
        TE_sample = TE;
    end
    
    % Save the data out
    save(dat_title,'T_sample','S_sample','TE_sample','params');
end % if save_data
    