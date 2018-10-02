% DBV_Error.m
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

% declare global variables
global S_true param1 tau1;

% load the "true" dataset
load('../../Data/GridSearches/ASE_SurfData_DHBModel');

% assign global variables
tau1 = tau;
param1 = params;

ns = length(par1);      % number of steps

% Pre-allocate results array
errs = zeros(ns,ns);
DBVs = zeros(ns,ns);

% Loop over the first parameter
for i1 = 1:ns
    
    % Loop over the second parameter
    
    for i2 = 1:ns
        
        % Pull out the true signal
        S_true = squeeze(S0(i2,i1,:))';

        % assign true value of parameter 1
        param1.dHb = par1(i1);

        % find the optimum DBV
        DBV = fminbnd(@DBV_loglikelihood,0.01,0.07);
        
        DBVs(i2,i1) = DBV;      % we fill the matrix this way so that DBV is along the x axis
        errs(i2,i1) = DBV - par2(i2);
        
    end % for i2 = 1:length(par2)
    
end % for i1 = 1:length(par1)

toc;


%% Plot result surface

% Plot actual DBV estimate
figure; hold on; box on;
surf(par2,par1,DBVs);
view(2); shading flat;
c=colorbar;
colormap(inferno);

axis([min(par2),max(par2),min(par1),max(par1)]);

title('DBV estimate');
xlabel('DBV');
ylabel('[dHb] (gL^-^1)')

% Plot error in DBV estimate
figure; hold on; box on;
surf(par2,par1,errs);
view(2); shading flat;
c=colorbar;

% set the colorbar so that it is even around 0
mcol = max(abs(errs(:)));
set(c, 'ylim', [-mcol, mcol]);

% colormap(jet);

axis([min(par2),max(par2),min(par1),max(par1)]);

title('Error in DBV estimate');
xlabel('DBV');
ylabel('[dHb] (gL^-^1)')