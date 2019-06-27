% function figure_frechet(simdir,bids_dir)

clear;

simdir = '../../Data/vesselsim_data/';
tic;

% Fixed Parameters
TE  = 0.060;
tau = (-28:8:64)./1000;    % For TE = 72ms or 108ms or 88 ms
% tau = (-12:4:32)./1000;      % For TE = 36ms or 56 ms

% Physiology
OEF = 0.4;
DBV = 0.03;

Rs=3:1:100;
relVf=gevpdf(Rs,0.41,5.8,10.1);
relVf=relVf./sum(relVf);

% Rs=[Rs(Rs<=10) 20 30 40 50 60];
% relVf=[relVf(Rs<10), sum(relVf(find((Rs>=10).*(Rs<15)))), ...
%        sum(relVf(find((Rs>=15).*(Rs<25)))), sum(relVf(find((Rs>=25).*(Rs<35)))), ...
%        sum(relVf(find((Rs>=35).*(Rs<45)))), sum(relVf(find((Rs>=45).*(Rs<55)))), ...
%        sum(relVf(find((Rs>=55).*(Rs<65))))];

Ya  = 1; 
Yv  = Ya.*(1-OEF);
Hct = 0.4;
Y   = Yv;

Vtot=DBV.*0.793;
Vf=relVf.*Vtot;

R2b = 4.5 + 16.4*Hct + (165.2*Hct + 55.7)*OEF^2;

for k = 1:length(Rs)
    load([simdir,'single_vessel_radius_D1-0Vf3pc_dist/simvessim_res',num2str(Rs(k)),'.mat']);
    [sigASE(:,k), tau, sigASEev(:,k), sigASEiv(:,k)] = generate_signal(p,spp,...
         'display',false,'Vf',Vf(k),'Y',Yv,'seq','ASE','includeIV',false,...
         'T2EV',0.087,'T2b0',1/R2b,'TE',TE,'tau',tau);
end

sigASEtot=(1-sum(Vf)).*prod(sigASEev,2)+sum(bsxfun(@times,Vf,sigASEiv),2);
se=find(tau==0);
S0 = sigASEtot./mean(sigASEtot(se-1:se+1));

toc; 


figure(1);
hold on;
plot(tau.*1000,S0);
xlim([min(tau.*1000) max(tau.*1000)]);
ylim([0.8 1.02]);
set(gca,'xtick',-28:14:56);
set(gca,'ytick',0.8:0.05:1);
grid on;
axis square;
title('Multiple vessel scale simulations: Frechet');
xlabel('Spin echo displacement time, \tau (ms)');
ylabel('Signal fraction (arb.)');


% % Plot vessel radii distribution
% figure;
% bar(Rs,relVf);
% axis square;
% xlim([0 100])
% title('Multiple vessel relative volume fractions: Frechet');
% xlabel('Vessel radius (/mum)');
% ylabel('Relative volume fraction');

Ds=[0:2:200];
Rs=Ds./2;
relVf=gevpdf(Rs,0.41,5.8,10.1);
relVf(Rs<3)=0;
relVf=relVf./sum(relVf);

% Plot vessel radii distribution
figure;
stairs(Rs,relVf);
axis square;
xlim([0 100])
title('Multiple vessel relative volume fractions: Frechet');
xlabel('Vessel radius (\mum)');
ylabel('Relative volume fraction');
grid on;
	