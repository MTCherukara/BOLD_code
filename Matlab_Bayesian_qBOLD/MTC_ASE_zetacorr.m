function DBVprime = MTC_ASE_zetacorr(PARAMS)
    % Calculates a correction to effective DBV based on the presence of a CSF
    % volume fraction:
    %
    %       [PARAMS] = MTC_ASE_zetacorr(PARAMS)
    %
    % Based on He & Yablonskiy, 2007.
    %
    % 
    %       Copyright (C) University of Oxford, 2018
    %
    % 
    % Created by MT Cherukara, 15 May 2018
    %
    % CHANGELOG:
    
% pull out parameter values that we care about
lam = PARAMS.lam0;
DBV = PARAMS.zeta;
TE  = PARAMS.TE;
TR  = PARAMS.TR;
R2t = PARAMS.R2t;
R2e = PARAMS.R2e;

% constants
T1t = 1.20;
T1e = 3.87;
T1b = 1.58;
nt = 0.723;
ne = 1.00;
nb = 0.723;

% calculate
R2b  =  4.5 + 16.4*PARAMS.Hct + (165.2*PARAMS.Hct + 55.7)*PARAMS.OEF^2;

mt = exp(-TE.*R2t) .* (1 - (2.*exp(-(TR-(TE./2))./T1t)) + exp(-TR./T1t));
me = exp(-TE.*R2e) .* (1 - (2.*exp(-(TR-(TE./2))./T1e)) + exp(-TR./T1e));
mb = exp(-TE.*R2b) .* (1 - (2.*exp(-(TR-(TE./2))./T1b)) + exp(-TR./T1b));

lamP = mb*nb*(1-lam)*DBV;
lam0 = (mt*nt*lam) / ( (me*ne*(1-lam)) + (mt*nt*lamP) );

DBVprime = DBV.*(1-lam0);
