function [S,PARAMS] = MTC_qASE_model(TAU,TE,PARAMS,NODW)
    % Calculates ASE signal from a single voxel. Usage:
    %
    %       [S,PARAMS] = MTC_qASE_model(TAU,TE,PARAMS,NODW)
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
    % For use in MTC_qASE.m, MTC_Asymmetric_Bayes.m, MTC_ASE_MH.m, and
    % other derived scripts. Based on MTC_qBOLD_metro.m (now deleted), but
    % using a tau-dependent ASE model. Uses the method described by
    % Yablonskiy & Haacke (1994), and He & Yablonskiy (2007). 
    %
    % 
    %       Copyright (C) University of Oxford, 2016-2017
    %
    % 
    % Created by MT Cherukara, 16 May 2016
    %
    % CHANGELOG:
    %
    % 2017-10-10 (MTC). Added the option to supply a vector of TE values
    %       outside the PARAMS struct, and made changes to the called model
    %       functions MTC_ASE_tissue.m, MTC_ASE_extra.m, MTC_ASE_blood.m,
    %       in order to allow for inference on data with any arbitrary set
    %       of TE-TAU pairs.
    %
    % 2017-08-07 (MTC). Added a control in the form of PARAMS.noDW to  
    %       change the way things are done when we're trying to infer on 
    %       R2'. Added PARAMS as an optional output. 
    %       
    % 2017-07-10 (MTC). Commented out the PARAMS.dw recalculation in order
    %       to use this for the R2' and zeta estimation (alongside
    %       MTC_qASE_model_long.m). This should be put back to normal if
    %       using this for any other grid-search (e.g. the classic OEF-DBV)
    %
    % 2016-05-27 (MTC). Updated the way the compartments were summed up.
   
    
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
    
% relaxation rate constant of blood
PARAMS.R2b  =  4.5 + 16.4*PARAMS.Hct + (165.2*PARAMS.Hct + 55.7)*PARAMS.OEF^2;
PARAMS.R2bp = 10.2 -  1.5*PARAMS.Hct + (136.9*PARAMS.Hct - 13.9)*PARAMS.OEF^2;

% weighting of blood mb
% mb = exp(-(TE-TAU).*PARAMS.R2b).*(1 - exp(-(3-(TE-TAU)/2)/1.58) + exp(-3/1.58));

% compartment weightings
w_csf = PARAMS.lam0;
% w_bld = 0.66.*mb.*PARAMS.zeta;
w_bld = PARAMS.zeta;
w_tis = 1 - (w_csf + w_bld);


% CALCULATE MODEL:

% comparments
S_tis = w_tis.*MTC_ASE_tissue(TAU,TE,PARAMS);
S_csf = w_csf.*MTC_ASE_extra(TAU,TE,PARAMS);
S_bld = w_bld.*MTC_ASE_blood(TAU,TE,PARAMS);

% add it all together:
S = PARAMS.S0.*(S_tis + S_csf + S_bld);