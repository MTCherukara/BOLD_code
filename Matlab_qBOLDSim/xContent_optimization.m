% xContent_optimization.m
%
% To find an optimal scaling factor SR for R2' that optimises estimates of dHb
% contentration, using only long-tau ASE data, based on xR2p_optimization.m
%
% MT Cherukara
% 2018-11-05

clear;
close all;

setFigureDefaults;

tic;

% Choose TE (train on 0.072, test on 0.084, also 0.108 and 0.036)
TE = 0.072;

% Vessel Type
vsd_name = 'sharan';

% Load data
%   Dimensions of S0:     DBV, OEF, TIME
load(['../../Data/vesselsim_data/vs_arrays/TE',num2str(1000*TE),'_vsData_',vsd_name,'_100.mat']);

% declare global variables
global tau1 S_true param1

% only use tau values >= 15ms
cInd = find(tau >= 0.019);
tau1 = tau(cInd);

% reduce S0 to only include the taus we want
%   Dimensions:     DBV, OEF, TIME
S0 = S0(:,:,cInd);

nDBV = length(DBVvals);
nOEF = length(OEFvals);

% create a parameters structure with the right params
param1 = genParams('incIV',false,'incT2',false,...
                   'Model','Asymp','TE',TE,...
                   'beta',1.0);
               
% pre-allocate estimate matrix
% Dimensions:   OEF, DBV
ests = zeros(nOEF,nDBV);

% Loop over OEF
for i1 = 1:nOEF
    
    % Loop over DBV
    for i2 = 1:nDBV
        
        param1.OEF  = OEFvals(i1);
        param1.zeta = DBVvals(i2);
        
        % pull out the true signal
        S_true = squeeze(S0(i2,i1,:))';
        
        % Minimize the function
        Scale_factor = fminbnd(@optimScaling,0,3);
        
        % Fill in ests matrix
        ests(i1,i2) = Scale_factor;
        
    end % DBV Loop
    
end % OEF Loop

toc;


% plot the results
plotGrid(ests,DBVvals,OEFvals,...
          'cmap',inferno,...
          'cvals',[0,3],...
          'title','Optimized R2'' Scaling Factor');

% Display Errors
disp('  Scaling Factor:');
disp(['Mean Scaling    :  ',round2str(mean(ests(:)),4)]);
disp([' OEF 40, DBV 5  :  ',round2str(ests(52,67),4)]);
