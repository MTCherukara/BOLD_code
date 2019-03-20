function S = qASE_model_FLAIR(TAU,TE,PARAMS)
    % A wrapper that will call qASE_model twice, once with FLAIR and once
    % without, in order to calculate the "combined" version which should
    % hopefully enable estimation of Frequency Shift DF and VCSF simultaneously
    % (perhaps).
    %
    % For now, we make the assumption that the TAU values (and all other
    % parameters) are identical for both sets.
    % 
    % MT Cherukara
    % 20 March 2019
    
    % Make local params
    locparams = PARAMS;
    
%     % First, split TAU into two sets
%     lt = length(TAU)/2;
%     Tau1 = TAU(1:lt);
%     Tau2 = TAU(lt+1:end);
    
    % Define the FLAIR version
    locparams.TI = 1.21;
    
    % Run the FLAIR version
    S1 = qASE_model(TAU,TE,locparams);
    
    % normalize this half;
    S1 = S1./max(S1);
    
    % Define the non-FLAIR version
    locparams.TI = 0;
    
    % Run the non-FLAIR version
    S2 = qASE_model(TAU,TE,locparams);
    
    % Normalize
    S2 = S2./max(S2);
    
    % Concatenate
    S = [S1, S2];