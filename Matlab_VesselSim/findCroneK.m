function k = findCroneK(OEF,MTT,CTH)
    % Calculate optimal value for k (for use in Crone-Rankin model), based
    % on Jespersen and Ostergaard, 2012 (JCBFM). Takes optional inputs of
    % OEF (default=0.4), MTT (default=1.4) and CTH (capillary transit-time
    % heterogeneity - default=1.33). Returns K
    %
    % MT Cherukara
    % 6 January 2017
    
    % check inputs and fill in default values of those that are missing
    if ~exist('OEF','var'); OEF = 0.4;  end    
    if ~exist('MTT','var'); MTT = 1.4;  end
    if ~exist('CTH','var'); CTH = 1.33; end
    
    % calculate derived constants
    a = (MTT/CTH).^2;
    b = MTT/a;
    h = 1/(b.^a)*gamma(a); % constant in the equation for h(t)
    
    % for now
    O = zeros(100,1);
    kk = linspace(0,10);
    
    for ii = 1:100
        k = kk(ii);
        Qh = @(t) (1-exp(-k.*t)).*h.*(t.^(a-1)).*exp(-t./b);
        O(ii) = integral(Qh,0,Inf);
    end
    
    Qh = @(t) (1-exp(-k.*t)).*h.*(t.^(a-1)).*exp(-t./b);
    df = @(k) abs(OEF-integral(Qh,0,Inf));
    
    k0 = fminsearch(df,1);
    