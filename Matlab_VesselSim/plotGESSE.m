function [sig_gesse, tau_gesse] = plotGESSE(p,storedPhase)
    % plots a GESSE signal generated using the simple_vessel_sim, based on
    % plotresults.m but modified (MTC) to output only GESSE signals. 

    % time points
	t = (p.deltaTE:p.deltaTE:p.TE*2)';

	%generate a GESSE weighted signal
	TE2ind = find(round(t.*1000)==round(p.TE*500),1,'first');
	mask   = repmat([ones(TE2ind,1); -ones(size(storedPhase,1)-TE2ind,1)],1,p.N);
	GESSEPhase = cumsum(storedPhase.*mask,1);
	tau_gesse  = t-p.TE;
	sig_gesse  = abs(sum(exp(-1i.*GESSEPhase),2)./p.N);
	
    %plot signal curves
    figure(23); hold on;
    plot(tau_gesse.*1000,sig_gesse,'o-');
    xlabel('Time (ms)')
    ylabel('Signal');
    box on;

return;