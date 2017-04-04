% MTC_qBOLD.m
%
% Generates plots of BOLD signal over time, based on MTC_qASE.m, which in
% turn is based on an older script, also named MTC_qBOLD.
%
% NB. CSF compartment is completely ignored here
%
% 
%       Copyright (C) University of Oxford, 2016-2017
%
% 
% Created by MT Cherukara, 4 April 2017
%
% CHANGELOG:

clear; 
close all;

% set it to 1 in order to plot a figure
plot_fig = 1;


%% Model Parameters
% noise
params.sig  = 0.01;         % -         - noise standard deviation
% constants 
params.B0   = 3.0;          % T         - static magnetic field
params.dChi = 2.64e-7;      % parts     - susceptibility difference
params.gam  = 2.67513e8;    % rad/s/T   - gyromagnetic ratio

% scan parameters 
params.TE   = 0.074;        % s         - echo time
params.tau  = -0.01;        % s         - 90 pulse displacement

% model fitting parameters
params.S0   = 1;            % a. units  - signal
params.R2t  = 1/0.110;      % 1/s       - rate constant, tissue
params.zeta = 0.075;        % no units  - deoxygenated blood volume
params.OEF  = 0.400;        % no units  - oxygen extraction fraction
params.Hct  = 0.40;         % no units  - fractional hematocrit


%% Calculate values for remaining parameters

% relaxation rate constant of blood
params.R2bs = 14.9*params.Hct + 14.7 + (302.1*params.Hct + 41.8)*params.OEF^2;
params.R2b  = 16.4*params.Hct + 4.5  + (165.2*params.Hct + 55.7)*params.OEF^2;

% calculate characteristic frequency
params.dw   = (4/3)*pi*params.gam*params.dChi*params.Hct*params.OEF*params.B0;


%% Compute Model

% tau now represents time steps from excitation (T=0) to 100 ms (TE = 0.74)
tau = linspace(0,0.1,1000);
np = length(tau);

% compartment weightings
w_tis = 1 - params.zeta;
w_bld = params.zeta;

% calculate compartments
S_tis = w_tis.*MTC_SE_tissue(tau,params);
S_bld = w_bld.*MTC_SE_blood(tau,params);

% add it all together:
S_total = params.S0.*(S_tis + S_bld);

TP = params.TE/2 + params.tau;

%% plot figure
if plot_fig

        figure('WindowStyle','docked');
        hold on; box on;
        
        % plot some lines to show the spin echo
        plot(1000*[params.TE,params.TE],[0,0.15],'k-','LineWidth',2);
        plot(1000*[params.TE,params.TE],[0.25,2],'k-','LineWidth',2);
        plot(1000*[params.TE/2,params.TE/2],[0,2],'k--','LineWidth',2);
        plot(1000*[TP,TP],[0,0.12],'k-','LineWidth',2);
        plot(1000*[TP,TP],[0.28,2],'k-','LineWidth',2);
        
        % plot the signal compartments
        l.s = plot(1000*tau,S_total,'-','LineWidth',4);
        l.t = plot(1000*tau,S_tis,'g:','LineWidth',4);
        l.b = plot(1000*tau,S_bld,'c:','LineWidth',4);
       
        % labels on the graph
        if params.tau
            text(1000*params.TE,0.2,'$$TE$$',...
                 'HorizontalAlignment','Center',...
                 'FontSize',16,...
                 'Interpreter','latex');
             text(1000*TP,0.2,'$$\frac{TE}{2}-\tau$$',...
                 'HorizontalAlignment','Center',...
                 'FontSize',16,...
                 'Interpreter','latex');
        end
        
        % label axes
        xlabel('Time (ms)');
        ylabel('Signal');
        legend([l.s,l.t,l.b],'Total','Tissue','Blood','Location','NorthEast');
        axis([0,100,0,1.1]);
        set(gca,'FontSize',18);

end