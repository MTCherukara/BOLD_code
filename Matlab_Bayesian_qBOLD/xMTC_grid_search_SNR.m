% xMTC_grid_search_SNR

clear; close all;

% these values are in the OneNote, under June 2017
OEF11m = [0.6339, 0.4527, 0.401,   0.4042,  0.4049 ];
OEF11s = [0.399,  0.192,  0.09094, 0.05072, 0.02813]; 

DBV11m = [0.05112, 0.03436, 0.02993,  0.03047,  0.03044 ];
DBV11s = [0.04335, 0.01685, 0.007481, 0.004402, 0.002466];

OEF21m = [0.4396, 0.3583, 0.4242,  0.4086,  0.4056 ];
OEF21s = [0.3661, 0.1065, 0.07163, 0.03795, 0.02185];

DBV21m = [0.03724, 0.02758, 0.03288 , 0.03074 , 0.03050 ];
DBV21s = [0.02612, 0.01164, 0.006393, 0.003273, 0.001993];

SNR = [5, 15, 50, 150, 500];

OEF_true = 0.4;
DBV_true = 0.03;

% plot 'em for OEF
figure('WindowStyle','docked');
hold on; box on;

errorbar(log(SNR),OEF11m,OEF11s,'-','LineWidth',2);
errorbar(log(SNR)+0.05,OEF21m,OEF21s,'r-','LineWidth',2);
plot([1.5,6.5],[OEF_true,OEF_true],'k--','LineWidth',3);
axis([1.5, 6.5, 0, 1]);
xticks(log(SNR));
xticklabels({'5','15','50','150','500'});
xlabel('Simulated SNR');
ylabel('Inferred OEF');
legend('11 \tau values','21 \tau values','True OEF','Location','NorthEast');

set(gca,'FontSize',16);

% plot 'em for DBV
figure('WindowStyle','docked');
hold on; box on;

errorbar(log(SNR),DBV11m,DBV11s,'-','LineWidth',2);
errorbar(log(SNR)+0.05,DBV21m,DBV21s,'r-','LineWidth',2);
plot([1.5,6.5],[DBV_true,DBV_true],'k--','LineWidth',3);
axis([1.5, 6.5, 0, 0.1]);
xticks(log(SNR));
xticklabels({'5','15','50','150','500'});
xlabel('Simulated SNR');
ylabel('Inferred DBV');
legend('11 \tau values','21 \tau values','True DBV','Location','NorthEast');

set(gca,'FontSize',16);