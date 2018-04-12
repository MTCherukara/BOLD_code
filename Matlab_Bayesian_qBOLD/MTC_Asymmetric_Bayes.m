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
% 2018-03-29 (MTC). Added the means for displaying the locations of the maximum
%       values produced by a 2D grid search.
%
% 2018-02-12 (MTC). Went back to 'param_update' since it is actually much
%       faster. Removed the 3D grid search code because it was taking up space
%       (it will be in the repository somewhere).
%
% 2018-02-05 (MTC). Removed the need for the 'param_update' function. Fixed a
%       bug in the 1D grid search method.
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
close all;

% setFigureDefaults;  % since we're doing plotting later

tic;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%    Initialization          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inference Parameters

np = 500; % number of points to perform Bayesian analysis on
nz = 41; % number of points in the third dimension

% Select which parameter(s) to infer on
%       (1 = OEF, 2 = DBV, 3 = R2', 4 = CSF, 5 = dF, 6 = geom)
pars = [3,2];

% Load the Data:
load('ASE_Data/Data_180412_DBV_5.mat');

params.tc_man = 1;
params.tc_val = 0.03;

% extract relevant parameters
sigma = mean(params.sig);   % real std of noise
ns = length(S_sample); % number of data points
params.R2p = params.dw.*params.zeta;
truepars = params;

if ~exist('TE_sample','var')
    TE_sample = params.TE;
end

% Parameter names and search ranges
pnames  = { 'OEF'   ;  'zeta'    ; 'R2p' ; 'lam0'  ; 'dF' ; 'geom'  };
intervs = [ 0.001,1 ; 0.03,0.13 ; 10,12 ; 0.0,0.2 ; 1,10 ; 0.1,0.5 ];  
%            OEF     DBV        R2'     v_CSF      dF       Geom

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
    pos = zeros(1,np);
    
    % step through values of the parameter and calculate the model for each one
    % of those, at all time points
    for ii = 1:np
        
        % update parameter
        params = param_update(vals(ii),params,pname);

        % evaluate model
        S_val = MTC_qASE_model(T_sample,TE_sample,params,noDW);
      
        % calculate log likelihood
        pos(ii) = MTC_loglike(S_sample,S_val,sigma);

        
    end

    
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
    
end % length(pars) == 1 ... elseif 

toc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Display Results

% create docked figure
figure; hold on; box on;

if length(pars) == 1
    % Plot 1D grid search results
    
%     plot([trv, trv],[0, 1.1*max(pos)],'k--','LineWidth',2);
    plot(vals,exp(pos),'-','LineWidth',4);
%     axis([min(vals), max(vals), 0, 1.1*max(pos)]);

    xlabel(pname);
    legend('Posterior','Location','NorthEast');
    
elseif length(pars) == 2 
    % Plot 2D grid search results
    
    Pscale = [quantile(pos(:),0.95), max(pos(:))];
    imagesc(vals(2,:),vals(1,:),exp(pos)); hold on;
    c=colorbar;
    colormap('parula');
    plot([trv(2),trv(2)],[  0, 30],'w-');
    plot([  0, 30],[trv(1),trv(1)],'w-');
    
    xlabel(pname{2});
    ylabel(pname{1});
    
    ylabel(c,'Posterior Probability Density');
%     ylabel(c,'Log Likelihood');
    
    axis([min(vals(2,:)),max(vals(2,:)),min(vals(1,:)),max(vals(1,:))]);
    set(gca,'YDir','normal');
    set(c,'FontSize',19);
    
    % Calculate distribution's maximum position in 2D
    [V2G,V1G] = meshgrid(vals(2,:),vals(1,:));
    [~,mi] = max(pos(:));
    disp('  ');
    disp([  'OEF = ',num2str(truepars.OEF),...
          ', DBV = ',num2str(100*truepars.zeta),...
          ', Tc = ',num2str(1000*params.tc_val),'ms']);
    disp(['  Maximum ',pname{1},': ',num2str(V1G(mi),4)]);
    disp(['  Maximum ',pname{2},': ',num2str(100*V2G(mi),4)]);
    
end % if length(pars) == 1 ... elseif ...
