function PARAMS = updateParams(VALUE,PARAMS,INFER)
    % This function is used in Bayesian inference of simulated qBOLD (ASE)
    % data to update the values in the PARAMS structure at each iteration
    % of either a grid search or Metropolis Hastings algorithm.
    %
    % Usage:
    %
    %       PARAMS = updateParams(VALUE,PARAMS,INFER)
    %
    % Input: VALUES - The new value
    %        PARAMS - The structure containing all the parameters used in
    %                 simulation and model inference, this is updated and
    %                 returned as the Output.
    %        INFER  - String corresponding to the name of the specific paramter
    %                 which is to be updated.
    %
    % For use in MTC_Asymmetric_Bayes and similar
    %
    % 
    %       Copyright (C) University of Oxford, 2016-2017
    %
    % 
    % Created by MT Cherukara, 29 April 2016
    %
    % CHANGELOG:
    %
    % 2018-09-13 (MTC). Removed the MH multiple-update functionality, now you
    %       have to call this function once per parameter you want to update.
    %       It's better to just have this function do one thing.
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

    if strcmp(INFER,'OEF')
        PARAMS.OEF = VALUE;
    elseif strcmp(INFER,'zeta')
        PARAMS.zeta = VALUE;
    elseif strcmp(INFER,'R2p')
        PARAMS.R2p = VALUE;
    elseif strcmp(INFER,'lam0')
        PARAMS.lam0 = VALUE;
    elseif strcmp(INFER,'R2e')
        PARAMS.R2e = VALUE;
    elseif strcmp(INFER,'dF')
        PARAMS.dF = VALUE;
    elseif strcmp(INFER,'R2t')
        PARAMS.R2t = VALUE;
    elseif strcmp(INFER,'geom')
        PARAMS.geom = VALUE;
    else
        disp('----updateParams.m: Invalid parameter specified');
    end
    

