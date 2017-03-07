% xMTC_ASE_MH.m

% Metropolis Hastings algorithm for ASE data. Based on MTC_metroBOLD.m.

% MT Cherukara
% 18 May 2016 (origin)
%
% 14 June 2016 - Changed the way graphs are plotted so that they use a
% normal distribution rather than a horrible looking histogram. Added a
% test feature using the resulting normal distribution to display on the
% graphs whether a given parameter was found to be within one standard
% deviation of its true value.
%
% 13 June 2016 - Made various changes up to this date.
    

clear; close all;

% Load Data (data from 20-May-2016 uses besselj integral and isn't normalized)
load('ASE_Data_006.mat'); % various sigma = 0.02
DATA = S_sample;


%% Decide Which Parameters to Infer On
% if changing these, make sure to change PARAM_UPDATE!
infer_on = [ 1   ,  1    ,    0    , 0    ,   0    ,   0   ,  0    ,   0   ,   1    ];
var_name = {'OEF','DBV'  ,'\lambda','Hct','\Deltaf','R2(t)','S(0)' ,'R_2^e','\sigma'};
value =    [ 0.4 ,  0.03 ,    0.1  , 0.4 ,    5    ,   6   ,  1    ,   4   ,   0.2  ]; % true values
inits =    [ 0.4 ,  0.05 ,    0.1  , 0.5 ,    7    ,   5   ,  0.5  ,   5   ,   0.2  ]; % initial values
limit =    [ 0   ,  0    ,    0    , 0.0 ,    0    ,   1   ,  0    ,   0   ,   0     ; ...
             1   ,  0.2  ,    0.5  , 1   ,   10    ,  30   ,  10   ,  20   ,   1    ];
dis_t =    [ 1   ,  1    ,    1    , 1   ,    1    ,   1   ,  1    ,   1   ,   1    ];
pr_mn =    [ 0.5 ,  0.1  ,    0.25 , 0.5 ,    5    ,  15   ,  1    ,  10   ,   0.2  ]; % prior mean
pr_sd =    [ Inf ,  Inf  ,    Inf  , Inf ,    Inf  ,   Inf ,  Inf  ,   Inf ,   Inf  ]; % prior standard deviation
% type of distribution to fit, 1 = normal, 2 = gamma     
%       only use 1 (normal) for now

n_p = sum(infer_on);

ivars   = find(infer_on==1);

X0      = inits(  ivars);
LIMITS  = limit(:,ivars);
VALS    = value(  ivars);
DISTYPE = dis_t(  ivars);
PRMEANS = pr_mn(  ivars);
PRSTDS  = pr_sd(  ivars);

VNAME   = cell(1,n_p);

for var = 1:n_p
    VNAME{var} = var_name{ivars(var)};
end


%% function
% algorithm parameters
n_burn = 5000;  % number of jumps in the 'burn-in' phase
n_jump = 10000;  % number of jumps after the 'burn-in'
n_samp = 10;    % rate of sampling (1 every N_SAMP jumps)
n_updt = 10;    % rate of updating scale parameter (once every N_UPDT jumps)
qs = 0.60;      % q_sig scaling parameter = ideal acceptance rate

n_p = length(X0);   % number of parameters to be inferred on

% these will be used to adjust the width of the Gaussian from which new
% values are chosen
c_acc = zeros(1,n_p);   % counter of accepted jumps
c_irj = zeros(1,n_p);   % counter of rejected jumps within value limits
c_orj = zeros(1,n_p);   % counter of rejected jumps outside value limits

% the range over which a function could lie, used to determine the width of
% the Gaussian function from which new values are randomly drawn
p_range = LIMITS(2,:) - LIMITS(1,:);

% evaluate the function at it starting points
S_mod = MTC_qASE_model(T_sample,params);  

% norm, for comparison
L0 = norm(DATA-S_mod);

% preallocate samples array
SAMPLES = zeros(n_p,round(n_jump/n_samp));
s_c = 0;
X1 = X0;

% for monitoring
L_track = zeros(1,n_burn+n_jump);
l_c = 1;

% initial jump size
q_sig = 1.0.*p_range;

for ii = 1:(n_burn+n_jump)
    
%     jump_size = 0.4*p_range.*randn; % calculate jumps for this step
    jump_size = q_sig.*randn;
    for par = 1:n_p
        
        X1(par) = X0(par)+jump_size(par);
        
        % makes sure that estimated values of the parameters do not become
        % silly by restricting them to real-valued user-imposed limits.
        if (X1(par) < LIMITS(1,par) || X1(par) > LIMITS(2,par))
            
            c_orj(par) = c_orj(par) + 1; 
            X1(par) = X0(par);
            
        else
        
            params = param_update(X1,params,infer_on); % update all parameters to X1
            
            % evaluate function
            S_mod = MTC_qASE_model(T_sample,params); % REMEMBER TO CHANGE BOTH OF THESE
            
            L1 = norm(DATA-S_mod);
            L_track(l_c) = L1;
            l_c = l_c + 1;
            
            % if the ratio of norms (new/old) is greater than a randomly
            % defined threshold, accept the n
            if (L0/L1) > (1*rand)
                c_acc(par) = c_acc(par) + 1;
                X0(par) = X1(par);
                L0 = L1;
            else
                c_irj(par) = c_irj(par) + 1;
                X1(par) = X0(par);
%                 X0(par) = X1(par);
            end
        end
    end
    

    % once all parameters are done, update q_sig at appropriate times
    if (mod(ii,n_updt)==0)
        q_sig = q_sig.*qs.*(1+c_acc+c_irj+c_orj)./(1+c_irj+c_orj);
%         q_sig = q_sig.*qs.*(1+c_acc+c_irj)./(1+c_irj);
        
        c_acc = c_acc.*0;
        c_irj = c_irj.*0;
        c_orj = c_orj.*0;
%         disp(['MH jump ',num2str(ii),' of ',num2str(n_burn+n_jump)]);
    end
    
    % and save out samples
    if ( mod(ii,n_samp)==0 && ii>n_burn )
        s_c = s_c + 1;
        SAMPLES(:,s_c) = X1;
    end
    
    % print out once burn-in is finished
    if (ii == n_burn)
        disp(['Completed burn-in stage (',num2str(n_burn),' jumps)']);
    end
    
end

% for monitoring
acc_rate = c_acc./(c_acc+c_irj);
L_track = L_track(1:l_c-1);
LR = L_track(2:end)./L_track(1:end-1);


%% Distribution Analysis

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


%% Histogram Analysis
% 
% nhp = 11; % number of histogram points
% 
% h_data = zeros(n_p,100); % pre-allocate histogram data arrays
% h_posi = zeros(n_p,100);
% 
% modes = zeros(1,n_p);   % pre-allocate comparison vectors
% means = zeros(1,n_p);
% mv    = zeros(1,n_p);
% 
% % create invisible figure to calculate original histograms on
% f0 = figure('visible','off');
% 
% for ff = 1:n_p
%     % calculate histogram using histfit
%     hh = histfit(SAMPLES(ff,:),nhp);
%     
%     % pull out key values for comparison
%     [mvp,m_pos] = max(hh(1).YData);
%     modes(ff) = hh(1).XData(m_pos);
%     means(ff) = mean(SAMPLES(ff,:));
%     
%     % save out values of the fitted curve
%     h_posi(ff,:) = hh(2).XData;
%     h_data(ff,:) = hh(2).YData;
%     
%     mv(ff) = max([1.05*mvp,max(h_data(ff,:))]);
% end


%% plot histogram for any number of variables
% % figure('units','normalized','outerposition',[0.0 0.2 (0.25*n_p) 0.6]);
% for ff = 1:n_p
%     
%     figure('units','normalized','outerposition',[(0.25*ff - 0.25) 0.2 0.25 0.6]);
% %     hist(SAMPLES(ff,:),11); hold on;
%     plot(h_posi(ff,:),h_data(ff,:),'k-','LineWidth',2); hold on;
%     p_true = plot([VALS(ff),VALS(ff)],[0,mv(ff)],'r-','LineWidth',3);
%     p_mode = plot([modes(ff),modes(ff)],[0,mv(ff)],'g--','LineWidth',3);
%     p_mean = plot([means(ff),means(ff)],[0,mv(ff)],'m:','LineWidth',3);
%     axis([LIMITS(1,ff),LIMITS(2,ff),0,mv(ff)]);
%     ylabel('Posterior Distribution');
%     xlabel(VNAME{ff});
%     title(['Posterior distribution of ',VNAME{ff},' = ',num2str(means(ff))]);
%     legend([p_mean,p_mode,p_true],'Mean value','Modal value','True value');
%     set(gca,'FontSize',16);
% end


%% plot distributions for any number of variables

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

