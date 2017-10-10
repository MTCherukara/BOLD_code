% xMTC_ASE_MH.m
%
% Metropolis Hastings algorithm for ASE data. Based on MTC_metroBOLD.m.
%
% 
%       Copyright (C) University of Oxford, 2016-2017
%
% 
% Created by MT Cherukara, 18 May 2016
%
% CHANGELOG:
%
% 2017-10-10 (MTC). Added the TE input to MTC_qASE_model function calls.
%
% 2017-03-31 (MTC). Clean-up, and revert back to histogram plotting.
%
% 2016-06-14 (MTC). Changed the way graphs are plotted so that they use a
%       normal distribution rather than a horrible looking histogram. Added
%       a test feature using the resulting normal distribution to display
%       on the graphs whether a given parameter was found to be within one
%       standard deviation of its true value.
%
% 2016-06-13 (MTC). Various changes.


clear; close all;

% Load Data 
load('ASE_Data/ASE_CSF_5_SNR_1000.mat'); % various sigma = 0.02
DATA = S_sample;

% the r structure will contain settings which will be used in the MH
% algorithm, including which parameters are being inferred on, and what
% values they take
r.plot_dist = 0; % set this to 1 to plot distributions and stuff
                 % or to 0 to plot histogram peaks

%% Decide Which Parameters to Infer On
% if changing these, make sure to change PARAM_UPDATE!
r.infer_on = [ 1   ,  0    ,    1    , 0   ,    0    ,   0   ,  0    ,   0   ,   0    ];
r.var_name = {'OEF','DBV'  ,'\lambda','Hct','\Deltaf','R2(t)','S(0)' ,'R_2^e','\sigma'};
r.value =    [ 0.4 ,  0.05 ,    0.05 , 0.34,    5    ,   6   ,  1    ,   4   ,   0.001 ]; % true values
r.inits =    [ 0.4 ,  0.05 ,    0.1  , 0.5 ,    7    ,   5   ,  0.5  ,   5   ,   0.001]; % initial values
r.limit =    [ 0   ,  0    ,    0    , 0.0 ,    0    ,   1   ,  0    ,   0   ,   0     ; ...
               1   ,  0.2  ,    0.5  , 1   ,   10    ,  30   ,  10   ,  20   ,   0.1  ];
r.dis_t =    [ 1   ,  1    ,    1    , 1   ,    1    ,   1   ,  1    ,   1   ,   1    ];

% % ignore priors for now
% pr_mn =    [ 0.5 ,  0.1  ,    0.25 , 0.5 ,    5    ,  15   ,  1    ,  10   ,   0.0001  ]; % prior mean
% pr_sd =    [ Inf ,  Inf  ,    Inf  , Inf ,    Inf  ,   Inf ,  Inf  ,   Inf ,   Inf  ]; % prior standard deviation
% type of distribution to fit, 1 = normal, 2 = gamma     
%       only use 1 (normal) for now

n_p = sum(r.infer_on); % number of parameters being inferred

ivars   = find(r.infer_on==1); % positions in the standard structure of the parameters being inferred here

X0      = r.inits(  ivars);
LIMITS  = r.limit(:,ivars);
VALS    = r.value(  ivars);
DISTYPE = r.dis_t(  ivars);
% PRMEANS = pr_mn(  ivars);     % ignore priors now
% PRSTDS  = pr_sd(  ivars);

% collect parameter names into a cell array
VNAME   = cell(1,n_p);
for var = 1:n_p
    VNAME{var} = r.var_name{ivars(var)};
end


%% function
% algorithm parameters
r.nb = 10000;      % number of jumps in the 'burn-in' phase
r.nj = 10000;     % number of jumps after the 'burn-in'
r.ns = 10;    % rate of sampling (1 every N_SAMP jumps)
r.nu = 10;    % rate of updating scale parameter (once every N_UPDT jumps)

qs = 1-0.234;       % q_sig scaling parameter = ideal acceptance rate

% counters, these will be used to adjust the width of the Gaussian from
% which new values are chosen
c_acc = zeros(1,n_p);   % number of accepted jumps
c_irj = zeros(1,n_p);   % number of jumps inside limits that were still rejected
c_orj = zeros(1,n_p);   % number of jumps outside limits that were rejected
t_acc = zeros(1,n_p);   % track the total number of accepted jumps
t_rej = zeros(1,n_p);   % track the total number of rejected jumps

% the range over which a function could lie, used to determine the width of
% the Gaussian function from which new values are randomly drawn
p_range = LIMITS(2,:) - LIMITS(1,:);

% run param_update once to set the initial parameters
params = param_update(X0,params,r.infer_on);

% evaluate the function at it starting points
S_mod = MTC_qASE_model(T_sample,params.TE,params);  

% norm, for comparison
L0 = norm(DATA-S_mod);

% preallocate samples array
SAMPLES = zeros(n_p,round(r.nj/r.ns));
s_c = 0;        % what does this count?
X1 = X0;

% for monitoring
L_track = zeros(1,r.nb+r.nj);
l_c = 1;

% initial jump size - set to half the limits, so that 91% of possible
%                     initial samples will be within the acceptable range,
%                     otherwise we may just be wasting time trying to
%                     sample too far away
q_sig = 0.1.*p_range;

% Metropolis Hastings algorithm
for ii = 1:(r.nb+r.nj) 

    jump_size = q_sig.*randn; % generate a random sample from Gaussian with variance q_sig
    
    % loop through parameters that are being inferred on
    for par = 1:n_p
        
        X1(par) = X0(par)+jump_size(par);
        
        % makes sure that estimated values of the parameters do not become
        % silly by restricting them to real-valued user-imposed limits.
        if (X1(par) < LIMITS(1,par) || X1(par) > LIMITS(2,par))
            
            c_orj(par) = c_orj(par) + 1; % add one to the outside-rejection counter
            X1(par) = X0(par);           % go back to the value we had before
            
        else
        
            params = param_update(X1,params,r.infer_on); % update all parameters to X1
            
            % evaluate function at point (X1) in paramter-space
            S_mod = MTC_qASE_model(T_sample,params.TE,params); % REMEMBER TO CHANGE BOTH OF THESE
            
            % SS difference between the data and the function evaluated at
            % this point (X1) in parameter-space
            L1 = norm(DATA-S_mod); 
            
            L_track(l_c) = L1; % record the new Norm
            l_c = l_c + 1;     % count the number of times a new norm has been generated
            
            % new norm L1 should be smaller than old norm L0, if it is,
            % accept it, if it is not, accept it with a probability that is
            % proportional to their ratio
            if (L0/L1) > (rand)
                
                c_acc(par) = c_acc(par) + 1;
                X0(par) = X1(par);
                L0 = L1;
                
            else % reject
                
                c_irj(par) = c_irj(par) + 1;
                X1(par) = X0(par); % revert back to previous thing
                
            end % if (L0/L1) > (rand) 
            
        end % if (X1(par) < LIMITS(1,par) || X1(par) > LIMITS(2,par))
        
    end % for par = 1:n_p
    

    % once all parameters are done, update q_sig at appropriate times
    if (mod(ii,r.nu)==0) % maybe this should be done less frequently?
        
        % (1+total)/(1+rejected) - as more attempts get rejected, this
        %                          number gets bigger, effectively widening
        %                          the search area. Does this make sense?
        % Yes, but only if you start with a narrow band to begin with, so
        % q_sig should start off small. What effect does qs have?
        q_sig = q_sig.*qs.*(1+c_acc+c_irj+c_orj)./(1+c_irj+c_orj);
        
        t_acc = t_acc + c_acc;          % total acceptance counter
        t_rej = t_rej + c_irj + c_orj;  % total rejection counter
        
        % reset the counters every time - is this necessary?
        c_acc = c_acc.*0;
        c_irj = c_irj.*0;
        c_orj = c_orj.*0;
        
    end 
    
    % and save out samples
    if ( mod(ii,r.ns)==0 && ii>r.nb )
        s_c = s_c + 1;
        SAMPLES(:,s_c) = X1;
    end
    
    % print out once burn-in is finished
    if (ii == r.nb)
        disp(['Completed burn-in stage (',num2str(r.nb),' jumps)']);
    end
    
% end of MH loop
end % for ii = 1:(r.nb+r.nj) 

disp(['Completed main stage (',num2str(r.nj),' jumps)']);


% for monitoring
acc_rate = t_acc./(t_rej+t_acc);
L_track = L_track(1:l_c-1);
LR = L_track(2:end)./L_track(1:end-1);
disp(['    Mean Acceptance Rate: ',num2str(mean(acc_rate))]);


%% Distribution Analysis
if r.plot_dist
    ndp = 1000; % number of points in distribution pdf

    x_dist = zeros(n_p,ndp);    % pre-allocate distribution vectors
    y_dist = zeros(n_p,ndp);

    modes = zeros(1,n_p);   % pre-allocate comparison vectors
    means = zeros(1,n_p);
    mv    = zeros(1,n_p);
    fits  = false(1,n_p);   % for checking if it worked
    sigs  = zeros(1,n_p);   % for plotting standard deviation

    for ff = 1:n_p
        % fit a gamma function to the probability distribution
        if DISTYPE(ff) == 2
            PD = fitdist(SAMPLES(ff,:)','gamma');
            x_dist(ff,:) = linspace(LIMITS(1,ff),LIMITS(2,ff),ndp);
            y_dist(ff,:) = gampdf(x_dist(ff,:),PD.a,PD.b);

        % or fit a normal function
        else
            PD = fitdist(SAMPLES(ff,:)','normal');
            x_dist(ff,:) = linspace(LIMITS(1,ff),LIMITS(2,ff),ndp);
            y_dist(ff,:) = normpdf(x_dist(ff,:),PD.mu,PD.sigma);

            % compare accuracy (only works for normally distributed parameters)
            if (abs(mean(SAMPLES(ff,:)) - VALS(ff)) < (PD.sigma))
                fits(ff) = 1;
            end

            sigs(ff) = PD.sigma;
        end

        % other comparisons
        [g_pv,g_peak] = max(y_dist(ff,:));
        mv(ff) = g_pv.*1.1;
        modes(ff) = x_dist(g_peak);
        means(ff) = mean(SAMPLES(ff,:));

    end
 
    % plot
    for ff = 1:n_p

        figure('units','normalized','outerposition',[(0.25*ff - 0.25) 0.2 0.25 0.6]);
        plot(x_dist(ff,:),y_dist(ff,:),'k-','LineWidth',2); hold on;
        p_true = plot([VALS(ff),VALS(ff)],[0,mv(ff)],'r-','LineWidth',3);
        p_mean = plot([means(ff),means(ff)],[0,mv(ff)],'b:','LineWidth',3);
        p_sd   = plot([means(ff)+sigs(ff),means(ff)+sigs(ff)],[0,mv(ff)],'b--','LineWidth',2);
        p_sd2  = plot([means(ff)-sigs(ff),means(ff)-sigs(ff)],[0,mv(ff)],'b--','LineWidth',2);
        axis([LIMITS(1,ff),LIMITS(2,ff),0,mv(ff)]);
        ylabel('Posterior Density');
        xlabel(VNAME{ff});
        legend([p_true,p_mean,p_sd],'True value','Mean value','Mean \pm SD');
        set(gca,'FontSize',12);

        if fits(ff)
            title([VNAME{ff},' Inferred Correctly'],'FontSize',14);
        else
            title([VNAME{ff},' Not Inferred Correctly'],'FontSize',14);
        end
    end

else % if NOT r.plot_dist
    
    % if not distributions, just plot some histograms
    
    for ff = 1:n_p
        
        [hn,he] = histcounts(SAMPLES(ff,:),25);
        hp = mean([he(1:end-1);he(2:end)]); % identify the midpoints of each histogram bin
        
        mv = max(hn); % identify maximum value
        
        % plot histogram
        figure; hold on;
        l.hist = plot(hp,hn,'k-','LineWidth',2);
        l.true = plot([VALS(ff),VALS(ff)],[0,1.05*mv],'r-','LineWidth',3);
        axis([LIMITS(1,ff),LIMITS(2,ff),0,1.05*mv]);
        ylabel('Posterior Samples');
        xlabel(VNAME{ff});
        set(gca,'FontSize',16);
        set(gcf,'WindowStyle','docked');
        
    end % for ff = 1:n_p
    
end % if r.plot_dist
