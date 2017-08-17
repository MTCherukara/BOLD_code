% xPlotErrors

% plot some ASE curves with errorbars (created using xCalcErrors.m)

clear; close all;

figure(1);
hold on; box on;

load('signalResults/VSsignal_VesselDist_Triple');
errorbar(1000*t,sigm,sige,'o-','LineWidth',2);
load('signalResults/VSsignal_VesselDist_Average');
errorbar((1000*t),sigm,sige,'o-','LineWidth',2);

ylabel('ASE Signal');
xlabel('Spin Echo Offset \tau (ms)');
legend('Three Vessels','Average Vessel','Location','South');
title('Three Vessel Types, Static')
set(gca,'FontSize',16);