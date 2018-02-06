% MTC_Metropolis.m
%
% Implements a Metropolis algorithm, which samples from a posterior distribution
% using a Markov-Chain-Monte-Carlo method, specifically for use with simulated
% ASE qBOLD data.
%
% The algorithm is based on that presented in Metropolis et al., 1953, with
% further refinements in Gelman, Roberts, and Gilks, 1996. This code is based on
% MTC_ASE_MH.m, which is in turn based on a DTC lecture example given by Saad
% Jbabdi, Michaelmas Term 2015.
%
% 
%       Copyright (C) University of Oxford, 2016-2017
%
% 
% Created by MT Cherukara, 16 January 2018
%
% CHANGELOG:
%
% 2018-02-05 (MTC). Came up with a better, more extensible, method for
%       displaying the results.
%
% 2018-01-23 (MTC). Added multi-dimensional Metropolis, and analysis protocol
%       for 3D.
%
% 2018-01-22 (MTC). Set the algorithm to save out the results of every single
%       jump (inluding those that were rejected), so that the total number of
%       jumps (not including burn-in) is the same as the total number of samples
%       collected. This has a risk of producing auto-correlation in the results,
%       but that shouldn't be a major concern, given that it still appears to be
%       properly sampling the whole posterior. This is a massive time saver.
%       Also, added the possibility to infer on R2' and DBV, as well as OEF-DBV.


%% Script Initialization

clear; 
close all;

% Load Data
load('ASE_Data/Data_180205_SNR_200.mat');
params_true = params;


% Parameter Values
p_names = { 'OEF'; 'R2p'; 'zeta'; 'R2t' ; 'geom' };
p_infer = [   0  ,   1  ,   0   ,   1   ,  0     ];
p_inits = [  0.5 ,  4.0 ,  0.026,  10.0 ,  0.3   ];
p_range = [  0.2 ,  3.0 ,  0.02 ,   5.0 ,  0.1    ;...
             0.6 ,  5.5 ,  0.04 ,  15.0 ,  0.5   ];

% true R2p

% cut parameters down to size
p_name = p_names(p_infer == 1);
p_init = p_inits(p_infer == 1);
p_rng  = p_range(:,p_infer == 1);

% are we inferring on R2p?
if p_infer(2) == 1
    infer_R2p = 1;
    params_true.R2p = params_true.zeta*params_true.dw;
else
    infer_R2p = 0;
end

% how many parameters?
np = sum(p_infer);

%% Metropolis Parameters
j_brn  = 10000;      % number of jumps in the 'burn-in' phase
j_run  = 100000;      % number of jumps in the real thing
j_updt = 10;       % rate of updating the scaling parameter
j_rng  = 500;       % range of samples to look over when updating scaling param

% counters
c_rt  = 0;      % rate counter

% ideal acceptance rate
if np == 2
    qs = 0.352;     % for 2 parameters
elseif np == 3
    qs = 0.316;     % for 3 parameters
else % if np > 3
    qs = 0.234;
end


%% Algorithm Initialization

% pull out parameter values
X0 = p_init;

% set parameter values to their initial guesses
for pp = 1:np
    eval(['params.',p_name{pp},'=',num2str(X0(pp)),';']);
end

% evaluate model at its initial parameter values
S_mod = MTC_qASE_model(T_sample,TE_sample,params,infer_R2p);

% calculate difference between data and generated sample
L0 = norm(S_sample-S_mod);

% pre-allocate results array
sample_results = zeros(np,j_run);
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
        for pp = 1:np
            eval(['params.',p_name{pp},'=',num2str(X1(pp)),';']);
        end
        
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
    if ii > j_brn
        sample_results(:,ii-j_brn) = X1;
    end

end % for ii = 1:(j_brn+j_run)

toc;


%% Display Acceptance Rate Trend
% figure('WindowStyle','Docked');
% hold on; box on;
% plot(accept_rate(1:end-1),'k-');
% xlabel('Iterations');
% ylabel('Sample Acceptance Rate');
% set(gca,'FontSize',14);


%% Scatter Plot
% only when there are fewer than 20k points, otherwise the whole thing is just a
% massive splodge

if ( np == 2 && size(sample_results,2) < 20000)
    figure('WindowStyle','Docked');
    hold on; box on;

    % plot true values
    % plot([params_true.OEF,params_true.OEF],[p_rng(1,2),p_rng(2,2)]  ,'r-','LineWidth',2);
    plot([p_rng(1,1),p_rng(2,1)],[params_true.zeta,params_true.zeta],'r-','LineWidth',2);
    plot([params_true.R2p,params_true.R2p],[p_rng(1,2),p_rng(2,2)]  ,'r-','LineWidth',2);

    % plot results
    scatter(sample_results(1,:),sample_results(2,:),'k.');

    xlabel(p_name{1});
    ylabel(p_name{2});
    set(gca,'FontSize',14);
end

%% Contour Plot
% % in two dimensions
% 
% if np == 2
%     
%     ctres = 25; % contour resolution
% 
%     figure('WindowStyle','Docked');
%     hold on; box on;
% 
%     if infer_R2p
%         plot([p_rng(1,2),p_rng(2,2)], [params_true.R2p,params_true.R2p],'k-','LineWidth',2);
%     else
%         plot([p_rng(1,2),p_rng(2,2)], [params_true.OEF,params_true.OEF],'k-','LineWidth',2);
%     end
%     plot([params_true.zeta,params_true.zeta], [p_rng(1,1),p_rng(2,1)],'k-','LineWidth',2);
% 
%     [n,c] = hist3(sample_results',[ctres,ctres]);
%     contour(c{2},c{1},n);
% 
%     xlabel(p_name{2});
%     ylabel(p_name{1});
%     set(gca,'FontSize',18);
%     
% end % if np == 2


%% 3D Analysis

% if np > 2
%     
%     ctres = 25; % contour resolution
% 
%     % choose which parameter 'plane' to look at
%     an_param = 3;       % 3 = R2
%     an_value = 11.0;
%     an_range = p_rng(2,an_param) - p_rng(1,an_param);
% 
%     % how big a slice of the 3D volume?
%     slabwidth = 0.1;    % 10%
% 
%     % define the boundaries of the slab
%     slabup = an_value + (slabwidth*an_range/2);
%     slabdn = an_value - (slabwidth*an_range/2);
% 
%     % identify which points are within the slab
%     slab_vals = sample_results(an_param,:);
%     slab_log = logical((slab_vals > slabdn) .* (slab_vals < slabup));
% 
%     % extract points from within the slab
%     slab_data = sample_results(1:2,slab_log);
% 
%     % plot    
%     figure('WindowStyle','Docked');
%     hold on; box on;
%     
%     if infer_R2p
%         plot([params_true.R2p,params_true.R2p],[p_rng(1,2),p_rng(2,2)]  ,'k-','LineWidth',2);
%     else
%         plot([params_true.OEF,params_true.OEF],[p_rng(1,2),p_rng(2,2)]  ,'k-','LineWidth',2);
%     end
%     plot([p_rng(1,1),p_rng(2,1)],[params_true.zeta,params_true.zeta],'k-','LineWidth',2);
%     
%     [n,c] = hist3(slab_data',[ctres,ctres]);
%     contour(c{1},c{2},n);
%     
%     xlabel(p_name{1});
%     ylabel(p_name{2});
%     set(gca,'FontSize',14);
% 
%     
% end % if np > 2


%% High Dimensional Result Presentation

% resolutions
hres = 25;
cres = 25;

% individual parameter histograms
for pp = 1:np
    
    figure('WindowStyle','Docked');
    hold on; box on;
    histogram(sample_results(pp,:),hres);
    xlabel(p_name{pp});
    xlim(p_rng(:,pp));
    set(gca,'FontSize',18);
    
end

p_pairs = combnk(1:np,2);

% pair-wise contour plots
for pp = 1:size(p_pairs,1)
    
    % parameters
    prm1 = p_pairs(pp,1);
    prm2 = p_pairs(pp,2);
        
    % collect contour points
    [n,c] = hist3(sample_results([prm1,prm2],:)',[cres,cres]);
    
    % plot
    figure('WindowStyle','Docked');
    hold on; box on;
    contour(c{2},c{1},n);
    
    % labels
    xlabel(p_name{prm2});
    ylabel(p_name{prm1});
    set(gca,'FontSize',18);
    
    % pull out true values
    true1 = eval(['params_true.',p_name{prm1}]);
    true2 = eval(['params_true.',p_name{prm2}]);
    
    % plot true values
    plot([p_rng(1,prm2),p_rng(2,prm2)],[true1,true1],'k-','LineWidth',2);
    plot([true2,true2],[p_rng(1,prm1),p_rng(2,prm1)],'k-','LineWidth',2);

    
end