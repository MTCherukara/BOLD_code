function SB = MTC_SE_blood(T,PARAMS)
% MTC_SE_blood usage:
%
%        SB = MTC_SE_blood(T,CONST)
% 
% For use in MTC_qBOLD.m
%
% Based on MTC_BOLD_blood, but taking into account a spin-echo sequence,
% and a variable Hct.
%
% Calculate the MRI signal contribution from blood. Takes a vector of
% timepoints T, and a struct, CONST, containing the necessary values.
% Returns a vector SB of the same length as T.
%
% 
%       Copyright (C) University of Oxford, 2016-2017
%
% 
% Created by MT Cherukara, 29 April 2016
%
% CHANGELOG:
%
% 2016-05-13 (MTC). Corrected the way in which R2b and R2b* are calculated
% in order to take into account OEF (1-Y).


% pull out constants
Hct = PARAMS.Hct;
OEF = PARAMS.OEF;
TE  = PARAMS.TE;

% calculate R2, R2*, and lambda, using Lu & Ge, and Simon et al., assuming
% that venous blood is the main contributor (is this valid?)
R2b  = 14.9*Hct + 14.7 + (302.1*Hct + 41.8)*OEF^2;
R2bs = 16.4*Hct + 4.5  + (165.2*Hct + 55.7)*OEF^2;


c1 = find(T>(TE/2),1); % points at which regime changes
c2 = find(T>TE,1);

SB = zeros(1,length(T)); % pre-allocate SE

% first regime, T < TE/2
SB(1:c1-1)  = exp(-R2bs.*T(1:c1-1));

% second regime, TE/2 < T < TE
SB(c1:c2-1) = exp( - (R2b.*(2*T(c1:c2-1)-TE)) - (R2bs.*(TE-T(c1:c2-1))));

% third regime, TE < T
SB(c2:end)  = exp( - (R2b.*TE) - (R2bs.*(T(c2:end)-TE)));
