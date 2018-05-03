function SE = MTC_ASE_extra(TAU,TE,PARAMS)
% MTC_ASE_extra usage:
%
%        SE = MTC_ASE_extra(TAU,TE,PARAMS)
% 
% For use in MTC_qBOLD.m and related scripts.
%
% Based on MTC_ASE_tissue, but for extracellular (CSF) signal 
%
% Calculate the MRI signal contribution from CSF. Takes a vector of offset
% values TAU, and either a single value or a vector of echo time TE, and a 
% struct PARAMS containing the necessary constants. Returns a vector SE, of
% the same length as TAU, containing the measured MRI signal strength for
% each TAU.
%
% 
%       Copyright (C) University of Oxford, 2016-2017
%
% 
% Created by MT Cherukara, 17 May 2016
%
% CHANGELOG:
%
% 2017-10-10 (MTC). Added TE as an input (see MTC_qASE_model.m)
%
% 2017-09-01 (MTC). Set the signal to be based on tau, not 2*tau, as we
%       erroneously used before
%
% 2017-04-04 (MTC). Various changes.

% pull out constants
R2e = PARAMS.R2e;
df  = PARAMS.dF;

% check whether one TE, or a vector, is supplied
if length(TE) ~= length(TAU)
    TE(2:length(TAU)) = TE(1);
end

% calculate signal
SE = exp( -R2e.*TE) .* exp(- 2i.*pi.*df.*abs(TAU));
SE = real(SE);

