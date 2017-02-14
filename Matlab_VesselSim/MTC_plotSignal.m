function [sig, tau] = MTC_plotSignal(p,storedPhase,varargin)
    % plot results from a particular signal type, based on plotresults.m
    %
    % need to incorporate the option to specify Y, or change permeability
    % of vessels, and include an intravascular signal component, and also
    % add more sequences potentially
    %
    % MT Cherukara
    % Created 13 February 2017
    
    % gather data from inputs
	q = inputParser;
	addParameter(q,'TE',p.TE,@isnumeric);           % target echo time
	addParameter(q,'Y',p.Y(end),@isnumeric);        % target blood oxygen saturation
	addParameter(q,'permeable',false,@islogical);   % are vessels permeable
	addParameter(q,'includeIV',false,@islogical);   % include intravascular signal for ASE
	addParameter(q,'display',true,@islogical);      % display plot of results
	addParameter(q,'T2EV',Inf,@isnumeric);          % extravascular T2, defaults to infinite i.e. no effect 
    addParameter(q,'sequence','GE',@ischar);       % sequence type, defaults to gradient echo
	parse(q,varargin{:});
	r = q.Results;
    
    % define time range
    t = (p.deltaTE:p.deltaTE:p.TE*2)';
    
	%scale for different Y values
	Yscale = (1-r.Y)./(1-p.Y(end)); % = 1, does nothing
    
    % define total phase based on sequence type - could potentially make
    % these each into independent functions?
    switch(r.sequence)
        case 'GESSE'
            TE2ind = find(round(t.*1000)==round(r.TE*500),1,'first');
            mask   = repmat([ones(TE2ind,1); -ones(size(storedPhase,1)-TE2ind,1)],1,p.N);
            Phase  = cumsum(storedPhase.*mask,1);
            tau    = t-p.TE;
        case 'ASE'
            TEind = find(round(1000*t)==round(1000*r.TE),1,'first');
            for k = 1:TEind+1 % should produce the same number of rows as tau_ase (31) 
            	Phase(k,:) = sum(storedPhase(1:k-1,:),1)-sum(storedPhase(k:TEind,:),1);
            end
            tau = (r.TE:-p.deltaTE*2:-r.TE)'; % [31 points]
        otherwise
            Phase = cumsum(storedPhase,1);
            tau    = t-p.TE; % same as GESSE tau, I think?
    end
    
    % calculate signal
    sigEV = abs(sum(exp(-1i.*Phase.*Yscale),2)./p.N);
    
    % account for T2 decay
    sig = sigEV.*exp(-r.TE./r.T2EV);
    
    % plot results
    if r.display
        figure;
        hold on;
        plot(tau.*1000,sig,'o-');
        xlabel('Time (ms)')
        ylabel('Signal');
        box on;
    end
    
return;

    
    
    
