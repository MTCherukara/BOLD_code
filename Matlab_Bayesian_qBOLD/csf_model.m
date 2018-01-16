clear;

pve =0.2;

te=80e-3;
tau=(0:4:64)./1000;
t2gm=87e-3;
t2csf=250e-3;
t2p=300e-3;

figure('WindowStyle','docked');
plot(tau.*1000,exp(-te/t2gm).*exp(-tau./t2p));
hold on;
plot(tau.*1000,abs(pve.*exp(-te./t2csf).*exp(-2.*pi.*i.*7.*tau)+(1-pve).*exp(-te/t2gm).*exp(-tau./t2p)));
plot(tau.*1000,real(pve.*exp(-te./t2csf).*exp(-2.*pi.*i.*7.*tau)+(1-pve).*exp(-te/t2gm).*exp(-tau./t2p)));
legend('No CSF','abs','real');
title(['CSF Volume: ',num2str(pve)]);
set(gca,'FontSize',16);