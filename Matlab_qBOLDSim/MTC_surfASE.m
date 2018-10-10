% MTC_surfASE.m
%
% Generates a 2D surface of ASE datasets along 2 chosen variables, based on
% MTC_qASE.m, requires qASE_model.m and updateParams.m
%
% 
%       Copyright (C) University of Oxford, 2016-2018
%
% 
% Created by MT Cherukara, 2016
%
% CHANGELOG:
%
% 2018-10-01 (MTC). Re-written to utilize parallel computing, and to use the new
%       standard of the model

clear;
% close all;

tic;


%% Set Parameters

% constants 
params.B0   = 3.0;          % T         - static magnetic field
params.dChi = 0.264e-6;     % parts     - susceptibility difference
params.gam  = 2.67513e8;    % rad/s/T   - gyromagnetic ratio
params.kap  = 0.003;        % ?         - conversion between Hct and [Hb]

% scan parameters 
params.TE   = 0.072;        % s         - echo time
params.TR   = 3.000;        % s         - repetition time
params.TI   = 0;        % s         - FLAIR inversion time

% model fitting parameters
params.S0   = 100;          % a. units  - signal
params.R2t  = 11.5;         % 1/s       - rate constant, tissue
params.R2e  = 4;            % 1/s       - rate constant, extracellular
params.dF   = 5;            % Hz        - frequency shift
params.lam0 = 0.00;         % no units  - ISF/CSF signal contribution
params.zeta = 0.03;         % no units  - deoxygenated blood volume
params.OEF  = 0.40;         % no units  - oxygen extraction fraction
params.Hct  = 0.400;        % no units  - fractional hematocrit
params.dHb  = 53.3;         % g/L       - deoxyhaemoglobin concentration
params.dhb  = 1.6;          % ?         - deoxyhaemoglobin CONTENT [dHb]*zeta
params.T1t  = 1.200;        % s         - tissue T1
params.T1b  = 1.580;        % s         - blood T1
params.T1e  = 3.870;        % s         - CSF T1

% analysis parameters
params.tc_man = 0;          % BOOL      - should Tc be defined manually?
params.tc_val = 0.0;        % s         - manual Tc (if tc_man = 1)
params.model  = 'Full';     % STRING    - model type: 'Full','Asymp','Phenom'
params.contr  = 'OEF';      % STRING    - contrast source: 'OEF','R2p','dHb',...
params.incT1  = 0;          % BOOL      - should T1 differences be considered?


%% Surface Parameters

% number of points on surface (in each dimension)
NS1 = 100;   % OEF
NS2 = 100;   % DBV

tau = (-28:1:64)/1000;
% par1 = linspace(25,80,NS1);         % dHb
par1 = linspace(0.1875,0.60,NS1);   % OEF
par2 = linspace(0.01,0.07,NS2);

NT = length(tau);   % number of points on surface, for loops


%% Generate Surface
% Dimensions:   TIME, DBV, OEF
S0 = zeros(NT,NS2,NS1);
% DBV = zeros(NS2,NS1);
% OEF = zeros(NS2,NS1);

% Loop over first parameter
parfor i1 = 1:NS1
    
    % Create and update a PARAM object
    looppars = updateParams(par1(i1),params,'OEF');
    
    % Pre-allocate a matrix to fill within the inner loop
    % Dimensions:   TIME, DBV
    S_in = zeros(NT,NS2);
    
    par22 = par2; % to avoid using par2 as a broadcast variable
    
    % Loop over second parameter
    for i2 = 1:NS2
        
        % Create and update a new PARAM object
        inpars = updateParams(par22(i2),looppars,'zeta');
        
        DBV(i2,i1) = par22(i2);
        OEF(i2,i1) = par1(i1);
        
        % Calculate Model
        S_mod = qASE_model(tau,params.TE,inpars);
        
        % Normalize
        S_mod = S_mod./max(S_mod);
        
        % Insert into S0
        S_in(:,i2) = S_mod;
     
    end %  for i2 = 1:NS2
    
    S0(:,:,i1) = S_in;
    
end % parfor i1 = 1:NS1

% Shift dimensions:     DBV, OEF, TIME
S0 = shiftdim(S0,1);

toc;

%% Save out results
save('ASE_TauData','S0','tau','par1','par2','params');

%% Plot a figure

% create docked figure
figure; hold on; box on;

% Plot 2D grid search results
surf(par2,par1,log(S0(:,:,3))');
% surf(par2,par1,DBV);
view(2); shading flat;
c=colorbar;

axis([min(par2),max(par2),min(par1),max(par1)]);
xlabel('DBV (%)');
ylabel('OEF (%)');

xticks(0.01:0.01:0.07);
xticklabels({'1','2','3','4','5','6','7'});
yticks(0.2:0.1:0.6);
yticklabels({'20','30','40','50','60'});
