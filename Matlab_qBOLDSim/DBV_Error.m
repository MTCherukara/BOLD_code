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

% load the OEF dataset in order to get a params structure
load('../../Data/vesselsim_data/simulated_data/ASE_SurfData_OEFModel.mat');

% load the dataset we want to examine
load('../../Data/vesselsim_data/vs_arrays/vsData_frechet_100.mat');

% assign global variables
tau1 = tau;
param1 = params;

ns = length(par1);      % number of steps

% Pre-allocate results array
errs = zeros(ns,ns);
DBVs = zeros(ns,ns);

% Loop over OEF
for i1 = 1:ns
    
    % Loop over DBV
    for i2 = 1:ns
        
        % Pull out the true signal
        S_true = squeeze(S0(i1,i2,:))';

        % assign true value of parameter 1
        param1.OEF = par1(i1);

        % find the optimum DBV
        DBV = fminbnd(@DBV_loglikelihood,0.001,0.1);
        
        DBVs(i1,i2) = DBV;      % we fill the matrix this way so that DBV is along the x axis
        errs(i1,i2) = DBV - par2(i2);
        
    end % DBV Loop
    
end % OEF Loop

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

title('DBV estimate');
xlabel('DBV (%)');
xticks([0.01,0.02,0.03,0.04,0.05,0.06,0.07]);
xticklabels({'1','2','3','4','5','6','7'});
ylabel('OEF (%)');
yticks([0.2,0.3,0.4,0.5,0.6]);
yticklabels({'20','30','40','50','60'})


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

title('Error in DBV estimate');
xlabel('DBV (%)');
xticks([0.01,0.02,0.03,0.04,0.05,0.06,0.07]);
xticklabels({'1','2','3','4','5','6','7'});
ylabel('OEF (%)');
yticks([0.2,0.3,0.4,0.5,0.6]);
yticklabels({'20','30','40','50','60'})