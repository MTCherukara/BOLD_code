function PARAMS = param_update(VALUES,PARAMS,INFER)
    % This function is used in Bayesian inference of simulated qBOLD (ASE)
    % data to update the values in the PARAMS structure at each iteration
    % of either a grid search or Metropolis Hastings algorithm.
    %
    % Usage:
    %
    %       PARAMS = param_update(VALUES,PARAMS,INFER)
    %
    % Input: VALUES - One or more numbers which are the values of specified
    %                 parameters that should be updated)
    %        PARAMS - The structure containing all the parameters used in
    %                 simulation and model inference, this is updated and
    %                 returned as the Output.
    %        INFER  - EITHER a string corresponding to the name of a
    %                   specific parameter that is to be updated, in which
    %                   case, VALUES must be a single number.
    %                 OR a logical vector of the same length as VALUES
    %                   indicating which parameters should be updated
    %
    % For use in MTC_Asymmetric_Bayes, xMTC_metroBOLD_counter.m and similar
    %
    % 
    %       Copyright (C) University of Oxford, 2016-2017
    %
    % 
    % Created by MT Cherukara, 29 April 2016
    %
    % CHANGELOG:
    %
    % 2018-01-23 (MTC). Added update for R2t.
    %
    % 2017-09-04 (MTC). Added CSF compartment variables lambda, R2e and dF
    %       so that inference on data that includes CSF can also be tried.
    %
    % 2017-08-07 (MTC). Added compatibility with the grid-search inference
    %       (MTC_Asymmetric_Bayes) as well as Metropolis Hastings. In this
    %       case, the INFER input should be a string corresponding to the
    %       PARAMS.name of a single parameter that is to be updated
    %
    % 2017-04-04 (MTC). Various changes, including adding the ability to
    %       infer upon noise.
    %
    % 2016-06-15 (MTC). Added more parameters that can be inferred on.
    %
    % 2016-05-18 (MTC). Changed update order to match MTC_ASE_MH.m.
    
 
% variables, for reference:
% 'OEF','\zeta','\lambda','Hct','\Deltaf','R2(t)','S(0)' ,'R_2^e'

if (length(VALUES) == 1)
    % updating a single parameter (for use in the Grid Search script)
    if strcmp(INFER,'OEF')
        PARAMS.OEF = VALUES;
    elseif strcmp(INFER,'zeta')
        PARAMS.zeta = VALUES;
    elseif strcmp(INFER,'R2p')
        PARAMS.R2p = VALUES;
    elseif strcmp(INFER,'lam0')
        PARAMS.lam0 = VALUES;
    elseif strcmp(INFER,'R2e')
        PARAMS.R2e = VALUES;
    elseif strcmp(INFER,'dF')
        PARAMS.dF = VALUES;
    elseif strcmp(INFER,'R2t')
        PARAMS.R2t = VALUES;
    else
        disp('----param_update.m: Invalid parameter specified');
    end
    
else
    % multiple values specified, updating multiple inferred-on parameters
    % at the same time (for use in the Metropolis Hastings script)

    i = 1;

    if INFER(1) == 1
        PARAMS.OEF  = VALUES(i);
        i = i+1;
    end
    if INFER(2) == 1 
        PARAMS.zeta = VALUES(i);
        i = i+1;
    end
    if INFER(3) == 1
        PARAMS.lam0 = VALUES(i);
        i = i+1;
    end
    if INFER(4) == 1
        PARAMS.Hct  = VALUES(i);
        i = i+1;
    end
    if INFER(5) == 1
        PARAMS.dF   = VALUES(i);
        i = i+1;
    end
    if INFER(6) == 1
        PARAMS.R2t  = VALUES(i);
        i = i+1;
    end
    if INFER(7) == 1
        PARAMS.S0   = VALUES(i);
        i = i+1;
    end
    if INFER(8) == 1
        PARAMS.R2e  = VALUES(i);
        i = i+1;
    end
    if INFER(9) == 1
        PARAMS.sig  = VALUES(i);
        i = i+1;
    end
end

