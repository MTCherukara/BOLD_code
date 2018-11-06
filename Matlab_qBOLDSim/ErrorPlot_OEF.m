% ErrorPlot_OEF.m
%
% OBSOLETE as of 2018-11-06 (use ErrorPlot.m)
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

% Which distribution we want - 'sharan' or 'frechet'
vsd_name = 'sharan';    

% Which model do we want to compare to
mod_name = 'Asymp';

% What TE value do we want to use (36, 72, 84, 108 ms)
TE = 0.072;

% Which tau values do we want to look at
cTaus = (-28:4:64)./1000;      % For longer TEs
% cTaus = (-12:4:32)./1000;      % For TE = 36ms

nt = length(cTaus);

% Do we want to plot estimates or true values
plot_est = 0;
plot_tru = 0;

% Do we want to plot the relative error?
plot_err = 0;
plot_rel = 1;


% declare global variables
global S_true param1 tau1;

% S0 dimensions:    DBV, OEF, TIME

% generate a params structure
param1 = genParams('incIV',false,'incT2',false,...
                   'Model',mod_name,'TE',TE);

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
param1.SR = 0.808;    % 0.808
param1.beta = 1.2;  % 1.20

nDBV = length(DBVvals);
nOEF = length(OEFvals);

trus = repmat(OEFvals',1,nDBV);
tru2 = repmat(DBVvals,nOEF,1);

% pre-allocate OEF estimate matrix
% Dimensions:   OEF, DBV
ests = zeros(nOEF,nDBV);
est2 = zeros(nOEF,nDBV);

% Loop over OEF
for i1 = 1:nOEF
    
    % Loop over DBV
    for i2 = 1:nDBV
        
        tDBV = DBVvals(i2);
        
        % Pull out the true signal
        S_true = squeeze(S0(i2,i1,:))';
        
        % assign true value of DBV
        param1.zeta = tDBV;
        
        % assign values of scaling parameters
%         param1.SR = (0.0046/tDBV) + 0.39;
        
        % find the optimum OEF
        X1 = fminbnd(@OEF_loglikelihood,0,1);
%         X1 = fminsearch(@qBOLD_loglikelihood,[0.5,0.05]);
        
        % Dimensions: OEF, DBV
        ests(i1,i2) = X1(1);
%         est2(i1,i2) = X1(2);
        
    end % DBV Loop
    
end % OEF Loop
  
toc;

% Calculate error
%   Dimensions:   OEF, DBV
errs    = trus - ests;
rel_err = (errs) ./ trus;


% Display Errors
disp('  OEF Error:');
disp(['Mean Rel. Error:  ',round2str(100*mean(abs(rel_err(:))),2)]);
disp([' OEF 40, DBV 5  : ',round2str(100*rel_err(52,67),2)]);
% disp([' OEF 55, DBV 2  : ',round2str(100*rel_err(88,18),2)]);
% disp([' OEF 25, DBV 6.5: ',round2str(100*rel_err(16,92),2)]);


% % %  For DBV analyses
% rel_err2 = (tru2 - est2) ./ tru2;
% disp(' ');
% disp('  DBV Error:');
% disp(['Mean Rel. Error:  ',round2str(100*mean(abs(rel_err2(:))),2)]);
% disp([' OEF 40, DBV 5  : ',round2str(100*rel_err2(52,67),2)]);
% disp([' OEF 55, DBV 2  : ',round2str(100*rel_err2(88,18),2)]);
% disp([' OEF 25, DBV 6.5: ',round2str(100*rel_err2(16,92),2)]);

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

if plot_err

    h_err = plotGrid(100.*errs,DBVvals,OEFvals,...
                     'cvals',[-50,50],...
                     'title','Error in OEF (%)');

end % if plot_err


%% Plot relative error

if plot_rel
    
    h_rel = plotGrid(100.*rel_err,DBVvals,OEFvals,...
                     'cvals',[-100,100],...
                     'title','',...
                     'cmap',jet);
    
end