function ST = MTC_ASE_bessel(TAU,TE,PARAMS)
% MTC_ASE_bessel usage:
%
%        ST = MTC_ASE_bessel(TAU,TE,PARAMS)
% 
% The same as MTC_ASE_tissue, but with the full analytical model (bessel
% function integration) instead of the asymptotic versions.
%
% MT Cherukara
% 19 December 2017

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
