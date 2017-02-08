function simplevesselsim_jobY(Yv)

	t=cputime;

	p=gentemplate;

	Ya=0.98;
	k=0.6;
	Yc=(1-k)*Ya+k*Yv;

	p.R=[5 3 5].*1e-6;
	p.vesselFraction=[0.01 0.02 0.02];
	p.Y=[Ya Yc Yv];
	p.Hct=[0.4 0.4 0.4];
	p.N=10000;
	p.universeScale=sqrt(25000);
	p.D=1e-9;

	[spp p]=simplevesselsim(p);
		
	save(['../simvessim_res' num2str(Yv*100) '.mat']);
	
	e=cputime-t;
	
	disp(['CPUtime (mins): ' num2str(e/60)]);

return;
