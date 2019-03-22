% MTC_Metropolis.m
%
% Implements a Metropolis algorithm, which samples from a posterior distribution
% using a Markov-Chain-Monte-Carlo method, specifically for use with simulated
% ASE qBOLD data.
%
% The algorithm is based on that presented in Metropolis et al., 1953, with
% further refinements in Gelman, Roberts, and Gilks, 1996. This code is based on
% a DTC lecture example given by Saad Jbabdi, Michaelmas Term 2015.
%
% 
%       Copyright (C) University of Oxford, 2015-2019
%
% 
% Created by MT Cherukara, 16 January 2018
%
% CHANGELOG:
%
% 2019-03-21 (MTC). Fixed the model evaluation (it needed to be normalized to
%       the spin echo in this script). Now the whole algorithm appears to be
%       working well (for 2 parameters). Still might want to play with the
%       acceptance rate and jump size, etc., and the presentation of results.
%
% 2018-10-24 (MTC). Updated to reflect changes in the way the model is
%       calculated. It's still not really working correctly. Need to sort out
%       the jump sizes and acceptance rate, possibly, and present the results in
%       a scatter plot.
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

% since we'll be plotting stuff
setFigureDefaults;

% Options
plot_trace = 0;
plot_results = 1;
save_figures = 0;

% Load Data
% load('ASE_Data/Data_MultiTE_180208_SNR_200.mat');
load('ASE_Data/Data_190320_40_3_CSF_FLAIR.mat');
params_true = params;
m_params = params;      % this will be the struct that we actually change
SEind = 3; % hardcoded for now

% Parameter Values
p_names = {  'OEF' ; 'R2p'; 'zeta' ; 'R2t' ; 'lam0' };
p_infer = [    1   ,   0  ,   1    ,   0   ,   0    ];
p_inits = [  0.500 ,  4.0 ,  0.100 ,  10.0 ,  0.10  ];
p_range = [  0.001 ,  0.0 ,  0.001 ,   5.0 ,  0.00   ;...
             1.000 , 20.0 ,  0.500 ,  15.0 ,  1.00  ];


% cut parameters down to size
p_name = p_names(p_infer == 1);
p_init = p_inits(p_infer == 1);
p_rng  = p_range(:,p_infer == 1);

% are we inferring on R2p?
if p_infer(2) == 1
    m_params.contr = 'R2p';
else
    m_params.contr = 'OEF';
end

% Obviously, we want to use the asymptotic model here
m_params.model = 'Asymp';

% how many parameters?
np = sum(p_infer);

%% Metropolis Parameters
j_run  = 1e6;       % number of jumps in the real thing
j_updt = 10;        % rate of updating the scaling parameter
j_rng  = 200;       % range of samples to look over when updating scaling param
j_brn  = (200*j_updt) + j_rng;      % number of jumps in the 'burn-in' phase

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

% qs = 0.5;

%% Algorithm Initialization

% pull out parameter values
X0 = p_init;

% set parameter values to their initial guesses
for pp = 1:np
    m_params = updateParams(X0(pp),m_params,p_name{pp});
end

% evaluate model at its initial parameter values
S_mod = qASE_model(T_sample,TE_sample,m_params);

% normalize to the spin echo
S_mod = S_mod./S_mod(SEind);

% calculate difference between data and generated sample
L0 = norm(S_sample-S_mod);

% pre-allocate results array
sample_results = zeros(np,j_run);
accept_rate    = zeros( 1,round((j_brn-j_rng)./j_updt));
accept_tracker = false(1,j_brn+j_run);

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
        
        % first, update the parameters
        for pp = 1:np
            m_params = updateParams(X1(pp),m_params,p_name{pp});
        end
        
        % calculate the model
        S_mod = qASE_model(T_sample,TE_sample,m_params);
        
        % normalize to the spin echo
        S_mod = S_mod./S_mod(SEind);
        
        % Evaluate the norm
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
%     if ( mod(ii,j_updt) == 0 && ii < j_brn && ii > j_rng )
    if ( mod(ii,j_updt) == 0 && ii > j_rng )
        
        % calculate acceptance rate over last 100 samples
        ra = sum(accept_tracker(ii-j_rng+1:ii))./j_rng;
        
        % track acceptance rate over time
        c_rt = c_rt + 1;
        accept_rate(c_rt) = ra;
        
        % change proposal distribution sigma
        q_sig = q_sig.*(1+(1*(ra-qs)));        
        
    end % if ( mod(ii,j_updt) == 0 && ii < j_brn && ii > j_rng )
    
    % save out samples
    if ii > j_brn
        sample_results(:,ii-j_brn) = X1;
    end

end % for ii = 1:(j_brn+j_run)

toc;
disp(num2str(mean(sample_results,2)));


%% Display Acceptance Rate Trend

if plot_trace
    
    figure; hold on; box on;
    plot(accept_rate(1:end-1),'k-','LineWidth',1);
    ylim([0,1]);
    
    xlabel('Iterations');
    ylabel('Sample Acceptance Rate');
    title(['Trace Plot (update range = ',num2str(j_rng),')']);
    
end


%% Results

if plot_results

    % resolutions
    hres = 50;
    cres = 100;

    % individual parameter histograms
    for pp = 1:np

        figure; hold on; box on;
        histogram(sample_results(pp,:),hres);
        hold on;
      
        xlabel(p_name{pp});
        xlim(p_rng(:,pp));
        
        % show the true value
        true1 = eval(['params_true.',p_name{pp}]);
        plot([true1,true1],get(gca,'ylim'),'r-');
        
        if save_figures
            warning('You need to save figures manually');
%             ftitle = strcat('temp_plots/MH_',date,'_Hist_',p_name{pp});
%             export_fig([ftitle,'.pdf']);
%             print(gcf,ftitle,'-dpdf');
        end

    end

    p_pairs = combnk(1:np,2);

    % pair-wise scatter or contour plots
    for pp = 1:size(p_pairs,1)

        % parameters
        prm1 = p_pairs(pp,1);
        prm2 = p_pairs(pp,2);

        % true values
        true1 = eval(['params_true.',p_name{prm1}]);
        true2 = eval(['params_true.',p_name{prm2}]);

        % make figure    
        figure; hold on; box on;

        % For a small number of samples, do a scatter plot
        if size(sample_results,2) < 20000

            % plot scatter
            scatter(sample_results(prm2,:),sample_results(prm1,:),'k.');

            % in this case, plot the true values on top, in red
            plot([p_rng(1,prm2),p_rng(2,prm2)],[true1,true1],'r-');
            plot([true2,true2],[p_rng(1,prm1),p_rng(2,prm1)],'r-');


        % Otherwise, make a contour plot
        else

%             % collect contour points
%             [n,c] = hist3(sample_results([prm1,prm2],:)',[cres,cres]);
%             
%             % this time, put the true values underneath the countour lines, in black
%             plot([p_rng(1,prm2),p_rng(2,prm2)],[true1,true1],'k-');
%             plot([true2,true2],[p_rng(1,prm1),p_rng(2,prm1)],'k-');
% 
%             % plot
%             contour(c{2},c{1},n);

            % for surface plot
            [nh,ch] = hist3(sample_results([prm1,prm2],:)',[cres,cres]);
            
            % plot
            surf(ch{2},ch{1},nh);
            view(2); shading flat;
            
            % add true values over the top
            plot3([p_rng(1,prm2),p_rng(2,prm2)],[true1,true1],[1e3,1e3],'k-');
            plot3([true2,true2],[p_rng(1,prm1),p_rng(2,prm1)],[1e3,1e3],'k-');
        
        end % if size(sample_results,2) < 20000

        % labels
        xlabel(p_name{prm2});
        ylabel(p_name{prm1});   

    end % for pp = 1:size(p_pairs,1)
    
end % if plot_results