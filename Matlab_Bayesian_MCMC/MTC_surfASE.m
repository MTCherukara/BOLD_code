% MTC_surfASE.m

% generate a 3D surface of signal as a function of both TE and tau for
% given values of OEF and DBV

clear;
close all;


%% Set Parameters

% noise
params.sig  = 0.00;

tau = (-20:80)./1000;
TE  = (20:80)./1000;
OEF = 0.35:0.01:0.6;
DBV = 0.01:0.001:0.05;


% constants 
params.B0   = 3.0;          % T         - static magnetic field
params.dChi = 2.64e-7;      % parts     - susceptibility difference
params.gam  = 2.67513e8;    % rad/s/T   - gyromagnetic ratio

% model parameters
params.S0   = 1;            % a. units  - signal
params.R2t  = 1/0.110;      % 1/s       - rate constant, tissue
params.R2e  = 4;            % 1/s       - rate constant, extracellular
params.dF   = 5;            % Hz        - frequency shift
params.lam0 = 0.000;        % no units  - ISF/CSF signal contribution
params.Hct  = 0.40;         % no units  - fractional hematocrit


%% Generate Surface
S0 = zeros(length(OEF),length(DBV),length(TE),length(tau));
nt = length(TE).*length(tau);   % number of points on surface, for loops

for iO = 1:length(OEF)
    
    params.OEF = OEF(iO);
    
    % calculate a few things
    params.R2bs = 14.9*params.Hct + 14.7 + (302.1*params.Hct + 41.8)*params.OEF^2;
    params.R2b  = 16.4*params.Hct + 4.5  + (165.2*params.Hct + 55.7)*params.OEF^2;
    params.dw   = (4/3)*pi*params.gam*params.dChi*params.Hct*params.OEF*params.B0;
    
    for iZ = 1:length(DBV)
        
        params.zeta = DBV(iZ);
        
        for iT = 1:length(TE)
            
            params.TE = TE(iT);
            
            % run the model
            S0(iO,iZ,iT,:) = MTC_qASE_model(tau,params);
        end
    end
end


%% Analysis

% choose which values of OEF and DBV we want to specifically look at
OEF_1 = 0.40;
DBV_1 = 0.03;

[~,i1] = min(abs(OEF - OEF_1));
[~,i2] = min(abs(DBV - DBV_1));

% isolate 3D matrices for those chosen values
SY = squeeze(S0(:,i2,:,:));     % matrix with changes in OEF (or Y)
SZ = squeeze(S0(i1,:,:,:));     % matrix with changes in DBV (or Z)

% loop through all points on the surface to calculate the gradient at each
SYG = squeeze( (SY(1,:,:) - SY(end,:,:))./SY(1,:,:) );
SZG = squeeze( (SZ(1,:,:) - SZ(end,:,:))./SZ(1,:,:) );


%% Plot Results
figure(1);
imagesc(1000*tau,1000*TE,SYG); hold on;
c=colorbar;
xlabel('180 Pulse Offset \tau (ms)');
ylabel('Echo Time TE (ms)');
title('Effect of Changing OEF on Signal')
set(gca,'FontSize',16,'YDir','normal');
set(c,'FontSize',16)
set(gcf,'WindowStyle','docked');

figure(2);
imagesc(1000*tau,1000*TE,SZG); hold on;
c=colorbar;
xlabel('180 Pulse Offset \tau (ms)');
ylabel('Echo Time TE (ms)');
title('Effect of Changing DBV on Signal')
set(gca,'FontSize',16,'YDir','normal');
set(c,'FontSize',16)
set(gcf,'WindowStyle','docked');
