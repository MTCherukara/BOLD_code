% ErrorPlot_OEF.m
%
% Calculate the error in estimates of OEF obtained by using the various qBOLD
% models. Derived from ErrorPlot_DBV.m
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


% declare global variables
global S_true param1 tau1;

% S0 dimensions:    DBV, OEF, TIME

% generate a params structure
param1 = genParams('incIV',false,'incT2',false,...
                   'Model',mod_name,...
                   'SR',1);

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
param1.TE = TE;
param1.contr = 'OEF';
param1.SR = 0.548;

nDBV = length(DBVvals);
nOEF = length(OEFvals);

trus = repmat(OEFvals',1,nDBV);

% pre-allocate OEF estimate matrix
% Dimensions:   OEF, DBV
ests = zeros(nOEF,nDBV);


% Loop over OEF
for i1 = 1:nOEF
    
    % Loop over DBV
    for i2 = 1:nDBV
        
        % Pull out the true signal
        S_true = squeeze(S0(i2,i1,:))';
        
        % assign true value of DBV
        param1.zeta = DBVvals(i2);
        
        % find the optimum OEF
        OEF = fminbnd(@OEF_loglikelihood,0,1);
        
        % Dimensions: OEF, DBV
        ests(i1,i2) = OEF;      
        
    end % DBV Loop
    
end % OEF Loop
  
toc;

%% Plot True Parameter Value
if plot_tru
    
    h_tru = plotGrid(100.*trus,DBVvals,OEFvals,...
                     'cvals',[0,100],...
                     'title','True OEF (%)',...
                     'cmap','parula');
    
end % if plot_tru


%% Plot Parameter Estimate
if plot_est
    
    h_est = plotGrid(100.*ests,DBVvals,OEFvals,...
                     'cvals',[0,100],...
                     'title','Estimated OEF (%)',...
                     'cmap',parula);
    
end % if plot_estD


%% Plot Error in OEF Estimate

% Calculate error
%   Dimensions:   OEF, DBV
errs = trus - ests;


if plot_err

    h_err = plotGrid(100.*errs,DBVvals,OEFvals,...
                     'cvals',[-60,60],...
                     'title','Error in OEF (%)');

end % if plot_err


%% Plot relative error

if plot_rel
    
    % calculate relative error
    %       Dimensions: OEF, DBV
    rel_err = (errs) ./ trus;
    
    h_rel = plotGrid(100.*rel_err,DBVvals,OEFvals,...
                     'cvals',[-50,50],...
                     'title','Relative Error in OEF (%)',...
                     'cmap',jet);
    
end