% DBV_Error.m
%
% Calculate the error in estimates of DBV obtained by using the various qBOLD
% models
%
% MT Cherukara
% 2018-10-02

clear;
setFigureDefaults;
% close all;

tic;

% Where the data is stored
simdir = '../../Data/vesselsim_data/';

% Which tau values do we want to look at
cTaus = (-28:4:64)./1000;
nt = length(cTaus);

% Which distribution we want - 'sharan' or 'frechet'
vsd_name = 'sharan';    

% Which model do we want to compare to
mod_name = 'Asymp';

% Do we want to plot the DBV estimate?
plot_DBV = 1;       % BOOL

% DO we want to plot the relative error?
plot_rError = 1;    % BOOL

% Specify SNR of noise to be added. For no noise: SNR = inf; 
SNR = Inf;

% Number of times to repeat the whole process
nreps = 1;

% Random OEF scaling constant
scaleOEF = 1.0;

% declare global variables
global S_true param1 tau1;

% S0 dimensions:    DBV, OEF, TIME

% generate a params structure
param1 = genParams;s

% ignore the blood compartment
param1.incIV = 0;

% Load the actual dataset we want to examine
load([simdir,'vs_arrays/TEST_vsData_',vsd_name,'_100.mat']);
% load([simdir,'simulated_data/ASE_TauData_FullModel.mat']);

% Depending on the data type we might be using
if ~exist('OEFvals','var')
    OEFvals = par1;
    DBVvals = par2;
end

% pull out the right tau values
cInd = find(ismember(tau,cTaus));
tauC = tau(cInd);

% reduce S0 to only include the taus we want
%   Dimensions:     DBV, OEF, TIME
S0 = S0(:,:,cInd);

% assign global variables
tau1 = tauC;

nDBV = length(DBVvals);
nOEF = length(OEFvals);


% if we have no noise, we don't need to do multiple repeats
if SNR > 1e6
    disp('Setting number of repetitions to 1');
    nreps = 1;
end

% pre-allocate error and DBV matrices
% Dimensions:   OEF, DBV, REPS
errs = zeros(nOEF,nDBV,nreps);
DBVs = zeros(nOEF,nDBV,nreps);

% Loop over repeats
for ir = 1:nreps
    
    disp(['Calculating errors (run ',num2str(ir),' of ',num2str(nreps),')']);

    % Add random gaussian noise to S0, with specified SNR
    sigma = mean(S0(:))./SNR;
    S0 = S0 + sigma.*randn(nOEF,nDBV,nt);

    % Loop over OEF
    for i1 = 1:nOEF

        % Loop over DBV
        for i2 = 1:nDBV

            % Pull out the true signal
            S_true = squeeze(S0(i2,i1,:))';

            % assign true value of parameter 1
            param1.OEF = scaleOEF * OEFvals(i1);
            param1.model = mod_name;

            % find the optimum DBV
            DBV = fminbnd(@DBV_loglikelihood,0.01,0.07);

            % Dimensions: OEF, DBV
            DBVs(i1,i2,ir) = DBV;      % we fill the matrix this way so that DBV is along the x axis
            errs(i1,i2,ir) = DBV - DBVvals(i2);

        end % DBV Loop

    end % OEF Loop
  
end % for ir = 1:nreps

toc;

%% Average over repeats

av_DBV = mean(DBVs,3);
av_err = mean((errs),3);    % Do we want to mean the absolute error? Prolly not


%% Plot Actual DBV Estimate
if plot_DBV
    
    figure; hold on; box on;
    surf(DBVvals,OEFvals,av_DBV);
    view(2); shading flat;
    c=colorbar;
    caxis([0.01,0.07]);
    colormap(inferno);

    axis([min(DBVvals),max(DBVvals),min(OEFvals),max(OEFvals)]);
    axis square;

    title(['DBV estimate (',mod_name,' model)']);
    xlabel('DBV (%)');
    xticks(0.01:0.01:0.07);
    xticklabels({'1','2','3','4','5','6','7'});
    ylabel('OEF (%)');
    yticks(0.2:0.1:0.6);
    yticklabels({'20','30','40','50','60'})
    
end % if plot_DBV

%% Plot Error in DBV Estimate


figure; hold on; box on;
surf(DBVvals,OEFvals,av_err);
view(2); shading flat;
c=colorbar;

% set the colorbar so that it is even around 0
caxis([-0.05,0.05]);
colormap(jet);

axis([min(DBVvals),max(DBVvals),min(OEFvals),max(OEFvals)]);
axis square;

title(['Error in DBV estimate (',mod_name,' model)']);
xlabel('DBV (%)');
xticks(0.01:0.01:0.07);
xticklabels({'1','2','3','4','5','6','7'});
ylabel('OEF (%)');
yticks(0.2:0.1:0.6);
yticklabels({'20','30','40','50','60'})


%% Plot relative DBV error

if plot_rError
    
    % calculate relative error
    rel_err = av_err./repmat(DBVvals,nOEF,1);


    figure; hold on; box on;
    surf(DBVvals,OEFvals,100.*rel_err);
    view(2); shading flat;
    c=colorbar;

    % set the colorbar so that it is even around 0
    caxis([-100,100]);
    colormap(jet);

    axis([min(DBVvals),max(DBVvals),min(OEFvals),max(OEFvals)]);
    axis square;

    title(['Relative Error in DBV estimate (%)']);
    xlabel('DBV (%)');
    xticks(0.01:0.01:0.07);
    xticklabels({'1','2','3','4','5','6','7'});
    ylabel('OEF (%)');
    yticks(0.2:0.1:0.6);
    yticklabels({'20','30','40','50','60'})
    
end