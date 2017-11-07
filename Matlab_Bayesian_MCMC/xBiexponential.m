% xBiexponential.m

% plot a biexponential decay function
R2t = 1/0.11;
R2e = 1/0.25;
theta = 0.5;

TE = linspace(0,0.250,1000);

P1 = (1-theta).*exp(-TE.*R2t);
P2 = theta*exp(-TE.*R2e);
Pb = P1 + P2;

figure();
set(gcf,'WindowStyle','docked');
hold on; box on;

plot(1000*TE,P1,'--','LineWidth',3);
plot(1000*TE,P2,':', 'LineWidth',3);
plot(1000*TE,Pb,'-', 'LineWidth',3);

set(gca,'FontSize',18);

xlabel('Echo Time TE (ms)');
ylabel('Signal');

legend('Tissue Compartment','ECF Compartment','Combined Signal');
