% xPlotErrors

% plot some ASE curves with errorbars (created using xCalcErrors.m)

clear; close all;

figure(1);
hold on; box on;

load('signalResults/VSsignal_Static_OEFdist_Single');
errorbar(1000*t,sigm,sige,'o-','LineWidth',2);
load('signalResults/VSsignal_Static_OEFdist_Normal');
errorbar((1000*t),sigm,sige,'o-','LineWidth',2);

ylabel('ASE Signal');
xlabel('Spin Echo Offset \tau (ms)');
legend('Single OEF','Normal Distribution','Location','South');
set(gca,'FontSize',16);