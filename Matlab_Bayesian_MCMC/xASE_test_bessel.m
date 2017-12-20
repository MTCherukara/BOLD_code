% xASE_text_bessel.m 
% Which asymptotic version most closely matches the analytical model?

clear; 
% close all;

plot_fig = 1;       

%% Model Parameters

% constants 
params.B0   = 3.0;          % T         - static magnetic field
params.dChi = 2.64e-7;      % parts     - susceptibility difference
params.gam  = 2.67513e8;    % rad/s/T   - gyromagnetic ratio

% scan parameters 
params.TE   = 0.074;        % s         - echo time

% model fitting parameters
params.S0   = 100;          % a. units  - signal
params.R2t  = 1/0.110;      % 1/s       - rate constant, tissue
params.R2e  = 4;            % 1/s       - rate constant, extracellular
params.dF   = 5;            % Hz        - frequency shift
params.lam0 = 0.00;        % no units  - ISF/CSF signal contribution
params.zeta = 0.030;        % no units  - deoxygenated blood volume
params.OEF  = 0.600;        % no units  - oxygen extraction fraction
params.Hct  = 0.340;        % no units  - fractional hematocrit


%% Compute Model

% define tau values that we want to simulate
tau = linspace(-0.032,0.032,200); % for visualising ( tau(286) = 0 )

TE  = params.TE;
np = length(tau);

% call MTC_qASE_model
[S_bessel,params] = MTC_qASE_modelB(tau,TE,params);
[S_10,params] = MTC_qASE_model(tau,TE,params);
[S_15,params] = MTC_qASE_model15(tau,TE,params);



%% plot figure
if plot_fig
    
    % create a figure
    figure;
    set(gcf,'WindowStyle','docked');
    hold on; box on;

    % plot the signal
    plot(1000*tau,log(S_bessel),'-','LineWidth',3);
    plot(1000*tau,log(S_10),':','LineWidth',3);
    plot(1000*tau,log(S_15),'--','LineWidth',3);
    xlim([-36,36]);

    
    % labels on axes
    xlabel('Spin Echo Displacement \tau (ms)');
    ylabel('Signal');
    title(['OEF = ',num2str(params.OEF),', DBV = ',num2str(params.zeta)]);
    legend('Analytical','1.0 Tc','1.5 Tc','Location','NorthEast');
    set(gca,'FontSize',18);
    
end % if plot_fig

    