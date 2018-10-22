% D_Error.m
%
% Calculate the error in estimates of deoxyhaemoglobin content D using the qBOLD
% model, against various vessel distributions
%
% Modified from DBV_Error.m
%
% MT Cherukara
% 2018-10-22

clear;
setFigureDefaults;
close all;

tic;

% Where the data is stored
simdir = '../../Data/vesselsim_data/';
           
% Which distribution we want - 'sharan' or 'frechet'
vsd_name = 'sharan';    

% Which parameter do we want to plot - 'R2p' or 'D'
plot_par = 'R2p';

% Do we want to plot the D estimates/true values?
plot_estD = 1;      % BOOL
plot_truD = 1;      % BOOL

% Do we want to plot the relative error?
plot_rError = 1;    % BOOL

% Random scaling constants
scaleOEF = 1.0;
scaleR2p = 1/(1-0.61);

% Content scaling constant
kappa = 0.03;

% declare global variables
global S_true tau1;

% S0 dimensions:    DBV, OEF, TIME

% generate a params structure
param1 = genParams;

% ignore the blood compartment
param1.incIV = 0;

% Load the actual dataset we want to examine
load([simdir,'vs_arrays/TEST_vsData_',vsd_name,'_100.mat']);
% load([simdir,'simulated_data/ASE_TauData_FullModel.mat']);

% Depending on the data type we might be using
if ~exist('OEFvals','var')
    OEFvals = par1;
    DBVvals = par2;
end

% only use tau values >= 20ms
cInd = find(tau >= 0.020);
tauC = tau(cInd);

% reduce S0 to only include the taus we want
%   Dimensions:     DBV, OEF, TIME
S0 = S0(:,:,cInd);

% assign global variable
tau1 = tauC;

nDBV = length(DBVvals);
nOEF = length(OEFvals);

% pre-allocate error and DBV matrices
% Dimensions:   OEF, DBV
errs = zeros(nOEF,nDBV);
oDs = zeros(nOEF,nDBV);
tDs = zeros(nOEF,nDBV);

% Loop over OEF
for i1 = 1:nOEF
    
    % Loop over DBV
    for i2 = 1:nDBV
        
        % Calculate true values
        tOEF = scaleOEF .* OEFvals(i1);
        tDBV = DBVvals(i2);
        
        tR2p = (4/3) * pi * param1.gam * param1.B0 * param1.dChi * param1.Hct * tOEF * tDBV;
        tD = param1.Hct .* tOEF .* tDBV ./ kappa;
 
        
        % Pull out the true signal
        S_true = log(squeeze(S0(i2,i1,:))');
        
        % find the optimum R2'
        oR2p = fminbnd(@R2p_loglikelihood,0,15);
        
        % scale R2p by some factor
        oR2p = scaleR2p .* oR2p;
        
        % calculate optimum D
        oD = (3/4) * oR2p / (pi * param1.gam * param1.B0 * param1.dChi * kappa);
 
        if strcmp(plot_par,'R2p')
            % Dimensions: OEF, DBV
            oDs(i1,i2) = oR2p;
            tDs(i1,i2) = tR2p;
        else
           % Dimensions: OEF, DBV
            oDs(i1,i2) = oD;
            tDs(i1,i2) = tD;
        end
        
    end % DBV Loop
    
end % OEF Loop

toc;


%% Plot True Parameter Value
if plot_truD
    
    % True values
    figure; hold on; box on;
    surf(DBVvals,OEFvals,tDs);
    
    view(2); shading flat;
    colorbar;
    axis([min(DBVvals),max(DBVvals),min(OEFvals),max(OEFvals)]);
    axis square;
    
    if strcmp(plot_par,'R2p')
        caxis([0,15]);
        title('True R_2'' (s^-^1)');
        colormap(viridis);
    else
        title('^ True dHb Content_ ');
        colormap(inferno);
    end
    
    xlabel('DBV (%)');
    xticks(0.01:0.01:0.07);
    xticklabels({'1','2','3','4','5','6','7'});
    ylabel('OEF (%)');
    yticks(0.2:0.1:0.6);
    yticklabels({'20','30','40','50','60'})
    
end % if plot_truD


%% Plot Parameter Estimate
if plot_estD
    
    figure; hold on; box on;
    surf(DBVvals,OEFvals,oDs);
    
    view(2); shading flat;
    colorbar;
    axis([min(DBVvals),max(DBVvals),min(OEFvals),max(OEFvals)]);
    axis square;
    
    if strcmp(plot_par,'R2p')
        caxis([0,15]);
        title('Estimated R_2'' (s^-^1)');
        colormap(viridis);
    else
        title('^ Estimated dHb Content_ ');
        colormap(inferno);
    end

    xlabel('DBV (%)');
    xticks(0.01:0.01:0.07);
    xticklabels({'1','2','3','4','5','6','7'});
    ylabel('OEF (%)');
    yticks(0.2:0.1:0.6);
    yticklabels({'20','30','40','50','60'})
    
end % if plot_estD


%% Plot Error in DBV Estimate

errs = tDs - oDs; 

figure; hold on; box on;
surf(DBVvals,OEFvals,errs);

view(2); shading flat;
colorbar;
colormap(jet);
axis([min(DBVvals),max(DBVvals),min(OEFvals),max(OEFvals)]);
axis square;

if strcmp(plot_par,'R2p')
    caxis([-10,10]);
    title('Error in R_2'' (s^-^1)');
else
    title('^ Error in dHb Content_ ');
end

xlabel('DBV (%)');
xticks(0.01:0.01:0.07);
xticklabels({'1','2','3','4','5','6','7'});
ylabel('OEF (%)');
yticks(0.2:0.1:0.6);
yticklabels({'20','30','40','50','60'})


%% Plot relative DBV error

if plot_rError
    
    % calculate relative error
    %       Dimensions: OEF, DBV
    rel_err = errs ./ tDs;

    figure; hold on; box on;
    surf(DBVvals,OEFvals,100.*rel_err);
    
    view(2); shading flat;
    colorbar;
    caxis([-100,100]);
    colormap(jet);
    axis([min(DBVvals),max(DBVvals),min(OEFvals),max(OEFvals)]);
    axis square;
    
    title('^ Relative Error (%)_ ');
    xlabel('DBV (%)');
    xticks(0.01:0.01:0.07);
    xticklabels({'1','2','3','4','5','6','7'});
    ylabel('OEF (%)');
    yticks(0.2:0.1:0.6);
    yticklabels({'20','30','40','50','60'})
    
end