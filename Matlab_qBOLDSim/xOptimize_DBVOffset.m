% DBV offset optimization. Derived from xR2p_optimization.m
%
% MT Cherukara
% 2018-10-30

clear;
close all;

setFigureDefaults;

tic;

% Choose TE (train on 0.072, test on 0.084, also 0.108 and 0.036)
TE = 0.072;

% Where the data is stored
simdir = '../../Data/vesselsim_data/';

% Which distribution we want - 'sharan' or 'frechet'
vsd_name = 'sharan';    

% Load data
%   Dimensions of S0:     DBV, OEF, TIME
load([simdir,'vs_arrays/TE',num2str(1000*TE),'_vsData_',vsd_name,'_100.mat']);

% declare global variables
global S_dist param1 tau1

% only use tau values >= 20ms
cInd = find(tau >= -0.20);
tauC = tau(cInd);

% reduce S0 to only include the taus we want
%   Dimensions:     DBV, OEF, TIME
S0 = S0(:,:,cInd);

% assign global variable
tau1 = tauC;

% create a parameters structure with the right params
param1 = genParams('incIV',false,'incT2',false,...
                   'Model','Asymp','TE',TE);
               
nDBV = length(DBVvals);
nOEF = length(OEFvals);

% pre-allocate estimate matrix
% Dimensions:   OEF, DBV
ests = zeros(nOEF,nDBV);

% Loop over OEF
for i1 = 1:nOEF
    
    % Loop over DBV
    for i2 = 1:nDBV
        
        % pull out the true signal
        S_dist = squeeze(S0(i2,i1,:))';
        
        % assign parameter values
        param1.zeta = DBVvals(i2);
        param1.OEF  = OEFvals(i1);
        
        % find the optimum R2' scaling factor
        Offset = fminbnd(@optimOffset,-2,2);
        
        % Fill in ests matrix
        ests(i1,i2) = Offset;
        
    end % DBV Loop
    
end % OEF Loop

toc;

md = max(abs(ests(:)));

% plot the results
plotGrid(ests,DBVvals,OEFvals,...
          'cmap',jet,...
          'cvals',[-md,md],...
          'title','Optimized DBV Offset \beta');

% Key datapoints for comparing
% OEF(52): 40 %    	OEF(88): 55 %       OEF(16): 25   %
% DBV(67):  5 %     DBV(18):  2 %       DBV(92):  6.5 % 



