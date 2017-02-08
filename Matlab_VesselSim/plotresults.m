function [sig_ase, tau_ase] = plotresults(p,storedPhase,varargin) 

	q = inputParser;
	addParameter(q,'TE',p.TE,@isnumeric); %target echo time
	addParameter(q,'Y',p.Y(end),@isnumeric); %target blood oxygen saturation
	addParameter(q,'permeable',false,@islogical); %are vessels permeable
	addParameter(q,'includeIV',false,@islogical); %include intravascular signal for ASE
	addParameter(q,'display',true,@islogical); %display plot of results
	addParameter(q,'T2EV',Inf,@isnumeric); %extravascular T2, defaults to infinite i.e. no effect 
	parse(q,varargin{:});
	r = q.Results;

	t = (p.deltaTE:p.deltaTE:p.TE*2)';
	
	%error checking
	if or(mod(round(r.TE*1000),(round(p.deltaTE*2000)))>0,p.TE<=0)
		disp(['TE must be in the range ' num2str(p.deltaTE*2000) 'ms to ' num2str(t(end)*1000) 'ms in steps of ' num2str(p.deltaTE*2000) 'ms!']);
		ase=[];
		return;
	end
	
	%scale for different Y values
	Yscale = (1-r.Y)./(1-p.Y(end)); % = 1, does nothing
	
	%generate an ASE weighted signal
	TEind = find(round(1000*t)==round(1000*r.TE),1,'first');
	
	for k = 1:TEind+1 % should produce the same number of rows as tau_ase (31)
        %%% ASEPhase = [2,1000], first row -X, second row +X
		ASEPhase(k,:) = sum(storedPhase(1:k-1,:),1)-sum(storedPhase(k:TEind,:),1);
	end
	tau_ase = (r.TE:-p.deltaTE*2:-r.TE)'; % [31 points]
	
	switch(r.permeable) % this will be FALSE
		case true
			protonIndex = 1:1000;
		case false
            %%% protonIndex = [952 points]
			protonIndex = find(p.numStepsInVessel==0,1000,'first');
		otherwise
			protonIndex = find(p.numStepsInVessel==0,1000,'first');
    end
	
    % don't generate an ASE signal at all if the proton didn't spend a
    % suitable amount of time outside the vessel - maybe we just get rid of
    % this statement, and use the whole length regardless (for now)
% 	if length(protonIndex)<500 
% 		sig_aseEV = NaN;
%     else
        sigexp = exp(-1i.*ASEPhase(:,protonIndex).*Yscale);
		sig_aseEV = abs(sum(sigexp,2)./length(protonIndex));
%     end
	
	switch(r.includeIV)
		case true
            sig_aseIV = intravascularsim(p,r.TE,r.Y); % put this in here to save a bit of time
			sig_ase = (1-p.vesselFraction).*sig_aseEV.*exp(-r.TE./r.T2EV)+p.vesselFraction.*sig_aseIV;
		case false
			sig_ase = sig_aseEV.*exp(-r.TE./r.T2EV);
		otherwise
			sig_ase = sig_aseEV.*exp(-r.TE./r.T2EV);
	end
	
	%generate a GESSE weighted signal
% 	TE2ind = find(round(t.*1000)==round(r.TE*500),1,'first');
% 	mask   = repmat([ones(TE2ind,1); -ones(size(storedPhase,1)-TE2ind,1)],1,p.N);
% 	GESSEPhase = cumsum(storedPhase.*mask,1);
% 	tau_gesse  = t-r.TE;
% 	sig_gesse  = abs(sum(exp(-1i.*GESSEPhase.*Yscale),2)./p.N);
	
	%plot signal curves
	if r.display
        % GESSE
% 		figure(22)
% 		hold on;
% 		plot(tau_gesse.*1000,sig_gesse,'o-');
%         xlabel('Time (ms)')
%         ylabel('Signal');
% 		box on;

        % ASE
		figure(33);
		hold on;
		plot(tau_ase.*1000,sig_ase,'o-');
		box on;
	end

return;