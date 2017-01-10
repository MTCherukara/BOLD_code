function O = OEFmax(k,MTT,CTH)
    % Calculate maximum OEF:
    %
    %       O = OEFmax(k,MTT,CTH)
    %
    % Calculates maximum OEF using Jespersen and Ostergaard method (JCBFM,
    % 2012), which is in turn based on Crone-Renkin (Crone, 1963). Takes an
    % input k which must be a single number, and optional inputs of MTT and
    % CTH (see CTTH.m).
    %
    % MT Cherukara
    % 10 January 2017
    
    % fill in some default values if these inputs are missing
    if ~exist('MTT','var'); MTT = 1.4;  end
    if ~exist('CTH','var'); CTH = 1.33; end
    
    f1 = @(t) (1-exp(-k.*t)).*CTTH(t,MTT,CTH);
    O = integral(f1,0,Inf);