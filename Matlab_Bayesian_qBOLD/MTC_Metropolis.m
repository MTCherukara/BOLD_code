% MTC_Metropolis.m
%
% Implements a Metropolis Hastings algorithm, which samples from a
% posterior distribution using a Markov-Chain-Monte-Carlo method,
% specifically for use with simulated ASE qBOLD data.
%
% The algorithm is based on those presented in Metropolis et al., 1953, and
% Hastings, 1970; this code is based on MTC_ASE_MH.m, which is in turn
% based on a DTC lecture example given by Saad Jbabdi, Michaelmas Term
% 2015.
%
% 
%       Copyright (C) University of Oxford, 2016-2017
%
% 
% Created by MT Cherukara, 16 January 2018
%
% CHANGELOG:


%% Script Initialization

clear; close all;

% Load Data
load('ASE_Data/Data_180112_SNR_50.mat');
params_true = params;

% Parameters being inferred on: OEF and DBV
np = 2;     % number of parameters

% Parameter values
p_name = {'OEF'; 'zeta'};
p_init = [ 0.5 ,  0.05 ];
p_rng  = [ 0.0 ,  0.00  ;...
           1.0 ,  0.20 ];
      
infer_R2p = 0;      % are we inferring on R2'?


%% Metropolis Hastings Parameters
j_burn = 1000;     % number of jumps in the 'burn-in' phase
j_run  = 2000;     % number of jumps in the real thing
j_samp = 10;        % rate of sampling (1 sample every J_SAMP jumps)
j_updt = 10;        % rate of updating the scaling parameter

% counters
c_acc = 0;      % number of accepted jumps
c_irj = 0;      % number of jumps inside limits that were still rejected
c_orj = 0;      % number of jumps outside limits that were rejected
t_acc = 0;      % track the total number of accepted jumps
t_rej = 0;      % track the total number of rejected jumps

% idea acceptance rate
qs = 1-0.234;


%% Algorithm Initialization

% pull out parameter values
X0 = p_init;

% set parameter values to their initial guesses
params = param_update(X0(1),params,p_name{1});
params = param_update(X0(2),params,p_name{2});

% evaluate model at its initial parameter values
S_mod = MTC_qASE_model(T_sample,TE_sample,params,infer_R2p);

% calculate difference between data and generated sample
L0 = norm(S_sample-S_mod);

% pre-allocate results array
sample_results = zeros(np,round(j_run./j_samp));

% pre-generate random numbers
rng_gauss = randn(np,j_burn+j_run)';
rng_accpt = rand(np,j_burn+j_run)';

% initial jump size
q_sig = 0.1*(p_rng(2,:)-p_rng(1,:));


%% Burn-In Phase
for ii = 1:j_burn
    
    % assign a new value for the parameters
    jump_size = q_sig.*rng_gauss(ii,:);
    X1 = X0+jump_size;
    
    % make sure the new value is within the limits
    if sum( (X1 > p_rng(2,:)) + (X1 < p_rng(1,:)) ) > 0
        
        % if the new value is outside the limits, count one outside-rejet,
        % and reset back to old value
        c_orj = c_orj + 1;
        X1 = X0;
        
    else
        % otherwise, evaluate the model
        params = param_update(X1(1),params,p_name{1});
        params = param_update(X1(2),params,p_name{2});

end