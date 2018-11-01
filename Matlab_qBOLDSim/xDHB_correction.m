% xDHB_correction.m

% Attempting to fit a power-law function to [dHb]

% MT Cherukara
% 2018-11-01

clear;
% close all;

setFigureDefaults;

tic;

% declare global variables
global KK arrDBV arrDHB arrTAU arrS0

% Load some data
VSdata = load('..\..\Data\vesselsim_data\vs_arrays\TE72_vsData_sharan_100.mat');

% Pull out data
tau = VSdata.tau;
TE = VSdata.TE;
OEFvals = VSdata.OEFvals;
DBVvals = VSdata.DBVvals;

% Do we include the R2' scaling correction?
SR = 0.7574*exp(-4.551*TE);
% SR = 1;

% Log-transform and normalize S0 (assume that tau=0 is the at element 8)
%   Dimensions:     DBV, OEF, TIME
S0 = log(VSdata.S0+1);
S0 = S0./repmat(squeeze(S0(:,:,8)),1,1,length(tau));

% Extract the long-tau values
tauC = tau(12:end);
arrS0 = S0(:,:,12:end);

% Array sizes
nDBV = length(DBVvals);
nOEF = length(OEFvals);
nt = length(tauC);

% generate a params structure
param1 = genParams('incIV',false,'incT2',false,...
                   'Model','Asymp',...
                   'SR',1,...
                   'TE',TE);


% define constant
KK = (4/3)*pi*SR*param1.gam*param1.B0*param1.dChi;

% generate revelant arrays
%   Dimensions:     DBV, OEF, TIME
arrDBV = repmat(DBVvals',1,nOEF,nt);
arrDHB = repmat(OEFvals,nDBV,1,nt).*param1.Hct;
arrTAU = shiftdim(repmat(tauC',1,nDBV,nOEF),1);

% Solver starting points
xx = [0.03,1.0];
x1 = fminsearch(@solveDHB,xx);

toc;

% Print results
disp(['Optimized kappa = ',num2str(x1(1))]);
disp(['Optimized beta  = ',num2str(x1(2))]);
