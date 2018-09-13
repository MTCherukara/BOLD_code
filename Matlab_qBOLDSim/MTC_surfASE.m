% MTC_surfASE.m

% generate a 3D surface of signal as a function of both TE and tau for
% given values of OEF and DBV

%
% 2018-09-13 (MTC). NB: THIS SCRIPT NEEDS TO BE UPDATED TO REFLECT CHANGES TO
%       THE MODEL CALCULATION FUNCTIONS!!

clear;
close all;


%% Set Parameters

% noise
params.sig  = 0.05;

tau = (-20:80)./1000;
TE  = (20:80)./1000;
OEF = 0.30:0.05:0.8;
DBV = 0.01:0.005:0.05;


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
            S0(iO,iZ,iT,:) = qASE_model(tau,TE(iT),params);
        end
    end
end

%% Save out results
save('ASE_SurfData_sigma_5','S0','TE','tau','OEF','DBV','params');

