% xAsymmetric_Bayes_Loop.m
% Perform 2D grid-search Bayesian inference a number of times, varying a single
% parameter (TC) in a loop and storing the results.
%
% Based on MTC_Asymmetric_Bayes.m
%
% MT Cherukara
% 5 April 2018

clear;
close all;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%    Initialization          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inference Parameters

np = 600; % number of points to perform Bayesian analysis on

% Select which parameter(s) to infer on
%       (1 = OEF, 2 = DBV, 3 = R2', 4 = CSF, 5 = dF, 6 = geom)
pars = [3,2];

% Load the Data:
load('ASE_Data/Data_180412_DBV_7.mat');

params.tc_man = 1;
tcvals = (4:2:28)./1000;

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
intervs = [ 0.001,1 ; 0.05,0.17 ; 14.5,17.5 ; 0.0,0.2 ; 1,10 ; 0.1,0.5 ];  
%            OEF     DBV        R2'     v_CSF      dF       Geom

% are we inferring on R2'?
if sum(pars == 3) > 0
    noDW = 1; % this changes what happens in MTC_qASE_model.m
else
    noDW = 0;
end

% Pull out parameter info
p1 = pars(1);
p2 = pars(2);
pname = {pnames{p1}; pnames{p2}};

trv(1) = eval(['params.',pname{1}]); % true value of parameter 1
trv(2) = eval(['params.',pname{2}]); % true value of parameter 2

vals(1,:) = linspace(intervs(p1,1),intervs(p1,2),np);
vals(2,:) = linspace(intervs(p2,1),intervs(p2,2),np);

% pre-allocate results
max_R2p = zeros(length(tcvals),1);
max_DBV = zeros(length(tcvals),1);

% loop through tc values
for gg = 1:length(tcvals)
    
    % assign TC value
    params.tc_val = tcvals(gg);
    
    % print
    disp(['Running grid search for TC value ',num2str(gg),' of ',num2str(length(tcvals)),'...']);

    % pre-allocate posterior matrix
    pos = zeros(np,np);

    % Bayesian Inference on two parameters, using grid search
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
    
    % Calculate distribution's maximum position in 2D
    [V2G,V1G] = meshgrid(vals(2,:),vals(1,:));
    [~,mi] = max(pos(:));
    
    max_R2p(gg) = V1G(mi);
    max_DBV(gg) = 100*V2G(mi);
    
end % for gg = 1:length(tcvals)
