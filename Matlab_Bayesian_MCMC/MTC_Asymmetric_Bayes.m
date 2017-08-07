% MTC_Asymmetric_Bayes.m
% Perform Bayesian inference on ASE/BOLD data from MTC_qBOLD.m using a 1D
% or 2D grid search
%
% Based on MTC_Bayes_BOLD.m
%
% 
%       Copyright (C) University of Oxford, 2016-2017
%
% 
% Created by MT Cherukara, 17 May 2016
%
% CHANGELOG:
%
% 2017-08-07 (MTC). Added R2'/DBV inference, and made the whole thing
%       better organised. The 1D grid search isn't working right, but it
%       isn't particularly important at this stage.
%
% 2017-04-04 (MTC). Various changes.

clear;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inference Parameters
np = 100; % number of points to perform Bayesian analysis on


% Select which parameter(s) to infer on (1 = OEF, 2 = DBV, 3 = R2')
p1 = 3;
p2 = 2; % setting p2 to 0 will infer on only p1 (1D grid search)

% Load the Data:
load('ASE_R2p_DBV_SNR_1000.mat');

% extract relevant parameters
sigma = params.sig;   % real std of noise
sigma_weight = 2/(sigma.^2);
ns = length(S_sample); % number of data points
[~,t0] = min(abs(T_sample));    % index of zero-point
params.R2p = params.dw.*params.zeta;

% Parameter names and search ranges
pnames  = { 'OEF'  ; 'zeta' ; 'R2p' };
intervs = [ 0, 1   ; 0, 0.1 ; 1, 6  ];  
%            OEF      DBV      R2'

% are we inferring on R2'?
if (p1 == 3 || p2 == 3)
    noDW = 1; % this changes what happens in MTC_qASE_model.m
else
    noDW = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inference
if ~p2
    % Bayesian inference on a single parameter using 1D grid search
    
    pname = pnames{p1}; % the name of the parameter being searched over
    
    v_t = eval(['params.',pname]); % true value of parameter
    va = linspace(intervs(p1,1),intervs(p1,2),np); 
    S_model = zeros(np,ns);

    % step through values of the parameter and calculate the model for each one
    % of those, at all time points
    for ii = 1:np
        params = param_update(va(ii),params,pname);
        S_val = MTC_qASE_model(T_sample,params);
        S_model(ii,:) = S_val./S_val(t0);
    end

    S_samp = repmat(S_sample,np,1);

    % compare the model against the data for each value of the parameter - this
    % is the likelihood (which is proportional to the posterior in the case of
    % uniform (zero) priors)
    lik = exp(-sum((S_samp-S_model).^2,2)/sigma);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else % if ~p2
    % Bayesian Inference on two parameters, using grid search
    
    pname = {pnames{p1}; pnames{p2}};

    tr1 = eval(['params.',pname{1}]); % true value of parameter 1
    tr2 = eval(['params.',pname{2}]); % true value of parameter 1

    w1 = linspace(intervs(p1,1),intervs(p1,2),np);
    w2 = linspace(intervs(p2,1),intervs(p2,2),np);

    pos = zeros(np,np);

    for i1 = 1:np
        % loop through parameter 1
        params = param_update(w1(i1),params,pname{1});

        for i2 = 1:np
            % loop through parameter 2
            params = param_update(w2(i2),params,pname{2});

            % run the model to evaluate the signal with current params
            S_mod = MTC_qASE_model(T_sample,params,noDW);

            % calculate posterior based on known noise value
            pos(i1,i2) = exp(-sum((S_sample-S_mod).^2)./(sigma));
            
        end % for i2 = 1:np
    end % for i1 = 1:np

end % if ~p2 // else ...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Display Results

% create docked figure
figure('WindowStyle','docked');
hold on; box on;
set(gca,'FontSize',16);

if (p2 == 0)
    % Plot 1D grid search results
    
    plot([v_t, v_t],[0, 1.1*max(lik)],'k--','LineWidth',2);
    plot(va,lik,'-','LineWidth',4);
    axis([min(va), max(va), 0, 1.1*max(lik)]);

    xlabel(pname);
    legend(['True ',pname],'Posterior','Location','NorthEast');
    
else % if (inftype == 1)
    % Plot 2D grid search results
    
    imagesc(w2,w1,pos); hold on;
    c=colorbar;
    plot([tr2,tr2],[  0, 30],'w-','LineWidth',2);
    plot([  0, 30],[tr1,tr1],'w-','LineWidth',2);
    
    xlabel(pname{2});
    ylabel(pname{1});
    
    ylabel(c,'Posterior Probability Density');
    
    axis([min(w2),max(w2),min(w1),max(w1)]);
    set(gca,'YDir','normal');
    set(c,'FontSize',16);
    
end % if (inftype == 1) // else ...

    
