function ests = xR2p_optimization
    % To optimize the value of a scaling factor applied to R2' in the asmypototic
    % SDR qBOLD model
    %
    % MT Cherukara
    % 2018-10-24
    %
    % CHANGELOG:
    % 
    % 2018-10-25 (MTC). Make it loop around all OEF and DBV.

clear;
close all;

setFigureDefaults;

tic;

% Load data
%   Dimensions of S0:     DBV, OEF, TIME
load('../../Data/vesselsim_data/vs_arrays/TEST_vsData_sharan_100.mat');

% declare global variables
global S_dist param1 tau1
tau1 = tau;

% create a parameters structure with the right params
param1 = genParams('incIV',false,'incT2',false,...
                   'Model','Asymp');
               
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
        Scale_factor = fminbnd(@optim_scaling,0,3);
        
        % Fill in ests matrix
        ests(i1,i2) = Scale_factor;
        
    end % DBV Loop
    
end % OEF Loop

toc;

% plot the results
plotGrid(ests,DBVvals,OEFvals,...
          'cmap',inferno,...
          'cvals',[0,1],...
          'title','Optimized R2'' Scaling Factor');

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


