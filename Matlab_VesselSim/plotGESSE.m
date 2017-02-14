function [sig_gesse, tau_gesse] = plotGESSE(p,storedPhase,varargin)
    % plots a GESSE signal generated using the simple_vessel_sim, based on
    % plotresults.m but modified (MTC) to output only GESSE signals. 
    
    q = inputParser;
    addParameter(q,'TE',p.TE,@isnumeric);           % echo time
    addParameter(q,'permeable',false,@islogical);	% are vessels permable
    addParameter(q,'display',true,@islogical);      % plot results
    addParameter(q,'T2EV',Inf,@isnumeric);          % tissue T2
    parse(q,varargin{:});
    r = q.Results;
    
    % time points
	t = (p.deltaTE:p.deltaTE:p.TE*2)';

	% generate a GESSE weighted signal
    
    % identify the time of the 180 pulse
	TE2ind = find(round(t.*1000)==round(r.TE*500),1,'first');
	mask   = repmat([ones(TE2ind,1); -ones(size(storedPhase,1)-TE2ind,1)],1,p.N);
	GESSEPhase = cumsum(storedPhase.*mask,1);
	tau_gesse  = t-p.TE;
	sig_gesse  = abs(sum(exp(-1i.*GESSEPhase),2)./p.N);
    
    % T2 effect
    sig_gesse  = sig_gesse.*exp(-r.TE./r.T2EV);
	
    %plot signal curves
    if r.display
        figure(23); hold on;
        plot(tau_gesse.*1000,sig_gesse,'o-');
        xlabel('Time (ms)')
        ylabel('Signal');
        box on;
    end

return;