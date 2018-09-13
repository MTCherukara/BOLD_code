% xBiexponential.m

% plot a biexponential decay function
R2t = 1/0.087;
R2e = 1/0.25;
theta = 0.1;

TE = linspace(0,0.250,1000);

P1 = (1-theta).*exp(-TE.*R2t);
P2 = theta*exp(-TE.*R2e);
Pb = P1 + P2;

figure();
hold on; box on;

plot(1000*TE,P1,'--','LineWidth',3);
plot(1000*TE,P2,':', 'LineWidth',3);
plot(1000*TE,Pb,'-', 'LineWidth',3);


xlabel('Echo Time TE (ms)');
ylabel('Signal');

legend('Tissue Compartment','CSF Compartment','Combined Signal');
