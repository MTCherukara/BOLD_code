function LL = optimScaling(X1)
    % long tau only version - for use in xContent_optimization.m, for other
    % uses, revert back to previous version (from 2018-11-06)

    global S_true param1 tau1
    
    loc_param = param1;
    S_local = S_true;
    
    % calculate content
    DD = ( loc_param.Hct * loc_param.OEF * loc_param.zeta / loc_param.kap )^loc_param.beta;
    
    S_model = exp(-DD.*tau1./X1);
    
    % align data
    diffS = S_model(1) - S_local(1);
    S_local = S_local + diffS;

    % evaluate log likelihood (sum of square differences)
    LL = log(sum((S_local-S_model).^2));
    
end
