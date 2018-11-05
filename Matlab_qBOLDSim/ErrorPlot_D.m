% D_Error.m
%
% Calculate the error in estimates of deoxyhaemoglobin content D using the qBOLD
% model, against various vessel distributions
%
% Modified from DBV_Error.m
%
% MT Cherukara
% 2018-10-22

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

% Which parameter do we want to plot - 'R2p' or 'D'
plot_par = 'D';

% What TE value do we want to use (36, 72, 84, 108 ms)
TE = 0.072;

% Do we want to plot estimates or true values
plot_est = 0;
plot_tru = 0;

% Do we want to plot the relative error?
plot_err = 0;
plot_rel = 1;

% Random R2' scaling
SR = 0.808;

% Content scaling constant
kappa = 0.03;


% declare global variables
global S_true tau1;

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

% only use tau values >= 20ms
cInd = find(tau >= 0.020);
tauC = tau(cInd);

% reduce S0 to only include the taus we want
%   Dimensions:     DBV, OEF, TIME
S0 = S0(:,:,cInd);

% assign global variable
tau1 = tauC;

nDBV = length(DBVvals);
nOEF = length(OEFvals);

% pre-allocate true and estimate matrices
% Dimensions:   OEF, DBV
ests = zeros(nOEF,nDBV);
trus = zeros(nOEF,nDBV);

% Loop over OEF
for i1 = 1:nOEF
    
    % Loop over DBV
    for i2 = 1:nDBV
        
        % Calculate true values
        tOEF = OEFvals(i1);
        tDBV = DBVvals(i2);
        
        tR2p = (4/3) * pi * param1.gam * param1.B0 * param1.dChi * (param1.Hct * tOEF)^1.2 * tDBV;
        tD = param1.Hct .* tOEF .* tDBV ./ kappa;
        
        % parametric SR
%         SR = (0.00462/tDBV) + 0.3906;
 
        
        % Pull out the true signal
        S_true = squeeze(S0(i2,i1,:))';
        
        % find the estimated R2'
        eR2p = fminbnd(@R2p_loglikelihood,0,30);
        
        % scale R2p
        eR2p = eR2p./SR;
        
        % calculate estimated D
        eD = (3/4) * eR2p / (pi * param1.gam * param1.B0 * param1.dChi * kappa);
 
        if strcmp(plot_par,'R2p')
            % Dimensions: OEF, DBV
            ests(i1,i2) = eR2p;
            trus(i1,i2) = tR2p;
        else
           % Dimensions: OEF, DBV
            ests(i1,i2) = eD;
            trus(i1,i2) = tD;
        end
        
    end % DBV Loop
    
end % OEF Loop

toc;

% Max D value
md = max(max(trus(:)),max(ests(:)));

% Calculate error
%   Dimensions:   OEF, DBV
errs = trus - ests;
rel_err = (errs) ./ trus;

% Display Errors
disp('  dHb Content Error:');
disp(['Mean Rel. Error:  ',round2str(100*mean(abs(rel_err(:))),2)]);
disp([' OEF 40, DBV 5  : ',round2str(100*rel_err(52,67),2)]);


%% Plot True Parameter Value
if plot_tru
    
    h_tru = plotGrid(trus,DBVvals,OEFvals,...
                     'cvals',[0,md],...
                     'title','True dHb Content',...
                     'cmap',flipud(magma));
    
end % if plot_tru


%% Plot Parameter Estimate
if plot_est
    
    h_est = plotGrid(ests,DBVvals,OEFvals,...
                     'cvals',[0,md],...
                     'title','Estimated dHb Content',...
                     'cmap',flipud(magma));
    
end % if plot_estD


%% Plot Error in OEF Estimate

if plot_err

    h_err = plotGrid(errs,DBVvals,OEFvals,...
                     'cvals',[-md,md],...
                     'title','Error in dHb Content');

end % if plot_err


%% Plot relative error

if plot_rel
    
    h_rel = plotGrid(100.*rel_err,DBVvals,OEFvals,...
                     'cvals',[-100,100],...
                     'title','Relative Error in dHb Content (%)',...
                     'cmap',jet);
    
end
