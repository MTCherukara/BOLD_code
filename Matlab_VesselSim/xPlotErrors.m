% xPlotErrors

% plot some ASE curves with errorbars (created using xCalcErrors.m)

clear; close all;

figure(1);
hold on; box on;

load('signalResults/VSsignal_OEFdist_Triple');
errorbar(1000*t,sigm,sige,'o-','LineWidth',2);
load('signalResults/VSsignal_OEFdist_Average');
errorbar((1000*t),sigm,sige,'o-','LineWidth',2);

ylabel('ASE Signal');
xlabel('Spin Echo Offset \tau (ms)');
legend('OEF = \{0.4,0.3,0.05\}','OEF = 0.24','Location','South');
title('Three OEF Values, Static')
set(gca,'FontSize',16);