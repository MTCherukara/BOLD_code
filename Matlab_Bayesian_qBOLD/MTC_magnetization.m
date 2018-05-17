function M = MTC_magnetization(tau,TE,TR,T1,T2,TI)
    % Calculates steady-state magnetization in an ASE sequence. Usage:
    %
    %       M = MTC_magnetization(tau,TE,TR,T1,T2,TI)
    %
    % Input:  TAU - Spin echo displacement (seconds), Vector
    %         TE  - Echo time (seconds), Vector
    %         TR  - Reptition time (seconds), Scalar
    %         T1  - Longitudinal relaxation rate (seconds), Scalar
    %         T2  - Transverse relaxation rate (seconds), Scalar
    %         TI  - FLAIR Inversion time (seconds), OPTIONAL Scalar
    %     
    % Based on Equation 16 from He & Yablonskiy, 2007, but adapted to a
    % FLAIR-ASE pulse sequence (as opposed to GESSE).
    %
    % 
    %       Copyright (C) University of Oxford, 2018
    %
    % 
    % Created by MT Cherukara, 16 May 2018
    %
    % CHANGELOG:
    
% Check TE vector length
if length(TE) ~= length(tau)
    TE = repmat(TE(1),1,length(tau));
end

% supply a FLAIR inversion time, if one is not given
if ~exist('TI','var')
    TI = 1.210;
end

% compute exponents
expT2 = (TE - tau)./T2;

% compute terms
terme = 1 + (2.*exp(expT2));
termf = (2 - exp(-(TR - TI)./T1)).*exp(-TI./T1);
termt = exp(-expT2);

% put it all together
M = ( 1 - (terme.*termf) ) .* termt;