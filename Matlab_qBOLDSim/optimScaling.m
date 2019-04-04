function LL = optimScaling(xx)
    % Optimization objective function for a scaling factor SR, applied to the
    % whole range of tau values. For use within FMINBND (or similar) only
    
    global S_dist param1 tau1
    
    loc_param = param1;
    
    loc_param.sgeo = xx(1);
    
    S_model = qASE_model(tau1,param1.TE,loc_param);
    S_model = S_model./max(S_model);
    
    S_mlong = S_model(1:end);
    S_dlong = S_dist(1:end);
    
    LL = log(sum((S_dlong-S_mlong).^2));
    
end
