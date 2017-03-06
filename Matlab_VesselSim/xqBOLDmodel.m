% xqBOLDmodel

% test for qBOLD model

clear; close all;

DBV = 0.05;
OEF = 0.4;
R2 = 0.11; % 110 ms
TE = 0.3;
Hct = 0.4;
lam = 0.1; % CSF volume

% params
dChi = 2.64e-7;
gam  = 2.67513e8;

dw = OEF*(4/3)*pi*gam*dChi*Hct*3;   % 142 s^-1, so 1.5 tc = 11 ms
R2p = DBV*dw;

R2s = R2 + R2p;
R2m = R2 - R2p;

t = linspace(0,0.02,100); % time up to 20 ms

tind = find(t>(1.5/dw),1,'first')-1;

s1 = exp(-R2s.*t);
s2 = exp(-((0.3).*DBV.*(dw.*t).^2) - (R2.*t));

s = [s2(1:tind),(s1(tind+1:end)+(s2(tind)-s1(tind)))];

% figure(1);
% plot(t*1000,s,'-','LineWidth',2); hold on;
% % plot(t*1000,s1,'--','LineWidth',2);
% % plot(t*1000,s2,':','LineWidth',2);
% box on;
% xlabel('Time (ms)');
% ylabel('Signal');
% set(gca,'FontSize',16);

%% ASE version

tau = linspace(-12,12,101)./1000; % -16 to 16 ms, odd number, so that we have one that's exactly at 0

S1 = exp(-R2.*(TE-2.*tau)+DBV-(2.*R2m.*tau));
S2 = exp(-(R2.*TE) - ((8/9).*DBV.*(dw.*tau).^2));
S3 = exp(-R2.*(TE-2.*tau)+DBV-(2.*R2s.*tau));

ti1 = find(tau>(-0.75/dw),1,'first');
ti2 = find(tau<(0.75/dw),1,'last');

SS = [S1(1:ti1-1), S2(ti1:ti2), S3(ti2+1:end)];

% figure(2); hold on;
% plot(tau.*1000,SS,'b-','LineWidth',2);
% plot(tau.*1000,S3,'r--','LineWidth',3);
% plot([0,0],[0,2],'k:','LineWidth',2);
% plot([-20,20],[S3(51),S3(51)],'k-');
% plot([-20,20],[S2(51),S2(51)],'k-');
% axis([-4,12,0.84,1.03]);
% box on;
% xlabel('\tau (ms)');
% ylabel('Signal');
% set(gca,'FontSize',16);

% disp(['DBV estimate: ',num2str(S3(51)-S2(51))]);

%% Blood component

R2b  = ( 16.4.*Hct ) +  4.5 + ((165.2.*Hct + 55.7).*OEF.^2);
R2bs = ( 14.9.*Hct ) + 14.7 + ((302.1.*Hct + 41.8).*OEF.^2);

R2bp = R2bs-R2b;
SB = exp(-TE*R2b).*exp(-abs(tau)*R2bp);

figure(3); hold on;
plot(tau.*1000,SS./max(SS),'-','Linewidth',2);
plot(tau.*1000,SB./max(SB),'-','LineWidth',2);
axis([-4,12,0.84,1.01]);
box on;
xlabel('\tau (ms)');
ylabel('Signal');
set(gca,'FontSize',12);

%% CSF component

R2e = 4;
Df  = 5;

SE = real(exp(-(R2e.*TE) - (4i.*pi.*Df.*abs(tau))));
figure(3);
plot(tau.*1000,SE./max(SE),'-','LineWidth',2);

%% Add it all up

Stotal = (DBV.*SB./max(SB)) + (1-DBV-lam).*SS./max(SS) + (lam.*SE./max(SE));

figure(3);
plot(tau.*1000,Stotal,'k--','LineWidth',2);
plot([0,0],[0,2],'k:','LineWidth',2);
legend('Tissue','Blood','CSF','Total','Location','SouthWest');
