function LL = optimOffset(Offset)

    global S_dist param1 tau1
    
    loc_param = param1;
    
    loc_param.Voff = Offset;
    
    S_model = qASE_model(tau1,param1.TE,loc_param);
    S_model = S_model./max(S_model);
    
    LL = log(sum((S_dist-S_model).^2));
    
end
