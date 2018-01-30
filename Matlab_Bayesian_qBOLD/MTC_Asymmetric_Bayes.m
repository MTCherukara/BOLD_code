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
% 2018-01-12 (MTC). Changed the way the posterior is calculated to actually
%       calculate log-likelihood, using the function MTC_loglike.m. This
%       technically shouldn't alter the shape of any of the posterior
%       distributions (in terms of their linearity) but should mean that
%       our selected value of SNR is 'applied' to the results correctly.
%
% 2017-10-06 (MTC). Added the option to make a 3D grid search, and made the
%       1D and 2D versions slightly more general (and less cumbersome) by
%       vectorising here and there.
%
% 2017-08-07 (MTC). Added R2'/DBV inference, and made the whole thing
%       better organised. The 1D grid search isn't working right, but it
%       isn't particularly important at this stage.
%
% 2017-04-04 (MTC). Various changes.

clear;
% close all;
tic;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%    Initialization          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inference Parameters

np = 1000; % number of points to perform Bayesian analysis on
nz = 41; % number of points in the third dimension

% Select which parameter(s) to infer on (1 = OEF, 2 = DBV, 3 = R2', 4 = CSF, 5 = dF)
pars = [1,2];

% Load the Data:
load('ASE_Data/Data_180130_SNR_200.mat');

% extract relevant parameters
sigma = mean(params.sig);   % real std of noise
ns = length(S_sample); % number of data points
[~,t0] = min(abs(T_sample));    % index of zero-point
params.R2p = params.dw.*params.zeta;

if ~exist('TE_sample','var')
    TE_sample = params.TE;
end

% Parameter names and search ranges
pnames  = { 'OEF' ; 'zeta'     ; 'R2p' ; 'lam0'    ; 'dF' };
intervs = [ 0.001,1   ; 0.001,0.1 ; 2,7   ; 0.0,0.2 ; 1,10 ];  
%            OEF     DBV        R2'     v_CSF      dF 

% are we inferring on R2'?
if sum(pars == 3) > 0
    noDW = 1; % this changes what happens in MTC_qASE_model.m
else
    noDW = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%    1D Line Search          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inference
if length(pars) == 1
    % Bayesian inference on a single parameter using 1D grid search
    
    pn = pars(1); % pull out the parameter's number
    pname = pnames{pn}; % the name of the parameter being searched over
    
    trv = eval(['params.',pname]); % true value of parameter
    vals = linspace(intervs(pn,1),intervs(pn,2),np); 
    S_mod = zeros(np,ns);
    
    % step through values of the parameter and calculate the model for each one
    % of those, at all time points
    for ii = 1:np
        params = param_update(vals(ii),params,pname);
        S_val = MTC_qASE_model(T_sample,TE_sample,params);
        S_mod(ii,:) = S_val./S_val(t0);
    end

    S_samp = repmat(S_sample,np,1);

    % compare the model against the data for each value of the parameter - this
    % is the likelihood (which is proportional to the posterior in the case of
    % uniform (zero) priors)
    loglik = - (0.5.*ns.*log(2.*pi.*(sigma.^2))) ...
             - ((0.5./(sigma.^2)).*(sum(S_samp-S_mod,2).^2));
    
	pos = loglik';
%     pos = exp(-sum((S_samp-S_mod).^2,2)/sigma);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%    2D Grid Search          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif length(pars) == 2
    % Bayesian Inference on two parameters, using grid search
    
    % pull out parameter numbers
    p1 = pars(1);
    p2 = pars(2);
    pname = {pnames{p1}; pnames{p2}};

    trv(1) = eval(['params.',pname{1}]); % true value of parameter 1
    trv(2) = eval(['params.',pname{2}]); % true value of parameter 2

    vals(1,:) = linspace(intervs(p1,1),intervs(p1,2),np);
    vals(2,:) = linspace(intervs(p2,1),intervs(p2,2),np);

    pos = zeros(np,np);

    for i1 = 1:np
        % loop through parameter 1
        params = param_update(vals(1,i1),params,pname{1});

        for i2 = 1:np
            % loop through parameter 2
            params = param_update(vals(2,i2),params,pname{2});

            % run the model to evaluate the signal with current params
            S_mod = MTC_qASE_model(T_sample,TE_sample,params,noDW);

            % calculate posterior based on known noise value
            pos(i1,i2) = MTC_loglike(S_sample,S_mod,sigma);
            
        end % for i2 = 1:np
    end % for i1 = 1:np
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%    3D Grid Search          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif length(pars) == 3
    % Bayesian inference on 3 parameters, using a very long grid-search
    
    p1 = pars(1);
    p2 = pars(2);
    p3 = pars(3);
    pname = {pnames{p1}; pnames{p2}; pnames{p3}};
    
    trv(1) = eval(['params.',pname{1}]); % true value of parameter 1
    trv(2) = eval(['params.',pname{2}]); % true value of parameter 2
    trv(3) = eval(['params.',pname{3}]); % true value of parameter 3
    
    vals(1,:) = linspace(intervs(p2,1),intervs(p2,2),np);
    vals(2,:) = linspace(intervs(p3,1),intervs(p3,2),np);
    valz = linspace(intervs(p1,1),intervs(p1,2),nz); % third (smaller) dimension
    
    pos = zeros(nz,np,np);
    
    for i1 = 1:nz
        % loop through parameter 1
        params = param_update(valz(1,i1),params,pname{1});
        disp(['Iterating ',num2str(i1),' of ',num2str(nz)]);

        for i2 = 1:np
            % loop through parameter 2
            params = param_update(vals(1,i2),params,pname{2});

            for i3 = 1:np
                % loop through parameter 3
                params = param_update(vals(2,i3),params,pname{3});

                % run the model to evaluate the signal with current params
                S_mod = MTC_qASE_model(T_sample,TE_sample,params,noDW);

                % calculate posterior based on known noise value
                pos(i1,i2,i3) = exp(-sum((S_sample-S_mod).^2)./(sigma));
                
            end % for i3 = 1:np
        end % for i2 = 1:np
    end % for i1 = 1:np
    
    % When doing a 3D grid search, we're always going to want to save the
    % results (just in case!)
    save('Grid3D_temp_001','pos','params','T_sample','TE_sample','S_sample','trv','vals','vals');

end % length(pars) == 1 ... elseif ... elseif ...

toc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Display Results

% create docked figure
figure('WindowStyle','docked');
hold on; box on;
set(gca,'FontSize',18);

if length(pars) == 1
    % Plot 1D grid search results
    
%     plot([trv, trv],[0, 1.1*max(pos)],'k--','LineWidth',2);
    plot(vals,exp(pos),'-','LineWidth',4);
%     axis([min(vals), max(vals), 0, 1.1*max(pos)]);

    xlabel(pname);
    legend(['True ',pname],'Posterior','Location','NorthEast');
    
elseif length(pars) == 2 
    % Plot 2D grid search results
    
    Pscale = [quantile(pos(:),0.75), max(pos(:))];
    imagesc(vals(2,:),vals(1,:),(pos),Pscale); hold on;
    c=colorbar;
    plot([trv(2),trv(2)],[  0, 30],'w-','LineWidth',2);
    plot([  0, 30],[trv(1),trv(1)],'w-','LineWidth',2);
    
    xlabel(pname{2});
    ylabel(pname{1});
    
    ylabel(c,'Posterior Probability Density');
    
    axis([min(vals(2,:)),max(vals(2,:)),min(vals(1,:)),max(vals(1,:))]);
    set(gca,'YDir','normal');
    set(c,'FontSize',19);
    
end % if length(pars) == 1 ... elseif ...
