% xOptimize_ContentPower.m

% Attempting to fit a power-law function to [dHb]

% MT Cherukara
% 2018-11-01

clear;
% close all;

setFigureDefaults;

tic;

% Choose TE

% Choose TE (train on 0.072, test on 0.084, also 0.108 and 0.036)
TE = 0.072;

% Load data
%   Dimensions of S0:     DBV, OEF, TIME
load(['../../Data/vesselsim_data/vs_arrays/TE',num2str(1000*TE),'_vsData_sharan_100.mat']);

% declare global variables
global S_dist param1 tau1
tau1 = tau;

% create a parameters structure with the right params
param1 = genParams('incIV',false,'incT2',false,...
                   'Model','Asymp','TE',TE);
               
% lengths
nDBV = length(DBVvals);
nOEF = length(OEFvals);

% pre-allocate estimate matrix
% Dimensions:   OEF, DBV
est_A = zeros(nOEF,nDBV);
est_B = zeros(nOEF,nDBV);
est_bt = zeros(nOEF,nDBV);


% Loop over OEF
for i1 = 1:nOEF
    
    % Loop over DBV
    for i2 = 1:nDBV
        
        % pull out the true signal
        S_dist = squeeze(S0(i2,i1,:))';
        
        % assign parameter values
        param1.zeta = DBVvals(i2);
        param1.OEF  = OEFvals(i1);
        
        % find the optimum R2' scaling factor
        x1 = fminsearch(@optimPowerScaleFun,[1,0,1]);
        
        % Fill in ests matrix
        est_A(i1,i2) = x1(1);
        est_B(i1,i2) = x1(2);
        est_bt(i1,i2) = x1(3);
        
    end % DBV Loop
    
end % OEF Loop

toc;

% Display Results
disp('  Parameters:');
disp(['OEF Scaling A    :  ',round2str(mean(est_A(:)),4)]);
disp(['  (OEF 40, DBV 5):  ',round2str(est_A(52,67),4)]);

disp(['TE Scaling B     :  ',round2str(mean(est_B(:)),4)]);
disp(['  (OEF 40, DBV 5):  ',round2str(est_B(52,67),4)]);

disp(['dHb Power beta   :  ',round2str(mean(est_bt(:)),4)]);
disp(['  (OEF 40, DBV 5):  ',round2str(est_bt(52,67),4)]);

% plot the results
plotGrid(est_A,DBVvals,OEFvals,...
          'cmap',inferno,...
          'cvals',[0.5,1.5],...
          'title','Optimized R2'' Scaling');
      
% plot the results
plotGrid(est_bt,DBVvals,OEFvals,...
          'cmap',inferno,...
          'cvals',[0.5,1.5],...
          'title','Optimized [dHb] Exponent \beta');