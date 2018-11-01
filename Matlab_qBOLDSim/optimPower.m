function LL = optimPower(beta)

    global S_dist param1 tau1
    
    loc_param = param1;
    
    loc_param.beta = beta;
    
    S_model = qASE_model(tau1,param1.TE,loc_param);
    S_model = S_model./max(S_model);
    
    S_mlong = S_model(12:end);
    S_dlong = S_dist(12:end);
    
    LL = log(sum((S_dlong-S_mlong).^2));
    
end
