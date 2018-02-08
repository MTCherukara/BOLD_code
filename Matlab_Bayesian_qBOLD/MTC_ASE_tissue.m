function ST = MTC_ASE_tissue(TAU,TE,PARAMS)
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
R2tp = zeta.*dw;

% check whether one TE, or a vector, is supplied
if length(TE) ~= length(TAU)
    TE(2:length(TAU)) = TE(1);
end


%% New Version
%   
% t0 = abs(TAU.*dw);              % predefine tau
% fint = zeros(1,length(TAU));    % pre-allocate
% 
% for ii = 1:length(TAU)
%     
%     % integrate
%     fnc0 = @(u) (2+u).*sqrt(1-u).*(1-besselj(0,3.*t0(ii).*u))./(u.^2);
%     fint(ii) = integral(fnc0,0,1);
%     
% end
% 
% ST = exp(-zeta.*fint./3) .* exp(-TE.*R2t);

%% Third Version (constants)
% % 
% % % define the regime changes in the case where tau is negative
% % c1 = find(abs(TAU)<(1.5./dw),1);
% % c2 = find(TAU>(1.5./dw),1);
% % 
% % % pre-allocate
% % ST = zeros(1,length(TAU));
% % 
% % % long negative tau regime
% % ST(1:c1-1) = exp(zeta+(zeta*dw*TAU(1:c1-1)));
% % 
% % % non-linear short tau regime
% % ST(c1:c2)  = exp(-(0.3*zeta*(dw.*TAU(c1:c2)).^2));
% % 
% % % long positive tau regime
% % ST(c2:end) = exp(zeta-(zeta*dw*TAU(c2:end)));
% % 
% % % add T2 effect
% % ST = ST.*exp(-R2t.*TE);

%% Fourth Version (tau-by-tau)

% define the regime boundary
% tc = 1/dw; 

% pre-allocate
ST = zeros(1,length(TAU)); 

% loop through tau values
for ii = 1:length(TAU)
    
    if abs(TAU(ii)) < 0.015
        % short tau regime
        ST(ii) = exp(-(gm*zeta*(dw.*TAU(ii)).^2));
    else
        % long tau regime
        ST(ii) = exp(zeta-(zeta*dw*abs(TAU(ii))));
    end
end

% add T2 effect
ST = ST.*exp(-R2t.*TE);