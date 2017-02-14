function S = MTC_qASE_model(T,PARAMS)
    % MTC_qASE_model.m usage:
    %
    %       S = MTC_qASE_model(T,PARAMS)
    %
    % For use in MTC_Asymmetric_Bayes.m and derived scripts; based on
    % MTC_qBOLD_metro.m, but using a tau-dependent ASE model
    %
    % Calculates the signal vs. tau relationship of a single voxel, for values
    % of tau T, using parameter struct PARAMS. Output S is the same size as T.
    %
    % Uses method described by Yablonskiy & Haacke, 1994, and others.
    %
    % MT Cherukara
    % 16 May 2016
    %
    % 17 May 2016 - Use data generated on 17 May and onwards, with 3
    % compartments.
    %
    % 27 May 2016 - Updated the way the compartments were added together
    
% update parameters
% relaxation rate constant of blood
PARAMS.R2b  = 14.9*PARAMS.Hct + 14.7 + (302.1*PARAMS.Hct + 41.8)*PARAMS.OEF^2;
PARAMS.R2bs = 16.4*PARAMS.Hct + 4.5  + (165.2*PARAMS.Hct + 55.7)*PARAMS.OEF^2;

% magnetisation of blood
% PARAMS.mb   = MTC_BOLD_M(PARAMS.T1b,1./PARAMS.R2b,PARAMS.TR,PARAMS.TE,PARAMS.alph);

% fraction of signal expressed by blood
% PARAMS.lamb = PARAMS.mb.*PARAMS.nb.*(1-PARAMS.lam0).*PARAMS.zeta;

%  characteristic frequency
PARAMS.dw   = (4/3)*pi*PARAMS.gam*PARAMS.dChi*PARAMS.Hct*PARAMS.OEF*PARAMS.B0;

% compartment weightings
w_tis = 1 - PARAMS.lam0 - PARAMS.zeta;
w_csf = PARAMS.lam0;
w_bld = PARAMS.zeta;

% calculate compartments
S_tis = w_tis.*MTC_ASE_tissue(T,PARAMS);
S_csf = w_csf.*MTC_ASE_extra(T,PARAMS);
S_bld = w_bld.*MTC_ASE_blood(T,PARAMS);

% add it all together:
S = PARAMS.S0.*(S_tis + S_csf + S_bld);

% add noise
S = S + max(S).*PARAMS.sig.*randn(1,length(T));
% S = (1 - PARAMS.lam0 - PARAMS.zeta).*S_tis + PARAMS.lam0.*S_csf .* PARAMS.zeta.*S_bld;