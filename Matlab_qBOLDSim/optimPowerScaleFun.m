function LL = optimPowerScaleFun(xx)

    global S_dist param1 tau1
    
    loc_param = param1;
    
    % parametric kappa definition
    a = xx(1);
    b = xx(2);
    
    loc_param.SR = a*loc_param.OEF*exp(-b*loc_param.TE);
    
    % beta
    loc_param.beta = xx(3);
    
    
    S_model = qASE_model(tau1,param1.TE,loc_param);
    S_model = S_model./max(S_model);
    
    S_mlong = S_model(1:end);
    S_dlong = S_dist(1:end);
    
    LL = log(sum((S_dlong-S_mlong).^2));
    
end
