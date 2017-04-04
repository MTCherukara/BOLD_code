function Y = MTC_smooth(X,sig,wdt)
    % apply gaussian smoothing kernel to data
    %
    % MT Cherukara, created 4 April 2017
    
    % optional inputs
    if ~exist('wdt','var');
        wdt = 100;
    end
    
    % make sure X is the right way around
    if size(X,2) == 1
        X = X';
    end
    
    if size(X,1) ~= 1
        % don't apply any smoothing if the input is not 1D
        Y = X;
    end
    
    % apply smoothing in 1 dimension
    krn = normpdf(-wdt:wdt,0,sig); % Gaussian weightings
    
    % add zeros as buffers on either end of X
    X2 = [zeros(1,wdt), X, zeros(1,wdt)];
    
    lx = length(X);
    Y = zeros(1,lx);
    
    for ii = 1:lx
        Y(ii) = sum(X2(ii:ii+(2*wdt)).*krn);
    end