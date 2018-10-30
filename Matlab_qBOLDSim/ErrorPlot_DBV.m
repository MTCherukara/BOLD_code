% ErrorPlot_DBV.m
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

% What TE value do we want to use (36, 72, 84, 108 ms)
TE = 0.072;

% Do we want to plot estimates or true values
plot_est = 0;
plot_tru = 0;

% Do we want to plot the relative error?
plot_err = 1;
plot_rel = 1;

% Specify SNR of noise to be added. For no noise: SNR = inf; 
SNR = Inf;

% Number of times to repeat the whole process
nreps = 1;

% declare global variables
global S_true param1 tau1;

% S0 dimensions:    DBV, OEF, TIME

% generate a params structure
param1 = genParams('incIV',false,'incT2',false,...
                   'Model',mod_name,'TE',TE,...
                   'SR',0.548,...
                   'Voff',0.0042);
               

% Load the actual dataset we want to examine
load([simdir,'vs_arrays/TE',num2str(1000*TE),'_vsData_',vsd_name,'_100.mat']);
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

trus = repmat(DBVvals,nOEF,1);


% if we have no noise, we don't need to do multiple repeats
if SNR > 1e6
    disp('Setting number of repetitions to 1');
    nreps = 1;
end

% pre-allocate error and DBV matrices
% Dimensions:   OEF, DBV, REPS
errs = zeros(nOEF,nDBV,nreps);
ests = zeros(nOEF,nDBV,nreps);

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
            param1.OEF = OEFvals(i1);

            % find the optimum DBV
            DBV = fminbnd(@DBV_loglikelihood,0.01,0.07);

            % Dimensions: OEF, DBV
            ests(i1,i2,ir) = DBV;      % we fill the matrix this way so that DBV is along the x axis
            errs(i1,i2,ir) = DBV - DBVvals(i2);

        end % DBV Loop

    end % OEF Loop
  
end % for ir = 1:nreps

toc;


%% Average over repeats

ests = mean(ests,3);

% calculate errors
errs = trus - ests;
rel_err = errs ./ trus;


%% Plots

% True value
if plot_tru
    
    h_tru = plotGrid(100.*trus,DBVvals,OEFvals,...
                     'cvals',[0,10],...
                     'title','True DBV (%)',...
                     'cmap',inferno);
    
end % if plot_tru

% Estimate
if plot_est
    
    h_est = plotGrid(100.*ests,DBVvals,OEFvals,...
                     'cvals',[0,10],...
                     'title','Estimated DBV (%)',...
                     'cmap',inferno);
    
end % if plot_estD

% Error
if plot_err

    h_err = plotGrid(100.*errs,DBVvals,OEFvals,...
                     'cvals',[-10,10],...
                     'title','Error in DBV (%)');

end % if plot_err

% Relative Error
if plot_rel
    
    h_rel = plotGrid(100.*rel_err,DBVvals,OEFvals,...
                     'cvals',[-100,100],...
                     'title','Relative Error in DBV (%)',...
                     'cmap',jet);
    
end
