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

% Where the data is stored
simdir = '../../Data/vesselsim_data/';

% Which tau values do we want to look at
cTaus = (-28:4:64)./1000;
nt = length(cTaus);

% Which distribution we want - 'sharan' or 'frechet'
vsd_name = 'sharan';    

% Which model do we want to compare to
mod_name = 'Phenom';

% declare global variables
global S_true param1 tau1;

% S0 dimensions:    DBV, OEF, TIME

% generate a params structure
param1 = genParams;

% Load the actual dataset we want to examine
load([simdir,'vs_arrays/vsData_',vsd_name,'_100.mat']);
% load([simdir,'simulated_data/ASE_TauData_FullModel.mat']);

% Depending on the data type we might be using
if ~exist('OEFvals','var')
    OEFvals = par1;
    DBVvals = par2;
end

% pull out the right tau values
cInd = find(ismember(tau,cTaus));
tauC = tau(cInd);

% reduce S0 to only include the taus we want
%   Dimensions:     DBV, OEF, TIME
S0 = S0(:,:,cInd);

% assign global variables
tau1 = tauC;

nDBV = length(DBVvals);
nOEF = length(OEFvals);

% Add random gaussian noise to S0, with specified SNR
SNR = inf;
sigma = mean(S0(:))./SNR;
S0 = S0 + sigma.*randn(nOEF,nDBV,nt);

% Pre-allocate results array
% Dimensions:   OEF, DBV
errs = zeros(nOEF,nDBV);
DBVs = zeros(nOEF,nDBV);

% Loop over OEF
for i1 = 1:nOEF
    
    % Loop over DBV
    for i2 = 1:nDBV
        
        % Pull out the true signal
        S_true = squeeze(S0(i2,i1,:))';

        % assign true value of parameter 1
        param1.OEF = 0.7 .* OEFvals(i1);
        param1.model = mod_name;

        % find the optimum DBV
        DBV = fminbnd(@DBV_loglikelihood,0.01,0.07);
        
        % Dimensions: OEF, DBV
        DBVs(i1,i2) = DBV;      % we fill the matrix this way so that DBV is along the x axis
        errs(i1,i2) = DBV - DBVvals(i2);
        
    end % DBV Loop
    
end % OEF Loop

toc;


%% Plot Actual DBV Estimate
figure; hold on; box on;
surf(DBVvals,OEFvals,DBVs);
view(2); shading flat;
c=colorbar;
set(c, 'ylim', [0.01,0.07]);
colormap(inferno);


axis([min(DBVvals),max(DBVvals),min(OEFvals),max(OEFvals)]);
axis square;

title(['DBV estimate (',mod_name,' model)']);
xlabel('DBV (%)');
xticks(0.01:0.01:0.07);
xticklabels({'1','2','3','4','5','6','7'});
ylabel('OEF (%)');
yticks(0.2:0.1:0.6);
yticklabels({'20','30','40','50','60'})


%% Plot Error in DBV Estimate

figure; hold on; box on;
surf(DBVvals,OEFvals,errs);
view(2); shading flat;
c=colorbar;

% set the colorbar so that it is even around 0
caxis([-0.05,0.05]);
colormap(jet);

axis([min(DBVvals),max(DBVvals),min(OEFvals),max(OEFvals)]);
axis square;

title(['Error in DBV estimate (',mod_name,' model)']);
xlabel('DBV (%)');
xticks(0.01:0.01:0.07);
xticklabels({'1','2','3','4','5','6','7'});
ylabel('OEF (%)');
yticks(0.2:0.1:0.6);
yticklabels({'20','30','40','50','60'})