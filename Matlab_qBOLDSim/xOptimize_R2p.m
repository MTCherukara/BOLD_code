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
TE = 0.080;
% taus = (-8:4:32)./1000;
% taus = (-16:8:64)./1000;
% taus = (-24:12:96)./1000;
% taus = [-4:2:6, 32, 40, 48, 56, 64]./1000;
taus = (-60:2:60)./1000;

% Vessel Type
vsd_name = 'lauwers';

% Are we optimizing two parameters at once?
optim2 = 1;

% Load data
%   Dimensions of S0:     DBV, OEF, TIME
fulldata = load(['../../Data/vesselsim_data/vs_arrays/DataRND_3_TE_',num2str(1000*TE),'_lauwers_100.mat']);

% pull out the right tau value datapoints
[~,Tind,~] = intersect(fulldata.tau,taus);

tau = fulldata.tau(Tind);
S0 = fulldata.S0(:,:,Tind);
DBVvals = fulldata.DBVvals;
OEFvals = fulldata.OEFvals;

% declare global variables
global S_dist param1 tau1
tau1 = tau;

% create a parameters structure with the right params
param1 = genParams('incIV',true,'incT2',true,...
                   'Model','Asymp','TE',TE,...
                   'beta',1.0);
               
nDBV = size(DBVvals,1);
nOEF = size(DBVvals,2);

% pre-allocate estimate matrix
% Dimensions:   OEF, DBV
ests = zeros(nOEF,nDBV);
est2 = ests;

options = optimset('MaxFunEvals',400);

% param1.SR = 0.8-(3*TE);
% param1.alpha = 3.8;
% param1.eta = 1.45;
% param1.SR = 0.47;
% param1.Voff = param1.SR;

%% Do the thing

% Loop over OEF
for i1 = 1:nOEF
    
    % Loop over DBV
    for i2 = 1:nDBV
        
        % pull out the true signal
        S_dist = squeeze(S0(i2,i1,:))';
        
        % assign parameter values
        param1.zeta = DBVvals(i2,i1);
        param1.OEF  = OEFvals(i2,i1);
        
        % find the optimum R2' scaling factor
        if optim2
            X1 = fminsearch(@optimPowerScale,[1,0.3],options);        
        else
            X1 = fminbnd(@optimScaling,0.0001,3);
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

% % plot the results
% plotGrid(ests,100*DBVvals,100*OEFvals,...
%           'cmap',inferno,...
%           'cvals',[-2,2],...
%           'title','Optimized R2'' Scaling Factor');
%       
% if optim2
%     plotGrid(est2,100*DBVvals,100*OEFvals,...
%           'cmap',jet,...
%           'cvals',[-1,1],...
%           'title','Optimized R2'' Scaling Factor');
% end

% Key datapoints for comparing
% OEF(52): 40 %    	OEF(88): 55 %       OEF(16): 25   %
% DBV(67):  5 %     DBV(18):  2 %       DBV(92):  6.5 % 



