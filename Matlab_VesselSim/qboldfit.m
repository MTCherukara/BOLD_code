function [vmeas r2pmeas e0meas ssq]=qboldfit(p,storedPhase,varargin)

	q=inputParser;
	addParameter(q,'TE',p.TE,@isnumeric); %target echo time
	addParameter(q,'Y',p.Y(end),@isnumeric); %target blood oxygen saturation
	addParameter(q,'permeable',false,@islogical); %are vessels permeable
	addParameter(q,'includeIV',false,@islogical); %include intravascular signal for ASE
	addParameter(q,'display',false,@islogical); %display plot of results
	addParameter(q,'T2EV',80e-3,@isnumeric); %extravascular T2
	parse(q,varargin{:});
	r=q.Results;

	t=(p.deltaTE:p.deltaTE:p.TE*2)';
	deltaChi0=0.264e-6;
	Hct=0.4;
	
	[sig_ase tau_ase]=plotresults(p,storedPhase,'TE',r.TE,'Y',r.Y,'permeable',r.permeable,'includeIV',r.includeIV,'display',r.display,'T2EV',r.T2EV);
	
	if isnan(sig_ase)
		r2pmeas=NaN;
		vmeas=NaN;
		e0meas=NaN;
	else	
		tau_ind=find(tau_ase>15e-3);
		X=[ones(size(tau_ind)) -tau_ase(tau_ind)];
		a=X\log(sig_ase(tau_ind));
	
		ssq=sum((log(sig_ase(tau_ind))-X*a).^2)./length(tau_ind);
	
		r2pmeas=a(2);
		vmeas=a(1)-log(sig_ase(find(tau_ase==0)));
		e0meas=(r2pmeas./vmeas)./(4/3*pi*p.gamma.*p.B0.*deltaChi0.*Hct);
	end
	
	%keyboard;