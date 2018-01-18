% MTC_Metropolis.m
%
% Implements a Metropolis Hastings algorithm, which samples from a posterior 
% distribution using a Markov-Chain-Monte-Carlo method, % specifically for use
% with simulated ASE qBOLD data.
%
% The algorithm is based on those presented in Metropolis et al., 1953, and
% Hastings, 1970; this code is based on MTC_ASE_MH.m, which is in turn based on 
% a DTC lecture example given by Saad Jbabdi, Michaelmas Term 2015.
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
           1.0 ,  0.10 ];
      
infer_R2p = 0;      % are we inferring on R2'?


%% Metropolis Hastings Parameters
j_brn  = 10000;      % number of jumps in the 'burn-in' phase
j_run  = 500000;      % number of jumps in the real thing
j_samp = 50;        % rate of sampling (1 sample every J_SAMP jumps)
j_updt = 10;       % rate of updating the scaling parameter
j_rng  = 500;       % range of samples to look over when updating scaling param

% counters
c_smp = 0;      % sample counter
c_rt  = 0;      % rate counter

% ideal acceptance rate
qs = 0.234;


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
accept_rate    = zeros( 1,round((j_brn-j_rng)./j_updt));
accept_tracker = false(1,j_brn);

% pre-generate random numbers
rng_gauss = randn(np,j_brn+j_run)';
rng_accpt = rand(1,j_brn+j_run)';

% initial jump size
q_sig = 0.0100*(p_rng(2,:)-p_rng(1,:));


%% Metropolis Algorithm
tic;

for ii = 1:(j_brn+j_run)
    
    % assign a new value for the parameters
    jump_size = q_sig.*rng_gauss(ii,:);
    X1 = X0+jump_size;
    
    % make sure the new value is within the limits
    if sum( (X1 > p_rng(2,:)) + (X1 < p_rng(1,:)) ) > 0
        
        % if the new value is outside the limits reset back to old value
        X1 = X0;
        
    else
        % otherwise, evaluate the model
        params = param_update(X1(1),params,p_name{1});
        params = param_update(X1(2),params,p_name{2});
        
        S_mod = MTC_qASE_model(T_sample,TE_sample,params,infer_R2p);
        
        L1 = norm(S_sample-S_mod);
        
        % the new norm L1 should be smaller than the old one, if it is,
        % then L0/L1 will be > 1, if not, L0/L1 will be between 0 and 1, in
        % this case, accept the new point in L0/L1 is greater than a
        % randomly generated threshold between 0 and 1
        if (L0/L1) > rng_accpt(ii)
            
            accept_tracker(ii) = 1;
            X0 = X1;                % keep these variables
            L0 = L1;                % record this norm
            
        else
            X1 = X0;                % reset variables
            
        end % if (L0/L1) > rng(accpt(ii))
        
    end % if sum( (X1 > p_rng(2,:)) + (X1 < p_rng(1,:)) ) > 0
        
    % adaptive sampling range update
    if ( mod(ii,j_updt) == 0 && ii < j_brn && ii > j_rng )
        
        % calculate acceptance rate over last 100 samples
        ra = sum(accept_tracker(ii-j_rng+1:ii))./j_rng;
        
        % track acceptance rate over time
        c_rt = c_rt + 1;
        accept_rate(c_rt) = ra;
        
        % change proposal distribution sigma
        q_sig = q_sig.*(1+(0.1*(ra-qs)));        
        
    end % if ( mod(ii,j_updt) == 0 && ii < j_brn && ii > j_rng )
    
    
    % save out samples
    if ( mod(ii,j_samp) == 0 && ii > j_brn )
        c_smp = c_smp + 1;
        sample_results(:,c_smp) = X1;
    end

end % for ii = 1:(j_brn+j_run)

toc;


%% Analysis 



%% Display Acceptance Rate Trend
figure('WindowStyle','Docked');
hold on; box on;
plot(accept_rate(1:end-1),'k-');
xlabel('Iterations');
ylabel('Sample Acceptance Rate');
set(gca,'FontSize',12);


%% Display Results

figure('WindowStyle','Docked');
hold on; box on;

% plot true values
plot([params_true.OEF,params_true.OEF],[p_rng(1,2),p_rng(2,2)]  ,'r-','LineWidth',2);
plot([p_rng(1,1),p_rng(2,1)],[params_true.zeta,params_true.zeta],'r-','LineWidth',2);

% plot results
scatter(sample_results(1,:),sample_results(2,:),'k.');
xlabel('OEF');
ylabel('DBV');
set(gca,'FontSize',12);

% contour plot
figure('WindowStyle','Docked');
hold on; box on;
plot([params_true.OEF,params_true.OEF],[p_rng(1,2),p_rng(2,2)]  ,'k-','LineWidth',1);
plot([p_rng(1,1),p_rng(2,1)],[params_true.zeta,params_true.zeta],'k-','LineWidth',1);
[n,c] = hist3(sample_results',[50,50]);
contour(c{1},c{2},n);
xlabel('OEF');
ylabel('DBV');
set(gca,'FontSize',12);