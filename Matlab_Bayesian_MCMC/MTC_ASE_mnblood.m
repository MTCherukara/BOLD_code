function SB = MTC_ASE_mnblood(TAU,TE,PARAMS)
% MTC_ASE_mnblood usage:
%
%        SB = MTC_ASE_mnblood(TAU,TE,PARAMS)
% 
% For use in MTC_qBOLD.m and related scripts.
%
% Based on MTC_ASE_blood, but using the motional narrowing model from
% Berman et al., 2017.
%
% 
%       Copyright (C) University of Oxford, 2018
%
% 
% Created by MT Cherukara, 8 January 2018
%
% CHANGELOG:


% pull out constants
gam = PARAMS.gam;
Hct = PARAMS.Hct;
OEF = PARAMS.OEF;
B0  = PARAMS.B0;

% assign constants
td = 0.0045067;     % diffusion time

% calculate parameters
dChi = ((-0.736 + (0.264*OEF) )*Hct) + (0.722 * (1-Hct));
G0   = (4/45)*Hct*(1-Hct)*((dChi*B0)^2);
kk   = 0.5*(gam^2)*G0*(td^2);


% check whether one TE, or a vector, is supplied
if length(TE) ~= length(TAU)
    TE(2:length(TAU)) = TE(1);
end

% calculate model
SB = exp(-kk.*( (TE./td) + sqrt(0.25 + (TE./td)) + 1.5 - ...
                (2.*sqrt( 0.25 + ( ((TE + TAU).^2) ./ td ) ) ) - ...
                (2.*sqrt( 0.25 + ( ((TE - TAU).^2) ./ td ) ) ) ) );
           
