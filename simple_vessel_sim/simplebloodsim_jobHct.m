function simplebloodsim_jobHct(Hct)

	t=cputime;

	p=gentemplate;

	p.R=3e-6;
	p.N=10000;
	p.universeScale=sqrt(25000);
	p.D=1e-9;
	p.Hct=Hct/100;

	[spp p]=simplebloodsim(p);
		
	save(['../simbloodsim_resHct' num2str(Hct) '.mat']);
	
	e=cputime-t;
	
	disp(['CPUtime (mins): ' num2str(e/60)]);

return;
