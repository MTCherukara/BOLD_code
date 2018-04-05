function ST = MTC_ASE_tissue(TAU,TE,PARAMS,tc)
% MTC_ASE_tissue usage:
%
%        ST = MTC_ASE_tissue(TAU,TE,PARAMS)
% 
% For use in MTC_qBOLD.m and related scripts.
%
% Based on MTC_BOLD_tissue, but taking into account an asymmetric spin-echo
% sequence as described in An & Lin, 2003. 
%
% Calculate the MRI signal contribution from brain tissue. Takes a vector
% of offset values TAU (which is the amount of offset of the refocusing RF
% pulse from TE/2, in seconds), and a value of TE (either as a single
% value, or a vector with the same length as TAU), and a struct PARAMS
% containing the necessary constants. Returns a vector ST, of the same 
% length as TAU, containing the measured MRI signal strength for each TAU
% and TE combination.
%
% 
%       Copyright (C) University of Oxford, 2016-2017
%
% 
% Created by MT Cherukara, 17 May 2016
%
% CHANGELOG:
%
% 2017-10-16 (MTC). Changed to calculating the signal for each tau value
%       individually, rather than all-together, in such a way that assumes
%       that the tau values are strictly increasing. This will probably be
%       slower, but should avoid any problems when only one regime of
%       values is specified.
%
% 2017-10-10 (MTC). Added the option to specify a range of TE values
%       outside the PARAMS structure.
%
% 2017-06-26 (MTC). Corrected the asymptotic solutions, and switched to
%       using tau correctly.
%
% 2017-04-04 (MTC). Reverted back to using the asymptotic solutions of the
%       qBOLD model.
%
% 2016-06-21 (MTC). Added a new version with constant terms sorted out
%       better.
%
% 2016-05-19 (MTC). Added integral function (BesselJ).

% pull out constants
gm   = PARAMS.geom;
dw   = PARAMS.dw;
zeta = PARAMS.zeta;
R2t  = PARAMS.R2t;

% check whether one TE, or a vector, is supplied
if length(TE) ~= length(TAU)
    TE(2:length(TAU)) = TE(1);
end


%% Fourth Version (tau-by-tau)

% define the regime boundary
if PARAMS.tc_man
    tc = PARAMS.tc_val;
else
    tc = 1.7/dw;
end
    
    
% pre-allocate
ST = zeros(1,length(TAU)); 

% loop through tau values
for ii = 1:length(TAU)
    
    if abs(TAU(ii)) < tc
        % short tau regime
        ST(ii) = exp(-(gm*zeta*(dw.*TAU(ii)).^2));
    else
        % long tau regime
        ST(ii) = exp(zeta-(zeta*dw*abs(TAU(ii))));
    end
end

% add T2 effect
ST = ST.*exp(-R2t.*TE);