% xPlotErrors

% plot some ASE curves with errorbars (created using xCalcErrors.m)

clear; close all;

figure(1);
hold on; box on;

load('signalResults/VSsignal_R_100_Static');
plot(1000*t,sigm,'o-','LineWidth',2);
load('signalResults/VSsignal_R_100_Diff');
plot((1000*t),sigm,'o-','LineWidth',2);

ylabel('ASE Signal');
xlabel('Spin Echo Offset \tau (ms)');
legend('D = 0','D = 10^-^9','Location','South');
title('Static vs Diffusion, R = 100\mum');
axis([-30, 30, 0.75, 1.0]);
set(gca,'FontSize',16);