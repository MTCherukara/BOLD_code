% xOptimizeTan.m
%
% Load in some Fabber results and optimise the parameters of a tan function
% using fminsearch. Based on xSimScatter.m and xSigmoidMapping.m
%
% 29 July 2019
% MT Cherukara

clear;
close all;
setFigureDefaults;


%% INITIALIZATION

% choose Fabber set number
setnum = 752;

% Choose set of random OEF and DBV values
paramPairs = 5;

% Kappa correction to R2'
kappa = 0.43;

% Optimization options
options = optimset('MaxFunEvals',1e4);


%% LOADING AND PRE-PROCESSING

% Data directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_ModelFits/';

% Load true values
load(['../Matlab_VesselSim/Sim_OEF_DBV_pairs_',num2str(paramPairs),'.mat']);
OEFvals = OEFvals(:)';
DBVvals = DBVvals(:)';

% Find fabber results the directory
fdname = dir([resdir,'fabber_',num2str(setnum),'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% Load the data
volR = LoadSlice([fabdir,'mean_R2p.nii.gz'],1);
volV = LoadSlice([fabdir,'mean_DBV.nii.gz'],1);

% Vectorize
vecR = volR(:);
vecV = volV(:);

% Calculate Ratio (also scales OEF to 0-100)
vecOEF = kappa.*vecR./(3.55.*vecV);


%% OPTIMIZE

% Declare some global parameters
global truOEF estOEF

% Remove data points where OEF > 80% or OEF < 10% (because we don't care about
% these)
vecBad = (OEFvals' > 0.9) + (OEFvals' < 0.1) ...
       + (vecOEF > 60) + (vecOEF < 0);% ...
%        + (DBVvals' > 0.05) + (DBVvals' < 0.005);

truOEF = 100*OEFvals(vecBad == 0)';
estOEF = vecOEF(vecBad == 0);

p1 = 0.15;%0.05:0.001:0.2;

fvals = zeros(1,length(p1));
xvals = zeros(3,length(p1));

for ii = 1:length(p1)
    
    [X1,FV] = fminsearch(@optimTan,[10,p1(ii),10],options);
    
    fvals(ii) = FV;
    xvals(:,ii) = X1;
end
    
    
% X1(1) = 30;
% X1(3) = 30;
X1(4) = 0;

% evaluate the corrected version
corOEF = 1*X1(1).*tan(X1(2).*(vecOEF+X1(4))) + X1(3);


%% DISPLAY RESULTS
disp(['p1 = ',num2str(X1(1))]);
disp(['p2 = ',num2str(X1(2))]);
disp(['p3 = ',num2str(X1(3))]);
disp(['p4 = ',num2str(X1(4))]);


%% PLOT ORIGINAL
figure; box on; hold on; axis square; grid on;

% plot
scatter(100*OEFvals,vecOEF,36,DBVvals,'filled');

% unity line
plot([0,100],[0,100],'k-','LineWidth',1);

% formatting
colormap(plasma);
axis([0,100,0,100]);
xlabel('True OEF (%)');
ylabel('Estimated OEF (%)');
yticks([0:20:100]);
xticks([0:20:100]);


%% PLOT CORRETED VERSION 
figure; box on; hold on; axis square; grid on;

% plot
scatter(100*OEFvals,corOEF,36,DBVvals,'filled');

% unity line
plot([0,100],[0,100],'k-','LineWidth',1);

% formatting
colormap(plasma);
axis([0,100,0,100]);
xlabel('True OEF (%)');
ylabel('Estimated OEF (%)');
yticks([0:20:100]);
xticks([0:20:100]);
