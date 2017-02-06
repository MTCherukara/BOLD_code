function ST = MTC_ASE_tissue(TAU,PARAMS)
% MTC_ASE_tissue usage:
%
%        ST = MTC_ASE_tissue(TAU,PARAMS)
% 
% For use in MTC_qBOLD.m and related scripts.
%
% Based on MTC_BOLD_tissue, but taking into account an asymmetric spin-echo
% sequence as described in An & Lin, 2003. 
%
% Calculate the MRI signal contribution from brain tissue. Takes a vector
% of offset values TAU (which is the amount of offset of the refocusing RF
% pulse from TE/2, in seconds), and a struct PARAMS containing the
% necessary constants. Returns a vector ST, of the same length as TAU,
% containing the measured MRI signal strength for each TAU.
% 
% MT Cherukara
% 17 May 2016
%
% 19 May 2016 - Added integral function (BesselJ) instead
%
% 21 June 2016 - Added a new version with constant terms sorted out better

% pull out constants
TE   = PARAMS.TE;
dw   = PARAMS.dw;
zeta = PARAMS.zeta;
R2t  = PARAMS.R2t;
R2tp = zeta.*dw;
R2ts = R2t + R2tp;
R2tr = R2t - R2tp; % rephasing rate R2*_

%% Old Version
% % define the regime changes in the case where tau is negative
% c1 = find(abs(TAU)<(0.75./dw),1);
% c2 = find(TAU>(0.75./dw),1);
% 
% % pre-allocate
% ST = zeros(1,length(TAU));
% 
% % define S(TE) as point of comparison
% ST0 = exp(-(TE - 2*TAU).*R2t);
% 
% % long negative tau regime
% ST(1:c1-1) = ST0(1:c1-1) .* exp(zeta - 2.*R2tr.*TAU(1:c1-1));
% 
% % non-linear short tau regime
% ST(c1:c2)  = exp(-(8/9).*zeta.*(dw.*TAU(c1:c2)).^2 - R2t.*TE);
% 
% % long positive tau regime
% ST(c2:end) = ST0(c2:end) .* exp(zeta - 2.*R2ts.*TAU(c2:end));

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

% define the regime changes in the case where tau is negative
c1 = find(abs(TAU)<(0.75./dw),1);
c2 = find(TAU>(0.75./dw),1);

% pre-allocate
ST = zeros(1,length(TAU));

% long negative tau regime
ST(1:c1-1) = exp(zeta+(2*zeta*dw*TAU(1:c1-1)));

% non-linear short tau regime
ST(c1:c2)  = exp(-(8/9*zeta*(dw.*TAU(c1:c2)).^2));

% long positive tau regime
ST(c2:end) = exp(zeta-(2*zeta*dw*TAU(c2:end)));

ST = ST.*exp(-R2t.*TE);