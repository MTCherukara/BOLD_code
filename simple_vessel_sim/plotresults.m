function [sig_ase tau_ase]=plotresults(p,storedPhase,varargin) 

	q=inputParser;
	addParameter(q,'TE',p.TE,@isnumeric); %target echo time
	addParameter(q,'Y',p.Y(end),@isnumeric); %target blood oxygen saturation
	addParameter(q,'permeable',false,@islogical); %are vessels permeable
	addParameter(q,'includeIV',false,@islogical); %include intravascular signal for ASE
	addParameter(q,'display',true,@islogical); %display plot of results
	addParameter(q,'T2EV',Inf,@isnumeric); %extravascular T2, defaults to infinite i.e. no effect 
	parse(q,varargin{:});
	r=q.Results;

	t=(p.deltaTE:p.deltaTE:p.TE*2)';
	
	%error checking
	if or(mod(round(r.TE*1000),(round(p.deltaTE*2000)))>0,p.TE<=0)
		disp(['TE must be in the range ' num2str(p.deltaTE*2000) 'ms to ' num2str(t(end)*1000) 'ms in steps of ' num2str(p.deltaTE*2000) 'ms!']);
		ase=[];
		return;
	end
	
	%scale for different Y values
	Yscale=(1-r.Y)./(1-p.Y(end));
	
	%generate an ASE weighted signal
	TEind=find(round(t.*1000)==round(r.TE*1000),1,'first');
	
	for k=1:TEind+1
		ASEPhase(k,:)=sum(storedPhase(1:k-1,:),1)-sum(storedPhase(k:TEind,:),1);
	end
	tau_ase=(r.TE:-p.deltaTE*2:-r.TE)';
	
	switch(r.permeable)
		case true
			protonIndex=(1:5000);
		case false
			protonIndex=find(p.numStepsInVessel==0,5000,'first');
		otherwise
			protonIndex=find(p.numStepsInVessel==0,5000,'first');
	end
	
	if length(protonIndex)<5000
		sig_aseEV=NaN;
	else
		sig_aseEV=abs(sum(exp(-i.*ASEPhase(:,protonIndex).*Yscale),2)./length(protonIndex));
	end
	
	sig_aseIV=intravascularsim(p,r.TE,r.Y);
	
	switch(r.includeIV)
		case true
			sig_ase=(1-p.vesselFraction).*sig_aseEV.*exp(-r.TE./r.T2EV)+p.vesselFraction.*sig_aseIV;
		case false
			sig_ase=sig_aseEV.*exp(-r.TE./r.T2EV);
		otherwise
			sig_ase=sig_aseEV.*exp(-r.TE./r.T2EV);
	end
	
	%generate a GESSE weighted signal
	TE2ind=find(round(t.*1000)==round(r.TE*500),1,'first');
	mask=repmat([ones(TE2ind,1); -ones(size(storedPhase,1)-TE2ind,1)],1,p.N);
	GESSEPhase=cumsum(storedPhase.*mask,1);
	tau_gesse=t-r.TE;
	sig_gesse=abs(sum(exp(-i.*GESSEPhase.*Yscale),2)./p.N);
	
	%plot signal curves
	if r.display
		figure(100);
		hold on;
		plot(tau_gesse.*1000,sig_gesse,'o-');
		box on;
	
		figure(101);
		hold on;
		plot(tau_ase.*1000,sig_ase,'o-');
		box on;
	end

return;