function [tau,signal] = MTC_analyticASE(tarray,p,r)
    % Produce an analyitcal ASE signal. Usage:
    %
    %       [tau,signal] = MTC_analyticASE(tarray,p,r)
    %
    % Based on the He & Yablonskiy (2007) model, and on MTC_qASE_model.m
    % and its derived scripts.
    
    % define range of tau points
    tau = linspace(tarray(1),tarray(end),1000);
    
    % calculate compartment signals
    S_tis = ASE_tissue(tau,p,r);
    S_bld = ASE_blood(tau,p,r);
    
    % add them up
    if r.incIV
        
        % compartment weightings
        wb = sum(p.vesselFraction); % blood
        wt = 1-wb;                  % tissue
        
        signal = (wt.*S_tis) + (wb.*S_bld);
        
    else
        
        signal = S_tis;
        
    end
    
    % normalise
    if r.normalise
        signal = signal./max(signal);
    end
    
return;


function ST = ASE_tissue(TAU,PARAMS,R)
    % calculates the ASE signal from the tissue compartment
    
    % pull out constants
    Hct  = PARAMS.Hct(1);
    OEF = 1-PARAMS.Y(1);
    dw  = (4/3).*pi.*PARAMS.gamma.*PARAMS.deltaChi0.*PARAMS.B0.*Hct.*OEF;
    zt  = sum(PARAMS.vesselFraction);
    
    % define the regime changes in the case where tau is negative
    c1 = find(abs(TAU)<(1.5./dw),1);
    c2 = find(TAU>(1.5./dw),1);
    
    % pre-allocate
    ST = zeros(1,length(TAU));
    
    % long negative tau regime
    ST(1:c1-1) = exp(zt+(zt.*dw.*TAU(1:c1-1)));
    
    % non-linear short tau regime
    ST(c1:c2)  = exp(-(0.3.*zt.*(dw.*TAU(c1:c2)).^2));
    
    % long positive tau regime
    ST(c2:end) = exp(zt-(zt.*dw.*TAU(c2:end)));
    
    % T2 effect
    if R.incT2
        ST = ST.*exp(-PARAMS.TE./PARAMS.T2EV);
    end
    
return;

function SB = ASE_blood(TAU,PARAMS,R)
    % calculates the ASE signal from the intravascular compartment
    
    % pull out constants
    Hct  = PARAMS.Hct(1);
    OEF  = 1-PARAMS.Y(1);
    R2b  = 14.9.*Hct + 14.7 + (302.1.*Hct + 41.8).*OEF.^2;
    R2bs = 16.4.*Hct + 4.5  + (165.2.*Hct + 55.7).*OEF.^2;
    
    % calculate
    SB = exp(-PARAMS.TE.*R2b).*exp(-abs(TAU).*(R2bs-R2b));
    
return;