% xOptimize_R2p.m
% To optimize the value of a scaling factor applied to R2' in the asmyptotic SDR
% qBOLD model
%
% MT Cherukara
% 2018-10-24
%
% CHANGELOG:
%
% 2018-10-25 (MTC). Make it loop around all OEF and DBV.

clear;
close all;

setFigureDefaults;

tic;

% Choose TE (train on 0.072, test on 0.084, also 0.108 and 0.036)
TE = 0.084;

% Vessel Type
vsd_name = 'sharan';

% Load data
%   Dimensions of S0:     DBV, OEF, TIME
load(['../../Data/vesselsim_data/vs_arrays/TE',num2str(1000*TE),'_vsData_',vsd_name,'_50.mat']);

% declare global variables
global S_dist param1 tau1
tau1 = tau;

% create a parameters structure with the right params
param1 = genParams('incIV',false,'incT2',true,...
                   'Model','Asymp','TE',TE,...
                   'beta',1.0);
               
nDBV = length(DBVvals);
nOEF = length(OEFvals);

% pre-allocate estimate matrix
% Dimensions:   OEF, DBV
ests = zeros(nOEF,nDBV);
est2 = zeros(nOEF,nDBV);

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
        X1 = fminbnd(@optimScaling,0,3);
%         X1 = fminsearch(@optimPowerScale,[0.5,1.0]);
        
        % Fill in ests matrix
        ests(i1,i2) = X1(1);
%         est2(i1,i2) = X1(2);
        
    end % DBV Loop
    
end % OEF Loop

toc;

% Display Errors
disp('  Scaling Factor:');
disp(['Mean A    :  ',round2str(mean(ests(:)),4)]);
disp(['Mean B    :  ',round2str(mean(est2(:)),4)]);


% plot the results
plotGrid(ests,100*DBVvals,100*OEFvals,...
          'cmap',inferno,...
          'cvals',[0,1],...
          'title','Optimized R2'' Scaling Factor');
      
% plotGrid(est2,100*DBVvals,100*OEFvals,...
%           'cmap',inferno,...
%           'cvals',[0,2],...
%           'title','Optimized R2'' Scaling Factor');

% Key datapoints for comparing
% OEF(52): 40 %    	OEF(88): 55 %       OEF(16): 25   %
% DBV(67):  5 %     DBV(18):  2 %       DBV(92):  6.5 % 



