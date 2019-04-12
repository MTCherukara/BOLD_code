% xOptimize_R2p.m
%
% To optimize the value of a scaling factor kappa (here called SR) applied to
% R2' in the asmyptotic SDR qBOLD model. In this case, it applies kappa the
% whole range of tau values, not just the long-tau regime.
%
% Actively used as of 2019-04-01
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

% Choose TE
TE = 0.084;

% Vessel Type
vsd_name = 'sharan';

% Are we optimizing two parameters at once?
optim2 = 1;

% Load data
%   Dimensions of S0:     DBV, OEF, TIME
load(['../../Data/vesselsim_data/vs_arrays/TE',num2str(1000*TE),'_vsData_',vsd_name,'_50.mat']);

% declare global variables
global S_dist param1 tau1
tau1 = tau;

% create a parameters structure with the right params
param1 = genParams('incIV',true,'incT2',true,...
                   'Model','Asymp','TE',TE,...
                   'beta',1.0);
               
nDBV = length(DBVvals);
nOEF = length(OEFvals);

% pre-allocate estimate matrix
% Dimensions:   OEF, DBV
ests = zeros(nOEF,nDBV);
est2 = zeros(nOEF,nDBV);

options = optimset('MaxFunEvals',400);

% param1.SR = 0.8-(3*TE);
% param1.alpha = 3.8;
% param1.eta = 1.45;
param1.SR = 0.44;
param1.Voff = 0.1;

%% Do the thing

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
        if optim2
            X1 = fminsearch(@optimPowerScale,[3.8,1.45],options);        
        else
            X1 = fminbnd(@optimScaling,0,10);
        end
        
        % Fill in ests matrix
        ests(i1,i2) = X1(1);
        if optim2
            est2(i1,i2) = X1(2);
        end
        
    end % DBV Loop
    
end % OEF Loop

toc;

%% Display Errors
disp('  Scaling Factor:');
disp(['Mean A    :  ',round2str(mean(ests(:)),4)]);
if optim2
    disp(['Mean B    :  ',round2str(mean(est2(:)),4)]);
end

% plot the results
plotGrid(ests,100*DBVvals,100*OEFvals,...
          'cmap',inferno,...
          'cvals',[-0,10],...
          'title','Optimized R2'' Scaling Factor');
      
if optim2
    plotGrid(est2,100*DBVvals,100*OEFvals,...
          'cmap',jet,...
          'cvals',[-5,5],...
          'title','Optimized R2'' Scaling Factor');
end

% Key datapoints for comparing
% OEF(52): 40 %    	OEF(88): 55 %       OEF(16): 25   %
% DBV(67):  5 %     DBV(18):  2 %       DBV(92):  6.5 % 



