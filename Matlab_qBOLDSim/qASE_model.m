function [S,PARAMS] = qASE_model(TAU,TE,PARAMS)
    % Calculates ASE signal from a single voxel. Usage:
    %
    %       [S,PARAMS] = qASE_model(TAU,TE,PARAMS)
    %
    % Input:  TAU    - A vector of tau values (refocussing pulse offsets)
    %                  in seconds.
    %         TE     - A single value, or a vector of equal length to TAU,
    %                  of echo time values in seconds.
    %         PARAMS - The structure containing all the parameters used in
    %                  the simulation and model inference. This can be
    %                  optionally returned as an output, with extra values
    %                  (such as dw) which are calculated within, returned
    %                  as the output.
    %
    % Output: S      - A vector of signal values of same size as T.
    %         PARAMS - [OPTIONAL] The modified parameter structure.
    %
    % For use in qASE.m, MTC_GridSearch_Bayes.m, etc. ses the method described
    % by Yablonskiy & Haacke (1994), and He & Yablonskiy (2007), with additional
    % components as described by Berman & Pike (2017) and Simon et al. (2016)
    %
    % 
    %       Copyright (C) University of Oxford, 2016-2018
    %
    % 
    % Created by MT Cherukara, 16 May 2016
    %
    % CHANGELOG:
    %
    % 2018-09-13 (MTC). Condensing the various compartment functions into the
    %       one script, and bringing nomenclature into line with fmriphysiology
    %       github.
    %
    % 2018-05-16 (MTC). Added the T1-based compartment weightings
    %
    % 2018-01-12 (MTC). R2_blood and R2_blood_star were the wrong way
    %       around. Now we have fixed that.
    %
    % 2017-10-10 (MTC). Added the option to supply a vector of TE values
    %       outside the PARAMS struct, and made changes to the called model
    %       functions MTC_ASE_tissue.m, MTC_ASE_extra.m, MTC_ASE_blood.m,
    %       in order to allow for inference on data with any arbitrary set
    %       of TE-TAU pairs.
    %
    % 2017-08-07 (MTC). Added a control in the form of PARAMS.noDW to  
    %       change the way things are done when we're trying to infer on 
    %       R2'. Added PARAMS as an optional output. 
    %       
    % 2017-07-10 (MTC). Commented out the PARAMS.dw recalculation in order
    %       to use this for the R2' and zeta estimation (alongside
    %       MTC_qASE_model_long.m). This should be put back to normal if
    %       using this for any other grid-search (e.g. the classic OEF-DBV)
    %
    % 2016-05-27 (MTC). Updated the way the compartments were summed up.
   
    
% RECALCULATE KEY PARAMETERS:

% characteristic frequency - this will not be calculated if doing R2'-DBV inference
if PARAMS.calcDW
    PARAMS.dw   = (4/3)*pi*PARAMS.gam*PARAMS.dChi*PARAMS.Hct*PARAMS.OEF*PARAMS.B0;    
else
    % if we are inferring on R2', we want to change the order we do things
    % in slightly:
    PARAMS.dw = PARAMS.R2p ./ PARAMS.zeta;
    PARAMS.OEF = PARAMS.dw ./ ( (4/3)*pi*PARAMS.gam*PARAMS.dChi*PARAMS.Hct*PARAMS.B0 );
end

% spin densities
nt = 0.723;
ne = 0.070;
nb = 0.723;    

% relaxation rate constant of blood
PARAMS.R2b  =  4.5 + 16.4*PARAMS.Hct + (165.2*PARAMS.Hct + 55.7)*PARAMS.OEF^2;
PARAMS.R2bp = 10.2 -  1.5*PARAMS.Hct + (136.9*PARAMS.Hct - 13.9)*PARAMS.OEF^2;

% calculate compartment steady-state magnetization
m_tis = calcMagnetization(TAU,TE,PARAMS.TR,PARAMS.T1t,1./PARAMS.R2t,PARAMS.TI);
m_bld = calcMagnetization(TAU,TE,PARAMS.TR,PARAMS.T1b,1./PARAMS.R2b,PARAMS.TI);
m_csf = calcMagnetization(TAU,TE,PARAMS.TR,PARAMS.T1e,1./PARAMS.R2e,PARAMS.TI);

% pull out parameters
Ve = PARAMS.lam0;
Vb = PARAMS.zeta;

% calculate compartment weightings
w_csf = (ne.*m_csf.*Ve) ./ ( (nt.*m_tis) + (ne.*m_csf.*Ve) - (nt.*m_tis.*Ve) );
w_bld = m_bld.*nb.*(1-w_csf).*Vb;
w_tis = 1 - (w_csf + w_bld);

% CALCULATE MODEL:

% tissue compartment
if PARAMS.asymp
    S_tis = w_tis.*calcAsympTissue(TAU,TE,PARAMS);
else
    S_tis = w_tis.*calcTissueCompartment(TAU,TE,PARAMS);
end

S_csf = w_csf.*calcExtraCompartment(TAU,TE,PARAMS);
S_bld = w_bld.*calcBloodCompartment(TAU,TE,PARAMS);

% add it all together:
S = PARAMS.S0.*(S_tis + S_csf + S_bld);

end


%% calcMagnetization function
function M = calcMagnetization(tau,TE,TR,T1,T2,TI)
    % Calculate steady-state magnetization in an ASE sequence

    % compute exponents
    expT2 = (TE - tau)./T2;

    % compute terms
    terme = 1 + (2.*exp(expT2));
    termf = (2 - exp(-(TR - TI)./T1)).*exp(-TI./T1);
    termt = exp(-expT2);

    % put it all together
    M = ( 1 - (terme.*termf) ) .* termt;
    
end


%% calcTissueCompartment function
function ST = calcTissueCompartment(TAU,TE,PARAMS)
    % Calculate tissue compartment ASE qBOLD signal using the static dephasing
    % model (Yablonskiy & Haacke, 1994)

    % pull out constants
    dw   = PARAMS.dw;
    zeta = PARAMS.zeta;
    R2t  = PARAMS.R2t;

    % check whether one TE, or a vector, is supplied
    if length(TE) ~= length(TAU)
        TE(2:length(TAU)) = TE(1);
    end

    t0 = abs(TAU.*dw);              % predefine tau
    fint = zeros(1,length(TAU));    % pre-allocate

    for ii = 1:length(TAU)

        % integrate
        fnc0 = @(u) (2+u).*sqrt(1-u).*(1-besselj(0,1.5*t0(ii).*u))./(u.^2);
        fint(ii) = integral(fnc0,0,1);

    end

    ST = exp(-zeta.*fint./3) .* exp(-TE.*R2t);
end


%% calcBloodCompartment function
function SB = calcBloodCompartment(TAU,TE,PARAMS)
    % Calculate intravascular contribution to ASE qBOLD signal using the
    % motional narrowing model (Berman & Pike, 2017)

    % pull out constants
    gam = PARAMS.gam;
    Hct = PARAMS.Hct;
    OEF = PARAMS.OEF;
    B0  = PARAMS.B0;
    R2b = PARAMS.R2b;

    % assign constants
    td = 0.0045067;     % diffusion time

    % calculate parameters
    dChi = (((-0.736 + (0.264*OEF) )*Hct) + (0.722 * (1-Hct)))*1e-6;
    G0   = (4/45)*Hct*(1-Hct)*((dChi*B0)^2);
    kk   = 0.5*(gam^2)*G0*(td^2);


    % check whether one TE, or a vector, is supplied
    if length(TE) ~= length(TAU)
        TE(2:length(TAU)) = TE(1);
    end

    % calculate model
    S  = exp(-kk.*( (TE./td) + sqrt(0.25 + (TE./td)) + 1.5 - ...
                    (2.*sqrt( 0.25 + ( ((TE + TAU).^2) ./ td ) ) ) - ...
                    (2.*sqrt( 0.25 + ( ((TE - TAU).^2) ./ td ) ) ) ) );

    SB = S.*exp(-R2b.*TE);

end


%% calcExtraCompartment function
function SE = calcExtraCompartment(TAU,TE,PARAMS)
    % Calculate the extracellular (CSF) contribution to ASE qBOLD signal using
    % the model given in Simon et al., 2016
    

    % check whether one TE, or a vector, is supplied
    if length(TE) ~= length(TAU)
        TE(2:length(TAU)) = TE(1);
    end

    % calculate signal
    SE = exp( -PARAMS.R2e.*TE) .* exp(- 2i.*pi.*PARAMS.dF.*abs(TAU));
    SE = real(SE);
    
end


%% calcAsympTissue function
function ST = calcAsympTissue(TAU,TE,PARAMS)
    % Calculate the tissue contribution to ASE qBOLD signal using the asymptotic
    % version of the Yablonskiy (1994) static dephasing model
    
    % pull out constants
    dw   = PARAMS.dw;
    zeta = PARAMS.zeta;
    R2t  = PARAMS.R2t;
    
    % define the regime boundary
    if PARAMS.tc_man
        tc = PARAMS.tc_val;
    else
        tc = 1.7/dw;
    end

    % tc = tc/dw;

    % pre-allocate
    ST = zeros(1,length(TAU)); 

    % loop through tau values
    for ii = 1:length(TAU)

        if abs(TAU(ii)) < tc
            % short tau regime
            ST(ii) = exp(-(0.3*zeta*(dw.*TAU(ii)).^2));
        else
            % long tau regime
            ST(ii) = exp(zeta-(zeta*dw*abs(TAU(ii))));
        end
    end

    % add T2 effect
    ST = ST.*exp(-R2t.*TE);
end


%% calcTissueDickson function
function ST = calcTissueDickson(TAU,TE,PARAMS)
    % calculate the phenomenological qBOLD model presented in Dickson et al.,
    % 2011
    
    % values of the coefficients (given by Dickson, for GESSE):
    B11 =  70.4280;
    B12 =  57.7890;
    B13 =   1.4565;
    B21 =   0.0324;
    B22 =  -0.1708;
    B23 =   2.1357;
    B31 =   0.2587;
    B32 =   0.1752;
    B33 =   6.1483;
    B41 =  58.1100;
    B42 =  62.8920;
    B43 =   1.5827;
    
    % model parameters of importance
    zeta = PARAMS.zeta;
    OEF  = PARAMS.OEF;
    
    % Calculate second order coefficients
    A1 = OEF*(B11 - (B12 * exp(-B13*OEF)));
    A2 = OEF*(B21 - (B22 * exp(-B23*OEF)));
    A3 = OEF*(B31 - (B32 * exp(-B33*OEF)));
    A4 = OEF*(B41 - (B42 * exp(-B43*OEF)));
    
    % Calculate F
    F = ( A1.*(exp(-A2.*abs(tau)) - 1) ) + (A3.*abs(tau)) + A4;
    
    % Calculate ST
    ST = exp(-zeta.*F);
    
    % add T2 effect
    ST = ST.*exp(-PARAMS.R2t.*TE);
end