% function figure_sharan(simdir,bids_dir)

clear;

setFigureDefaults;

simdir = '../../Data/vesselsim_data/';

TE=108e-3;
tauASE = (-28:4:64)./1000;    % For TE = 72ms or 108ms
% tauASE = (-12:4:32)./1000;      % For TE = 36ms

Ds=[5.6 15 30 45 90 180];
Rs=Ds./2;

Ya=1;
OEF=0.325;
DBV=0.03;
Yv=Ya.*(1-OEF);
k=0.4;
Yc=Yv; % Ya*k+Yv*(1-k);
Y=[Yc Yv Yv Yv Yv Yv];

aVessels=pi.*Rs.^2;
lVessels=[600 450 900 1350 2690 5390];
nVessels=[5.92e7 3.01e6 3.92e5 1.15e5 1.5e4 1880];
volVessels=nVessels.*lVessels.*aVessels;
relVf=volVessels./sum(volVessels);
Vtot=DBV*0.793;
Vf=relVf.*Vtot;

for k=1:length(Rs)
    load([simdir 'single_vessel_radius_D1-0_sharan/simvessim_res' num2str(Rs(k)) '.mat']);
    [sigASE(:,k), tauASE, sigASEev(:,k), sigASEiv(:,k)]=generate_signal(p,spp,'display',false,'Vf',Vf(k),'Y',Y(k),'seq','ASE','includeIV',false,'T2EV',Inf,'T2b0',Inf,'TE',TE,'tau',tauASE);
end

sigASEtot=(1-sum(Vf)).*prod(sigASEev,2)+sum(bsxfun(@times,Vf,sigASEiv),2);
se=find(tauASE==0);
sigASEtotn=sigASEtot./mean(sigASEtot(se-1:se+1));

lc=lines(6);

figure(1);
hold on;
plot(tauASE.*1000,sigASEtotn)
xlim([min(tauASE.*1000) max(tauASE.*1000)]);
ylim([0.8 1.02]);
set(gca,'xtick',-28:14:56);
set(gca,'ytick',0.8:0.05:1);
grid on;
axis square;
title('Multiple vessel scale simulations: Sharan');
xlabel('Spin echo displacement time, \tau (ms)');
ylabel('Signal fraction (arb.)');

Rs2=(1:100);
relVf2=zeros(size(Rs2));
for k=1:length(Rs)
    relVf2(Rs2==round(Rs(k)))=relVf(k);
end

% figure;
% stairs(Rs2,relVf2);
% axis square;
% xlim([0 100])
% title('Multiple vessel relative volume fractions: Sharan');
% xlabel('Vessel radius (\mum)');
% ylabel('Relative volume fraction');
% grid on;

