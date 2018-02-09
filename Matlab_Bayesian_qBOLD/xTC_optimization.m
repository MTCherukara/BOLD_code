% xTC_Optimization

% To optimize the value of Tc (the point of transition between the linear-
% exponential and quadratic-exponential regimes in the asymptotic qBOLD model).
% Using code from MTC_qASE.m and its subroutines.

% MT Cherukara
% 9 February 2018

clear;
close all;

% constants 
params.B0   = 3.0;          % T         - static magnetic field
params.dChi = 2.64e-7;      % parts     - susceptibility difference
params.gam  = 2.67513e8;    % rad/s/T   - gyromagnetic ratio

% scan parameters 
TE  = 0.074;        % s         - echo time
tau = linspace(-0.032,0.072,1000); % for visualising

% model fitting parameters
params.S0   = 100;          % a. units  - signal
params.R2t  = 1/0.087;      % 1/s       - rate constant, tissue
params.R2e  = 4;            % 1/s       - rate constant, extracellular
params.dF   = 5;            % Hz        - frequency shift
params.lam0 = 0.000;        % no units  - ISF/CSF signal contribution
params.zeta = 0.03;        % no units  - deoxygenated blood volume
params.OEF  = 0.40;        % no units  - oxygen extraction fraction
params.Hct  = 0.400;        % no units  - fractional hematocrit
params.geom = 0.3;          % no units  - quadratic regime geometry factor

params.dw   = (4/3)*pi*params.gam*params.dChi*params.Hct*params.OEF*params.B0;   
   

%% Calculate the Analytical tissue signal

S_analytical = MTC_ASE_bessel(tau,TE,params);

myfun = @(x) sum((S_analytical-MTC_ASE_tissue(tau,TE,params,x)).^2);

TC_ideal = fminbnd(myfun,0,0.020);

disp([' OEF  = ',num2str(params.OEF)]);
disp([' DBV  = ',num2str(params.zeta)]);
disp([' Tc   = ',num2str(TC_ideal)]);

