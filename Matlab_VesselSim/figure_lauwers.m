function figure_lauwers(simdir,bids_dir)

	TE=80e-3;
	tauASE=[-28:4:64]./1000;

	Ds=[6:2:200];
	DsT=1./sqrt(Ds);
	relVf=normpdf(DsT,0.38,0.07);
	relVf=relVf./sum(relVf);
	
	Rs=Ds./2;
	%Rs=[Rs(Rs<=10) 20 30 40 50 60 70 80 90 100];
	%relVf=[relVf(Rs<10) sum(relVf(find((Rs>=10).*(Rs<15)))) sum(relVf(find((Rs>=15).*(Rs<25)))) sum(relVf(find((Rs>=25).*(Rs<35)))) sum(relVf(find((Rs>=35).*(Rs<45)))) sum(relVf(find((Rs>=45).*(Rs<55)))) sum(relVf(find((Rs>=55).*(Rs<65)))) sum(relVf(find((Rs>=65).*(Rs<75)))) sum(relVf(find((Rs>=75).*(Rs<85)))) sum(relVf(find((Rs>=85).*(Rs<95)))) sum(relVf(find((Rs>=95).*(Rs<105))))];
	
	Ya=1;
	E0=0.4;
	Yv=Ya.*(1-E0);
	k=0.4;
	Yc=Ya*k+Yv*(1-k);
	Y=Yv;
	
	Vtot=0.05.*0.793;
	Vf=relVf.*Vtot;
	
	for k=1:length(Rs)
		load([simdir 'single_vessel_radius_D1-0Vf3pc_dist/simvessim_res' num2str(Rs(k)) '.mat']);
		[sigASE(:,k) tauASE sigASEev(:,k) sigASEiv(:,k)]=generate_signal(p,spp,'display',false,'Vf',Vf(k),'Y',Yv,'seq','ASE','includeIV',true,'T2EV',Inf,'T2b0',Inf,'TE',TE,'tau',tauASE);
	end
	
	sigASEtot=(1-sum(Vf)).*prod(sigASEev,2)+sum(bsxfun(@times,Vf,sigASEiv),2);
	se=find(tauASE==0);
	sigASEtotn=sigASEtot./mean(sigASEtot(se-1:se+1));
	
	lc=lines(6);
		
	figure;
	if exist([bids_dir '/derivatives/group_results.mat'])
		load([bids_dir '/derivatives/group_results.mat'],'tcn')
		plot(tauASE.*1000,tcn,'color',[0.5 0.5 0.5])
	end
	hold on;
	plot(tauASE.*1000,sigASEtotn,'color',lc(2,:),'linewidth',3)
	xlim([min(tauASE.*1000) max(tauASE.*1000)]);
	ylim([0.8 1.02]);
	set(gca,'xtick',[-28:14:56]);
	set(gca,'ytick',[0.8:0.05:1]);
	grid on;
	axis square;
	title('Multiple vessel scale simulations: Lauwers');
	xlabel('Spin echo displacement time, \tau (ms)');
	ylabel('Signal fraction (arb.)');
	
	Ds=[0:2:200];
	DsT=1./sqrt(Ds);
	Rs=Ds./2;
	relVf=normpdf(DsT,0.38,0.07);
	relVf(Rs<3)=0;
	relVf=relVf./sum(relVf);
	
	figure;
	stairs(Rs,relVf);
	axis square;
	xlim([0 100])
	title('Multiple vessel relative volume fractions: Lauwers');
	xlabel('Vessel radius (\mum)');
	ylabel('Relative volume fraction');	
	grid on;

