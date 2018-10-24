function xR2p_optimization

% To optimize the value of a scaling factor applied to R2' in the asmypototic
% SDR qBOLD model

% MT Cherukara
% 2018-10-24

clear;
close all;

setFigureDefaults;

% Load data
%   Dimensions of S0:     DBV, OEF, TIME
load('../../Data/vesselsim_data/vs_arrays/TEST_vsData_frechet_100.mat');

% What values of OEF and DBV do we want
OEF = 0.4;
DBV = 0.05;

% Find the right indices
iOEF = find(OEFvals > (OEF-1e-6), 1);
iDBV = find(DBVvals > (DBV-1e-6), 1);

% declare global variables
global S_dist param1 tau1

% Pull out the right data
S_dist = squeeze(S0(iDBV,iOEF,:))';
tau1 = tau;

% create a parameters structure with the right params
param1 = genParams('OEF',OEF,'DBV',DBV,...
                   'incIV',false,'incT2',false,...
                   'Model','Asymp');

% optimize it
Scale_factor = fminbnd(@optim_scaling,0,3);

disp(['Optimized R2'' scaling factor: ',num2str(Scale_factor)]);

end


%% Cost function
function LL = optim_scaling(Scale)

    global S_dist param1 tau1
    
    loc_param = param1;
    
    loc_param.R2p = Scale .* loc_param.dw .* loc_param.zeta;
    loc_param.contr = 'R2p';
    
    S_model = qASE_model(tau1,0.072,loc_param);
    S_model = S_model./max(S_model);
    
    LL = log(sum((S_dist-S_model).^2));
    
end

