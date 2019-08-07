% Figure_AcquisitionOptimBars.m
%
% Plot a bar chart showing the comparison of model corrections alongside optimal
% acquisition protocols. Based on barcharts_new.m
%
% MT Cherukara
% 7 August 2019


clear;
% close all;
setFigureDefaults;

%% Plotting Information

% key to data array columns
lbls = {'TE=66, \tau=32','TE=80, \tau=32','TE=80, \tau=64','TE=112, \tau=32','TE=112, \tau=96'};

% Choose which columns to plot
dpts = [1,6,7];

%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    DATA             % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%       66-32     84-32     84-64     112-32    112-96
R2p = [ 2.0610    2.8800    2.6810    2.0260    2.9820      % Unc
        2.6210    3.9760    3.9390    2.8120    4.3670      % Kappa S
        2.2560    3.4600    3.3590    2.4260    3.8290      % K/E S
        2.4720    4.1560    4.0810    3.8180    5.5900      % Kappa J
        3.0270    4.5610    4.4710    3.4600    5.1920      % K/E J
        2.6570    4.0880    3.9940    3.1630    4.8340      % Kappa L
        3.6890    5.1580    5.5800    4.4510    6.6030      % K/E L
        ];

%       66-32     84-32     84-64     112-32    112-96
DBV = [ 4.5840    5.0850    7.2760    4.8130    9.8190
        3.8120    4.1900    6.3030    4.0940    8.8820
        4.0710    4.6050    6.6040    4.2430    9.9620
        3.9540    4.1290    6.2670    3.7920    7.2260
        3.4140    3.9500    6.1020    3.7810    7.2700
        3.6520    4.0540    6.1330    3.8780    7.7130
        3.1780    3.4210    5.6310    3.3200    6.0040
        ];

%       66-32     84-32     84-64     112-32    112-96
OEF = [ 19.0300   23.9400   18.8500   17.4400   17.4200
        28.5900   35.2900   28.5200   27.2800   23.3000
        23.4100   29.8900   24.2700   23.1600   19.8300
        26.5300   36.9400   29.6900   35.0100   32.5700
        33.0500   40.6800   32.5500   32.9000   30.6400
        29.8400   36.0900   29.6900   30.4000   27.4400
        41.0500   48.2900   42.5200   41.4400   42.8500
        ];
    

%% Bar Chart Plotting

% % Plot R2p
% figure; hold on; grid on;
% bar(1:5,R2p(dpts,:)');
% box on;
% axis([0.5,5.5,0,7.2]);
% % ylabel('dHb content (ml/100g)');
% ylabel('R_2'' (s^-^1)');
% xticklabels(lbls); 
% legend('uncorr.','\kappa corr.','\kappa,\eta corr.','Location','NorthWest');
% title('GM Mean dHb Estimates')
% xtickangle(315);


% Plot DBV
figure; hold on; grid on; 
bar(1:5,DBV(dpts,:)');
% axis square;
box on;
axis([0.5,5.5,0,10.8]);
ylabel('DBV (%)');
xticklabels(lbls);
legend('uncorr.','\kappa corr.','\kappa,\eta corr.','Location','NorthWest');
title('GM Mean DBV Estimates (La)')
xtickangle(315);


% Plot OEF
figure; hold on; grid on;
bar(1:5,OEF(dpts,:)');
box on;
axis([0.5,5.5,0,52]);
ylabel('OEF (%)');
xticklabels(lbls);
legend('uncorr.','\kappa corr.','\kappa,\eta corr.','Location','NorthWest');
title('GM Mean OEF Estimates (La)')
xtickangle(315);
