function LL = optimContent(Kappa)
    % Optimization objective function for a scaling factor Kappa in the long-tau
    % calcuation of R2' only; for use within FMINBND (or similar) only.

    global S_dist param1 tau1
    
    loc_param = param1;
    
    % compute the true value of R2'
    tR2p = (4/3)*pi*loc_param.gam*loc_param.B0*loc_param.dChi*loc_param.Hct*loc_param.OEF*loc_param.zeta;
    
    % apply some scaling to it
    sR2p = Kappa .* tR2p;
    
    % generate a (log) signal 
    S_model = loc_param.zeta-sR2p.*tau1;
    
    % normalize the signals in some way?
   
       
    % calculate likelihood
    LL = log(sum((log(S_dist)-S_model).^2));
    
end
