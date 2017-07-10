function S = MTC_qASE_model_long(T,PARAMS)
    % MTC_qASE_model_long.m usage:
    %
    %       S = MTC_qASE_model_long(T,PARAMS)
    %
    % For use in MTC_Asymmetric_Bayes.m and derived scripts; based on
    % MTC_qASE_model.m, but fitting only in the long-tau regime. The CSF
    % compartment is ignored completely here.
    %
    % Uses method described by Yablonskiy & Haacke, 1994, and others.
    %
    % 
    %       Copyright (C) University of Oxford, 2016-2017
    %
    % 
    % Created by MT Cherukara, 10 July 2017
    %
    % CHANGELOG:
   
    
% update parameters
% relaxation rate constant of blood
PARAMS.R2b  = 14.9*PARAMS.Hct + 14.7 + (302.1*PARAMS.Hct + 41.8)*PARAMS.OEF^2;
PARAMS.R2bs = 16.4*PARAMS.Hct + 4.5  + (165.2*PARAMS.Hct + 55.7)*PARAMS.OEF^2;

%  characteristic frequency
PARAMS.dw   = (4/3)*pi*PARAMS.gam*PARAMS.dChi*PARAMS.Hct*PARAMS.OEF*PARAMS.B0;

% compartment weightings
w_tis = 1 - PARAMS.zeta;
w_bld = PARAMS.zeta;

% calculate tissue compartment for long tau only
S_tis = w_tis.*exp(-PARAMS.R2t*PARAMS.TE).*exp(PARAMS.zeta-(PARAMS.R2p.*T));

% get other compartents from their functions
S_bld = w_bld.*MTC_ASE_blood(T,PARAMS);

% add it all together:
S = PARAMS.S0.*(S_tis + S_bld);
