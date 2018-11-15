% xOptimizeSet_R2pScaling.m
%
% Optimize the value of a scaling factor applied to R2' in the asmypototic
% SDR qBOLD model, but for a single dataset. Derived from xR2p_optimization.m
%
% MT Cherukara
% 2018-10-26

clear;
close all;

setFigureDefaults;

tic;

TEs = [36,56,72,88,108]./1000;

% declare global variables
global S_dist param1 tau1

% Pre-allocate
SR = zeros(1,length(TEs));

% loop over TEs
for tt = 1:length(TEs)
    
    TE = TEs(tt);

    % Load data
    load(['ASE_Data/Frechet_Data_TE_',num2str(1000*TE),'.mat']);

    tau1 = tau;

    % create a parameters structure with the right params
    param1 = genParams('incIV',false,'incT2',false,...
                       'Model','Asymp','TE',TE,...
                       'OEF',0.40,'DBV',0.05);
               
	% true signal
    S_dist = S0';
    
    % find the optimum R2' scaling factor
    Scale_factor = fminbnd(@optimScaling,0,3);
    
    % Fill in ests matrix
    SR(tt) = Scale_factor;
    
    
end % TE loop

toc;

