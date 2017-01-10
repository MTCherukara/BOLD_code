function h = CTTH(t,MTT,CTH)
    % Capillary Transit-Time Distribution:
    %
    %       h = CTTH(t,MTT,CTH)
    %
    % Generates a distribution of capillary transit-times, based on transit
    % time t (which should be integrated over from 0 to Inf), using
    % parameters MTT (Mean Transit Time) and CTH (Capillary Transit-Time
    % Heterogeneity = standard deviation). Based on Jespersen and
    % Ostergaard, 2012 (JCBFM).
    %
    % MT Cherukara
    % 10 January 2017
    
    % fill in some default values if these inputs are missing
    if ~exist('MTT','var'); MTT = 1.4;  end
    if ~exist('CTH','var'); CTH = 1.33; end
    
    % calculate Alpha and Beta from MTT and CTH
    a = (MTT/CTH).^2;
    b = MTT/a;
    
    % calculate h
    h = (1./((b.^a).*gamma(a))) .* (t.^(a-1)) .* exp(-(t./b));
    
    