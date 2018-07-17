function [S,PARAMS] = MTC_qASE_model2(TAU,TE,PARAMS,NODW)
    % Calculates ASE signal from a single voxel. Usage:
    %
    %       [S,PARAMS] = MTC_qASE_model2(TAU,TE,PARAMS,NODW)
    %
    % Input:  TAU    - A vector of tau values (refocussing pulse offsets)
    %                  in seconds.
    %         TE     - A single value, or a vector of equal length to TAU,
    %                  of echo time values in seconds.
    %         PARAMS - The structure containing all the parameters used in
    %                  the simulation and model inference. This can be
    %                  optionally returned as an output, with extra values
    %                  (such as dw) which are calculated within, returned
    %                  as the output.
    %         NODW   - [OPTIONAL] A boolean, to be used when inferring on
    %                  R2', which changes the order in which things are
    %                  calculated.
    %
    % Output: S      - A vector of signal values of same size as T.
    %         PARAMS - [OPTIONAL] The modified parameter structure.
    %
    % Based on MTC_qASE_model.m, but with a change made to allow for difference
    % between true compartment volume fraction (DBV, lambda0) and signal
    % contribution, based on He & Yablonskiy, 2007.    
    %
    % 
    %       Copyright (C) University of Oxford, 2018
    %
    % 
    % Created by MT Cherukara, 16 May 2018
    %
    % CHANGELOG:
   
    
% UPDATE PARAMETERS:

if ~exist('NODW','var')
    NODW = 0;
end

% characteristic frequency - this will not be calculated if doing R2'-DBV inference
if NODW
    % if we are inferring on R2', we want to change the order we do things
    % in slightly:
    PARAMS.dw = PARAMS.R2p ./ PARAMS.zeta;
    PARAMS.OEF = PARAMS.dw ./ ( (4/3)*pi*PARAMS.gam*PARAMS.dChi*PARAMS.Hct*PARAMS.B0 );
    
else
    % otherwise, proceed as normal and calculate dw:
    PARAMS.dw   = (4/3)*pi*PARAMS.gam*PARAMS.dChi*PARAMS.Hct*PARAMS.OEF*PARAMS.B0;    
end

% spin densities
nt = 0.723;
ne = 0.070;
nb = 0.723;
    
% relaxation rate constant of blood
PARAMS.R2b  =  4.5 + 16.4*PARAMS.Hct + (165.2*PARAMS.Hct + 55.7)*PARAMS.OEF^2;
PARAMS.R2bp = 10.2 -  1.5*PARAMS.Hct + (136.9*PARAMS.Hct - 13.9)*PARAMS.OEF^2;

% calculate compartment steady-state magnetization
m_tis = MTC_magnetization(TAU,TE,PARAMS.TR,PARAMS.T1t,1./PARAMS.R2t,PARAMS.TI);
m_bld = MTC_magnetization(TAU,TE,PARAMS.TR,PARAMS.T1b,1./PARAMS.R2b,PARAMS.TI);
m_csf = MTC_magnetization(TAU,TE,PARAMS.TR,PARAMS.T1e,1./PARAMS.R2e,PARAMS.TI);

% pull out parameters
Ve = PARAMS.lam0;
Vb = PARAMS.zeta;

% calculate compartment weightings
w_csf = (ne.*m_csf.*Ve) ./ ( (nt.*m_tis) + (ne.*m_csf.*Ve) - (nt.*m_tis.*Ve) );
w_bld = m_bld.*nb.*(1-w_csf).*Vb;
w_tis = 1 - (w_csf + w_bld);

% CALCULATE MODEL:

% comparments
S_tis = w_tis.*MTC_ASE_tissue(TAU,TE,PARAMS);
S_csf = w_csf.*MTC_ASE_extra(TAU,TE,PARAMS);
S_bld = w_bld.*MTC_ASE_mnblood(TAU,TE,PARAMS);

% add it all together:
S = PARAMS.S0.*(S_tis + S_csf + S_bld);