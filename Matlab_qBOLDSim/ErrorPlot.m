% ErrorPlot.m
%
% Calculate the error in estimates of various parameters obtained by using the
% various qBOLD models, with corrections. Derived from ErrorPlot_DBV.m
%
% MT Cherukara
% 2018-10-02
%
% CHANGELOG:
%
% 2018-11-06 (MTC). Generalized this script so that it works for all variables
%       (OEF, DBV, and DHB content) instead of having to use separate scripts
%       for each variable. DHB currently not working

clear;
setFigureDefaults;
% close all;

tic;

%% User-Selected Inputs

var_name = 'OEF';               % Variable to test - 'OEF', 'DBV', or 'DHB'
vsd_name = 'lauwers';            % Distribution to use - 'sharan', 'frechet', 'lauwers'
mod_name = 'Asymp';             % Model to test - DON'T CHANGE

TE = 0.072;                     % TE value to use - 36, 72, 84, 108
cTaus = (-28:4:64)./1000;       % Tau values to use - DON'T CHANGE
% cTaus = (-12:4:32)./1000;      % For TE = 36ms

% kappa = 1;                    % Scalar correction to R2'
% kappa = 28.5*(TE.^2) + 0.54; 
kappa = 0.77 - (2.78*TE);
beta = 1;                     % Scalar power of [dHb]

plot_est = 1;                   % Plot options
plot_tru = 1;
plot_err = 0;
plot_rel = 1;

SNR = Inf;                      % Noise SNR. For no noise: SNR = inf;
nreps = 1;                      % Repetitions, only used for noise testing



%% Initialization
% Where the data is stored
simdir = '../../Data/vesselsim_data/';

nt = length(cTaus);

% declare global variables
global S_true param1 tau1;

% S0 dimensions:    DBV, OEF, TIME

% generate a params structure
param1 = genParams('incIV',false,'incT2',false,...
                   'Model',mod_name,'TE',TE,...
                   'SR',kappa,'beta',beta);
                              

% Load the actual dataset we want to examine
load([simdir,'vs_arrays/TE',num2str(1000*TE),'_vsData_',vsd_name,'_100.mat']);
% load([simdir,'simulated_data/ASE_TauData_FullModel.mat']);

% Depending on the data type we might be using
if ~exist('OEFvals','var')
    OEFvals = par1;
    DBVvals = par2;
end

% pull out the right tau values
if strcmp(var_name,'DHB')
    % Long-tau only in this case
    cInd = find(tau >= 0.019);
    tauC = tau(cInd);
else
    % All taus
    cInd = find(ismember(tau,cTaus));
    tauC = tau(cInd);
end

% reduce S0 to only include the taus we want
%   Dimensions:     DBV, OEF, TIME
S0 = S0(:,:,cInd);

% assign global variables
tau1 = tauC;

nDBV = length(DBVvals);
nOEF = length(OEFvals);


% if we have no noise, we don't need to do multiple repeats
if SNR > 1e6
%     disp('Setting number of repetitions to 1');
    nreps = 1;
end

% pre-allocate true and estimate matrices
% Dimensions:   OEF, DBV, REPS
trus = zeros(nOEF,nDBV,nreps);
ests = zeros(nOEF,nDBV,nreps);


%% Main Loops
for ir = 1:nreps
    
    disp(['Calculating errors (run ',num2str(ir),' of ',num2str(nreps),')']);

%     % Add random gaussian noise to S0, with specified SNR
%     sigma = mean(S0(:))./SNR;
%     S0 = S0 + sigma.*randn(nOEF,nDBV,nt);

    % Loop over OEF
    for i1 = 1:nOEF
        
        
        % Loop over DBV
        for i2 = 1:nDBV
            
            % pull out true values
            tOEF = OEFvals(i1);
            tDBV = DBVvals(i2);
            
            % optim SR
%             param1.SR = 0.96-(0.38*tOEF);

        
            % assign true values of parameters
            param1.OEF  = tOEF;
            param1.zeta = tDBV;

            % Pull out the true signal
            S_true = squeeze(S0(i2,i1,:))';
          
            % find the optimum value for specific parameter that we care about
            switch var_name
                case 'OEF'
                    optval = fminbnd(@logLikelihoodOEF,0,1);
                    truval = tOEF;
                    
                case 'DBV'
                    optval = fminbnd(@logLikelihoodDBV,0.0001,0.2);
                    truval = tDBV;
                    
                case 'DHB'
                % we previously were just optimizing R2' under the assumption
                % that dHb content was proportional to it, but that's not the
                % case when there's a BETA correction, so we have to do this in
                % a more sensible way. 
                
                    optval = fminbnd(@logLikelihoodDHB,0,20);
                    truval = param1.Hct * tOEF * tDBV / param1.kap;
                
                    
%                     tR2p = (4/3) * pi * param1.gam * param1.B0 * param1.dChi * (param1.Hct * tOEF)^param1.beta * tDBV;
%                     truval = param1.Hct .* tOEF .* tDBV ./ 0.03;
%                     oR2p = fminbnd(@R2p_loglikelihood,0,30);
%                     oR2p = oR2p./param1.SR;
%                     optval = (3/4) * oR2p / (pi * param1.gam * param1.B0 * param1.dChi * 0.03);

                    
            end

            % Dimensions: OEF, DBV
            ests(i1,i2,ir) = optval;      % we fill the matrix this way so that DBV is along the x axis
            trus(i1,i2,ir) = truval;

        end % DBV Loop

    end % OEF Loop
  
end % for ir = 1:nreps

toc;


%% Average over repeats

ests = mean(ests,3);

% calculate errors
errs = trus - ests;
rel_err = errs ./ trus;


% Display Errors
disp(['Mean Rel. Error:  ',round2str(100*mean(abs(rel_err(:))),2)]);
disp([' OEF 40, DBV 5  : ',round2str(100*rel_err(52,67),2)]);
% disp([' OEF 55, DBV 2  : ',round2str(100*rel_err(88,18),2)]);
% disp([' OEF 25, DBV 6.5: ',round2str(100*rel_err(16,92),2)]);


%% Plots

mvt = max(max(trus(:)),max(ests(:)));
% mvt = 8;

% True value
if plot_tru
    
    h_tru = plotGrid(trus,DBVvals,OEFvals,...
                     'cvals',[0,mvt],...
                     'title',['True ',var_name],...
                     'cmap',parula);
    
end % if plot_tru

% Estimate
if plot_est
    
    h_est = plotGrid(ests,DBVvals,OEFvals,...
                     'cvals',[0,mvt],...
                     'title',['Estimated ',var_name],...
                     'cmap',parula);
    
end % if plot_estD

% Error
if plot_err

    h_err = plotGrid(errs,DBVvals,OEFvals,...
                     'cvals',[-mvt,mvt],...
                     'title',['Error in ',var_name]);

end % if plot_err

% Relative Error
if plot_rel
    
    h_rel = plotGrid(100.*rel_err,DBVvals,OEFvals,...
                     'cvals',[-60,60],...
                     'title',['Relative error in ',var_name,' (%)'],...
                     'cmap',jet);
	title('');
    
end
