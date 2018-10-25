function LL = optimScaling(Scale)

    global S_dist param1 tau1
    
    loc_param = param1;
    
    loc_param.R2p = Scale .* loc_param.dw .* loc_param.zeta;
    loc_param.contr = 'R2p';
    
    S_model = qASE_model(tau1,param1.TE,loc_param);
    S_model = S_model./max(S_model);
    
    LL = log(sum((S_dist-S_model).^2));
    
end
