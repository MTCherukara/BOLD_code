function PARAMS = param_update(VALUES,PARAMS,INFER)
    % this function updates the specific parameters being inferred on and
    % must be modified for each MH parameter set.
    %
    % For use in xMTC_metroBOLD_counter.m and similar
    %
    %
    % 
    %       Copyright (C) University of Oxford, 2016-2017
    %
    % 
    % Created by MT Cherukara, 29 April 2016
    %
    % CHANGELOG:
    %
    % 2017-04-04 (MTC). Various changes, including adding the ability to
    % infer upon noise.
    %
    % 2016-06-15 (MTC). Added more parameters that can be inferred on.
    %
    % 2016-05-18 (MTC). Changed update order to match MTC_ASE_MH.m.
    
 
% variables, for reference:
% 'OEF','\zeta','\lambda','Hct','\Deltaf','R2(t)','S(0)' ,'R_2^e'

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

