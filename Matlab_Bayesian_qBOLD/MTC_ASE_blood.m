function SB = MTC_ASE_blood(TAU,TE,PARAMS)
% MTC_ASE_blood usage:
%
%        SB = MTC_ASE_blood(TAU,TE,PARAMS)
% 
% For use in MTC_qBOLD.m and related scripts.
%
% Based on MTC_BOLD_tissue, but taking into account an asymmetric spin-echo
% sequence as described in An & Lin, 2003. 
%
% Calculate the MRI signal contribution from brain tissue (which is assumed
% to be mostly grey matter, with some fraction of CSF). Takes a vector of
% offset values TAU (which is the amount of offset of the refocusing RF
% pulse from TE/2, in seconds), and a struct PARAMS containing the
% necessary constants. Returns a vector SB, of the same length as TAU,
% containing the measured MRI signal strength for each TAU.
%
% 
%       Copyright (C) University of Oxford, 2016-2017
%
% 
% Created by MT Cherukara, 17 May 2016
%
% CHANGELOG:
%
% 2017-10-10 (MTC). Added TE input (see MTC_qASE_model.m)
%
% 2017-04-04 (MTC). Various changes.

% pull out constants
R2b  = PARAMS.R2b;
R2bp = PARAMS.R2bp;

% check whether one TE, or a vector, is supplied
if length(TE) ~= length(TAU)
    TE(2:length(TAU)) = TE(1);
end

% calculate model
TAU = abs(TAU);

SB = exp(-TE.*R2b).*exp(-TAU.*R2bp);
