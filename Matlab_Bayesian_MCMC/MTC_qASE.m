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
%       its contents here, so that the whole thing is more modular.
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

plot_fig = 1;       
save_plot = 1;      % set to 1 in order to save out ASE data


%% Model Parameters
% noise
SNR = 100;
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
params.lam0 = 0.000;        % no units  - ISF/CSF signal contribution
params.zeta = 0.030;        % no units  - deoxygenated blood volume
params.OEF  = 0.400;        % no units  - oxygen extraction fraction
params.Hct  = 0.340;        % no units  - fractional hematocrit


%% Compute Model

% define tau values that we want to simulate
tau = (-16:4:64)/1000;      % for simulating data
% tau = (-36:4:36)/1000;
% tau = linspace(-0.016,0.064,1000); % for visualising ( tau(286) = 0 )
np = length(tau);

% call MTC_qASE_model
S_total = MTC_qASE_model(tau,params);

%% Add Noise
% Add noise that is proportional to the maximum
% Noise = max(S_total).*params.sig.*randn(1,np);
T_sample = tau;
S_sample = S_total + max(S_total).*params.sig.*randn(1,np);

[~,int0] = find(tau>=0,1);

S_norm = S_total; % don't normalise

%% plot figure
if plot_fig
    fig1 = figure('WindowStyle','docked');
    hold on; box on;
    
    % plot some lines
    plot([0 0],[-1 2],'k--','LineWidth',2);
    
    % plot the signal compartments
    l.s = plot(1000*tau,S_norm,'-','LineWidth',4);
    l.t = plot(1000*tau,(1-params.zeta)*S_tis./max(S_tis),'g-','LineWidth',4);
    l.b = plot(1000*tau,params.zeta*S_bld./max(S_bld),    '-','LineWidth',4);
    
    % labels on axes
    xlabel('Spin Echo Displacement \tau (ms)');
    ylabel('Signal');
    title('qBOLD Signal Measured Using ASE');
    % title(['Asymmetric Spin Echo Signal, SNR = ',num2str(1/sigma)]);
    axis([1000*min(tau), 1000*max(tau), -0.1, 1.1]);
    legend([l.s,l.t,l.b],'Total Signal','Parenchyma','Venous Blood','Location','NorthEast');
    set(gca,'FontSize',18);


    % Save Figure
    if save_plot
        fig_dir = '/Users/mattcher/Documents/Project_1/Figures/';
        fig_title1 = strcat('ASE_signal_',date,'_');
        fig_list = dir(strcat(fig_dir,fig_title1,'*'));
        fn = length(fig_list) + 1;

%         fig_title = strcat(fig_dir,fig_title1,num2str(fn),'.png');
%         saveas(fig1,fig_title);

        dat_title = strcat('ASE_signal_data_',date,'_',num2str(fn));
        save(dat_title,'T_sample','S_sample','params');
    end
else % if plot_fig
    
    figure('WindowStyle','docked');
    hold on; box on;
    plot(1000*tau,S_norm,'k-');
    plot(1000*T_sample,S_sample,'x');
    
end % if plot_fig