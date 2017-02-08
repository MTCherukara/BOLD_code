function ivASE=intravascularsim(p,TE,Y)

t=repmat((p.deltaTE:p.deltaTE:p.TE*2)',1,length(p.R));

if nargin>1
	if ~isempty(TE)
		p.TE=TE;
	end
end

if nargin<3
	Y=p.Y(end);
end

%intravascular GESSE signal - c.f. Simon et al. 2016
R2s=repmat((14.9.*p.Hct+14.7)+(302.1.*p.Hct+41.8).*(1-p.Y).^2,length(t),1);
R2=repmat((16.4.*p.Hct+4.5)+(165.2.*p.Hct+55.7).*(1-p.Y).^2,length(t),1);

S1=exp(-R2s.*t);
S2=exp(-R2.*(2.*t-p.TE)-R2s.*(p.TE-t));
S3=exp(-R2.*p.TE-R2s.*(t-p.TE));

ivGESSE=S1.*(t<(p.TE/2))+S2.*((t>=(p.TE/2)).*(t<p.TE))+S3.*(t>=p.TE);

%intravascular ASE signal
t=repmat((-p.TE:p.deltaTE*2:p.TE)',1,length(p.R));
R2s=repmat((14.9.*p.Hct+14.7)+(302.1.*p.Hct+41.8).*(1-p.Y).^2,length(t),1);
R2=repmat((16.4.*p.Hct+4.5)+(165.2.*p.Hct+55.7).*(1-p.Y).^2,length(t),1);

ivASE=exp(-p.TE.*R2).*exp(-abs(t).*(R2s-R2));

%keyboard;