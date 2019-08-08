% xBootstrapTest.m
%
% Plot the results from Bootstrap tests of tau values (simulated data)
%
% MT Cherukara
% 27 June 2019

clear;
% close all;

setFigureDefaults;

%% Data (TE = 48 ms) - Frechet
% taus = -8:4:32;
% 
% CorrOEF = [ 0.9300    0.9250    0.7950    0.9270    0.9310    0.8980    0.9190    0.9520    0.9330    0.9540    0.9640 ];
% CorrDBV = [ 0.6600    0.6620    0.1030    0.6630    0.6570    0.7050    0.7220    0.8180    0.5850    0.9080    0.8060 ];
% CorrR2p = [ 0.9830    0.9830    0.8300    0.9830    0.9830    0.9820    0.9830    0.9890    0.9790    0.9870    0.9920 ];
% 
% ErrOEF = [ 43.5900   43.0900   44.3500   43.0000   43.7500   45.5700   43.2000   40.1300   41.3000   40.3200   37.0100 ];
% ErrDBV = [ 56.7600   55.4500   71.9100   55.2000   57.1600   65.1800   52.0400   46.6800   52.8600   47.6500   37.6000 ];
% ErrR2p = [ 26.0200   25.5800   27.2400   25.6300   26.0200   22.9800   22.9300   20.5600   23.0400   16.7000   21.8400 ];


%% Data (TE = 80 ms) - Frechet
% taus = -16:8:64;
% 
% CorrOEF = [ 0.4980    0.4560    0.5420    0.4440    0.4850    0.3530    0.4880    0.4870    0.3410    0.4090    0.4380 ];
% CorrDBV = [ 0.3450    0.3500    0.3380    0.2840    0.3240    0.0520    0.3030    0.2530    0.0680    0.2380    0.3050 ];
% CorrR2p = [ 0.8070    0.7110    0.7660    0.6750    0.7680    0.4840    0.6130    0.5850    0.3460    0.6170    0.5820 ];
% 
% ErrOEF = [  52.1200   53.8700   56.1700   53.8500   52.7000   56.5900   53.1700   53.2300   54.7800   53.8200   53.5300 ];
% ErrDBV = [ 121.8400  128.5200  166.3300  128.5800  124.2400  149.2800  124.9400  129.8600  145.4000  126.4400  112.7700 ];
% ErrR2p = [  22.4800   23.2400   19.6200   24.0000   22.6500   31.4600   24.0500   25.3800   29.4400   24.8700   27.4900 ];
% 
% ErrDBV = ErrDBV./2;

%% Data (TE = 80 ms) - Sharan
% taus = -8:4:32;
% 
% CorrOEF = [ 0.7320    0.7590    0.7190    0.7730    0.7580    0.7300    0.6770    0.8070    0.8050    0.7990    0.7670 ];
% CorrDBV = [ 0.6070    0.4940    0.4970    0.5260    0.5390    0.5480    0.5600    0.6870    0.4230    0.7750    0.6870 ];
% CorrR2p = [ 0.9790    0.9650    0.9720    0.9680    0.9670    0.9720    0.9680    0.9890    0.9580    0.9810    0.9780 ];
% 
% ErrOEF = [ 51.2900   51.5200   51.8100   51.7000   51.3200   51.4400   54.6800   50.7600   53.0500   51.2100   50.6200 ];
% ErrDBV = [ 39.7590   43.0210   56.8190   42.5210   43.0020   42.8200   56.6770   37.1260   48.7540   34.7420   24.4360 ];
% ErrR2p = [ 49.7920   51.1560   50.5520   50.5400   50.7370   51.5730   49.2100   48.3450   53.2880   42.7420   51.3400 ];


%% Data (TE = 80 ms) - Sharan, various Tau distributions

CorrOEF = [ 0.6010    0.5470    0.6690    0.6140    0.6250    0.5760    0.5350 ];
CorrDBV = [ 0.5720    0.3730    0.6860    0.3830    0.3410    0.2730    0.3140 ];
CorrR2p = [ 0.9200    0.6550    0.9750    0.7570    0.8070    0.8390    0.7760 ];

ErrOEF = [ 53.4300   54.0000   45.1800   54.7300   55.1800   54.8100   54.5600 ];
ErrDBV = [ 81.5230   84.2930   36.5460   87.6280   91.6620   95.8010  101.8800 ];
ErrR2p = [ 32.2940   34.7720   47.4670   37.7980   38.1650   35.6910   36.2930 ];

taus = 1:length(CorrOEF);


%% Line Plots
% % Plot Correlation
% figure;
% hold on; box on; grid on;
% plot(taus,CorrR2p);
% plot(taus,CorrDBV);
% plot(taus,CorrOEF);
% axis([min(taus),max(taus),0,1]);
% xticks(taus);
% xlabel('Spin Echo Displacement \tau (ms)');
% ylabel('True-Estimated Correlation');
% legend('R2''','DBV','OEF');
% 
% 
% % Plot Error (Relative)
% figure;
% hold on; box on; grid on;
% plot(taus,ErrR2p);
% plot(taus,ErrDBV);
% plot(taus,ErrOEF);
% axis([min(taus),max(taus),0,100]);
% xticks(taus);
% xlabel('Spin Echo Displacement \tau (ms)');
% ylabel('Relative Error (%)');
% legend('R2''','DBV','OEF');


%% Bar Plots

% Combine the data
CorrAll = [CorrR2p; CorrOEF; CorrDBV]';
ErrAll  = [ErrR2p;  ErrOEF;  ErrDBV]';

% Plot Correlation
figure;
hold on; box on; grid on;
bar(taus,CorrAll);
axis([0.5,6.5,0,1]);
xlabel('Sets of \tau values');
ylabel('True-Estimated Correlation');
legend('R2p','OEF','DBV','Location','SouthEast');

% Plot Relative Error 
figure;
hold on; box on; grid on;
bar(taus,ErrAll);
axis([0.5,6.5,0,100]);
xlabel('Sets of \tau values');
ylabel('Relative Error (%)');
legend('R2p','OEF','DBV','Location','SouthEast');
