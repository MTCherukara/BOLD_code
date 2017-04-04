function [ST,FC] = MTC_SE_tissue(T,PARAMS)
% MTC_SE_tissue usage:
%
%        ST = MTC_SE_tissue(T,PARAMS)
% 
% For use in MTC_qBOLD.m
%
% Based on MTC_BOLD_tissue, but taking into account a spin-echo sequence.
%
% Calculate the MRI signal contribution from brain tissue. Takes a vector 
% of timepoints T, and a struct PARAMS containing the necessary values.
% Returns a vector SB of the same length as T, and also optionally returns
% a vector FC, containing only the integrated bessel function part (not
% exponential).
%
% 
%       Copyright (C) University of Oxford, 2016-2017
%
% 
% Created by MT Cherukara, 29 April 2016


ST = zeros(1,length(T)); % preallocate output array
FC = zeros(1,length(T));

% pull out constants
tc = 1./PARAMS.dw;
zeta = PARAMS.zeta;
R2 = PARAMS.R2t;
SE = PARAMS.TE;

for i = 1:length(T)
    t = T(i);
    
    % first regime T < SE/2
    if t < (SE/2)
        ttc = t./tc;
        
    % third regime T > SE
    elseif t > SE
        ttc = (t-SE)./tc;
        
    % second regime (between SE/2 and SE)
    else
        ttc = (SE-t)./tc;
        
    end
    
    fun_fc = @(x) ((2+x).*sqrt(1-x)./(x.^2)).*(1-besselj(0,(1.5.*x.*(ttc))));
    fc = integral(fun_fc,0,1);
    
    FC(i) = fc;
    ST(i) = exp((-R2.*t)-(zeta.*fc));
end
