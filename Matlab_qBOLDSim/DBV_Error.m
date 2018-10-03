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

% choose which set of simulated data to load
datamodel = 'AsyOEF';

% load the "true" dataset
load(['../../Data/GridSearches/ASE_SurfData_',datamodel,'Model.mat']);


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
        S_true = squeeze(S0(i1,i2,:))';

        % assign true value of parameter 1
        param1.OEF = par1(i1);

        % find the optimum DBV
        DBV = fminbnd(@DBV_loglikelihood,0.01,0.07);
        
        DBVs(i1,i2) = DBV;      % we fill the matrix this way so that DBV is along the x axis
        errs(i1,i2) = DBV - par2(i2);
        
    end % for i2 = 1:length(par2)
    
end % for i1 = 1:length(par1)

toc;


%% Plot result surface

% Plot actual DBV estimate
figure; hold on; box on;
surf(par2,par1,DBVs);
view(2); shading flat;
c=colorbar;
set(c, 'ylim', [0,0.1]);
colormap(inferno);


axis([min(par2),max(par2),min(par1),max(par1)]);
axis square;

title(['DBV estimate (',datamodel,' model)']);
xlabel('DBV');
ylabel(datamodel)

% Plot error in DBV estimate
figure; hold on; box on;
surf(par2,par1,errs);
view(2); shading flat;
c=colorbar;

% set the colorbar so that it is even around 0
set(c, 'ylim', [-0.06, 0.06]);
colormap(jet);

axis([min(par2),max(par2),min(par1),max(par1)]);
axis square;

title(['Error in DBV estimate (',datamodel,' model)']);
xlabel('DBV');
ylabel(datamodel)