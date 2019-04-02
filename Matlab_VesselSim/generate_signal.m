function [sigEV, sigIV]=generate_signal(p,storedPhase,varargin)

	q=inputParser;
	addParameter(q,'TE',p.TE,@isnumeric); %target echo time
	addParameter(q,'Y',p.Y(end),@isnumeric); %target blood oxygen saturation
	addParameter(q,'Hct',p.Hct,@isnumeric); %target haematocrit
	addParameter(q,'permeable',false,@islogical); %are vessels permeable
	addParameter(q,'includeIV',false,@islogical); %include intravascular signal
	addParameter(q,'display',false,@islogical); %display plot of results
	addParameter(q,'T2EV',87e-3,@isnumeric); %extravascular T2
	addParameter(q,'T2b0',189e-3,@isnumeric); %intravascular T2
	addParameter(q,'Vf',p.vesselFraction(1),@isnumeric);
	addParameter(q,'seq','ASE'); %blood oxygenation saturation saturation to match tissue susceptibility
	addParameter(q,'tau',[]);
	parse(q,varargin{:});
	r=q.Results;

	t=(p.deltaTE:p.deltaTE:p.TE*2)';

	%error checking
	if or(mod(round(r.TE*1000),(round(p.deltaTE*2000)))>0,p.TE<=0)
		disp(['TE must be in the range ' num2str(p.deltaTE*2000) 'ms to ' num2str(t(end)*1000) 'ms in steps of ' num2str(p.deltaTE*2000) 'ms!']);
		return;
	end
	
% 	%scale for different Y values
% 	if length(p.R)>1
% 		Yscale=1;
% 	else
% 		Yscale=(1-r.Y)./(1-p.Y(end));
% 	end

    if strcmp(r.seq,'ASE')
		%generate an ASE weighted signal
		if isempty(r.tau) %error checking required here
			tau=(r.TE:-p.deltaTE*2:-r.TE)';
		else
			tau=r.tau;
			tau=tau(:);
		end
		
		TE=repmat(r.TE,size(tau));
		TEind=r.TE/p.deltaTE;
		SEind=round((r.TE-tau)./(2.*p.deltaTE),0);
        
        % Pre-allocate
        Phase = zeros(length(tau),size(storedPhase,2));
        
        % Pre-sum
        cumPhase = cumsum(storedPhase,1);
	
		for k=1:length(tau)
                
            % FIRST ATTEMPT 
%             Phase(k,:) = cumPhase(SEind(k),:) - ( cumPhase(TEind,:)  - cumPhase(SEind(k)+1,:) );

            % SECOND ATTEMPT - appears to be working?
            Phase(k,:) = cumPhase(SEind(k),:) - ( cumPhase(TEind,:)  - cumPhase(SEind(k),:) );

            % OLD VERSION - SLOW
% 			Phase(k,:)=sum(storedPhase(1:SEind(k),:),1)-sum(storedPhase(SEind(k)+1:TEind,:),1);
		end	

	elseif strcmp(r.seq,'GESSE')
		%generate a GESSE weighted signal
		if isempty(r.tau)
			tau=(-r.TE/2:p.deltaTE:(p.TE*2-r.TE))';
		else
			tau=r.tau;
		end
		
		TE=r.TE+tau;
		TEind=round((r.TE+tau)./p.deltaTE,0);
		SEind=r.TE/(2*p.deltaTE);
	
		for k=1:length(tau)
			Phase(k,:)=sum(storedPhase(1:SEind,:),1)-sum(storedPhase(SEind+1:TEind(k),:),1);
		end		
	else
		disp('Sequence unknown');
		return;
    end
      
% 	numStepsInVessel=p.numStepsInVessel;
	
	switch(r.permeable)
		case true
			protonIndex=(1:5000);
		case false
            protonIndex=(1:5000);
% 			protonIndex=find(numStepsInVessel==0,5000,'first');
        otherwise
            protonIndex=(1:5000);
% 			protonIndex=find(numStepsInVessel==0,5000,'first');
	end

	if length(protonIndex)<5000
		sigEV=NaN(length(tau),1);
	else
		sigEV=calc_sig(Phase(:,protonIndex),p,r).*exp(-TE./r.T2EV);
	end

	if r.includeIV
		sigIV=calc_sigIV(p,r,TE,tau);
		sigTOT=(1-r.Vf).*sigEV+r.Vf.*sigIV;
	else
		sigTOT=sigEV;
		sigIV=calc_sigIV(p,r,TE,tau);
    end
end


function sigEV=calc_sig(Phase,p,r)

		if length(p.R)==1
			Suscscale=(p.deltaChi0.*r.Hct.*(1-r.Y).*p.B0)./(p.deltaChi0.*p.Hct.*(1-p.Y).*p.B0);
		else
			Suscscale=1;
		end
		
		sigEV=abs(sum(exp(-1i.*Phase.*Suscscale),2)./length(Phase));

		if length(p.R)==1
			shapeEV=-log(sigEV)./p.vesselFraction;
			sigEV=exp(-r.Vf.*shapeEV);
		end
		
	return;
end

	
function sigIV=calc_sigIV(p,r,TE,tau)
		
		X0=0.27e-6;
		rc=2.6; %micrometers
		D=2*1000; %micrometers squared per second
		taud=rc^2/D;
		%T2b0=189e-3;
		
		if length(p.R)==1
			G0=(4/45)*r.Hct*(1-r.Hct)*(4*pi*X0*(0.95-r.Y)*p.B0)^2;
			sigIV=exp(-(p.gamma.^2/2).*G0.*taud.^2.*((TE./taud)+((1./4)+(TE./taud)).^(1/2)...
				+(3/2)-2.*((1/4)+(TE-(TE-tau)/2)./taud).^(1/2)...
				-2.*((1./4)+((TE-tau)/2)/taud).^(1/2))).*exp(-TE./r.T2b0);
		else
			sigIV=NaN(length(tau),1);
		end
		
	return;
end
		