% xModelComparisons.m

% Comparing the results of Fabber ModelFits (simulated data)

% MT Cherukara
% 6 December 2018

% Actively used as of 2019-01-31


clear;
close all;

setFigureDefaults;


% Select the rows we want to plot
plotrows = [1,4,7,8];


%% Data for SNR comparisons using SDR model, February 2019

% Row Names
rnames = {'L Model (LLS)'    ; ...   % 1 - L model, MATLAB
          'L Model (VB)'     ; ...   % 2 - L model, VB
          '1C Model (VB)'    ; ...   % 3 - 1C model, new thresholding
          '1C Model (VB)'    ; ...   % 4 - 1C model, new, with std thresholding
          '2C Model (VB)'    ; ...   % 5 - 2C model, new thresholding
          '2C Model (VB)'    ; ...   % 6 - 2C model, new, with std thresholding
          '11 \tau (LLS)'    ; ...   % 7 - 1C model, 11 taus, MATLAB
          '11 \tau (VB)'     ; ...   % 8 - 1C model, 11 taus, VB
          };
     
% SNR values
SNR = [ 5, 10, 25, 50, 100, 200, 500 ];


% SNR        5         10         25         50        100        200        500
Err_OEF = [ 27.7000,   22.7000,   15.8000,   11.6000,    7.8000,    5.6700,    4.5000; ...
            26.3000,   21.6000,   14.9000,   10.6000,    7.5500,    5.5600,    4.5100; ...
            25.2000,   20.8000,   14.6000,   11.1000,    8.2700,    6.7300,    5.8100; ...
            22.1000,   17.5000,   12.2000,    8.8300,    6.3200,    5.2100,    4.6800; ...
            24.6000,   20.2000,   14.4000,   10.8000,    8.0300,    6.3500,    5.5300; ...
            21.5000,   17.3000,   12.2000,    9.0000,    6.7400,    5.4900,    4.8600; ...
            35.0000,   31.7000,   26.9000,   22.4000,   21.3000,   21.0000,   20.5000; ...
            25.6000,   24.9000,   23.7000,   22.0000,   21.1000,   20.8000,   20.7000 ];

% SNR        5         10         25         50        100        200        500
Err_DBV = [ 17.7000,    7.9800,    3.2700,    1.9400,    1.2600,    0.9800,    0.8600; ...
            17.6000,    8.3100,    3.3000,    1.8000,    1.2300,    0.9600,    0.8600; ...
            12.1000,    7.4000,    3.4600,    2.1500,    1.4500,    1.1900,    1.0300; ...
            15.1000,    7.6300,    3.3600,    1.7800,    1.1900,    1.0100,    0.9500; ...
            11.7000,    7.1500,    3.5800,    1.8000,    1.3700,    1.0100,    0.9100; ...
            13.2000,    7.1200,    2.7500,    1.4800,    1.0000,    0.7900,    0.7700; ...
            19.0000,    8.3100,    3.7800,    2.0100,    1.1800,    0.7600,    0.5800; ...
            11.2000,    7.5300,    4.2800,    2.3500,    1.3400,    0.8700,    0.6700 ];

% SNR        5         10         25         50        100        200        500
Err_R2p = [  5.2500,    3.3300,    2.6800,    2.5300,    2.4800,    2.4500,    2.3900; ...
             4.0900,    2.9900,    2.6300,    2.5200,    2.4700,    2.4400,    2.3900; ...
             4.4400,    3.3200,    2.6400,    2.5500,    2.4700,    2.4500,    2.4100; ...
             5.9300,    4.0000,    3.0800,    2.7700,    2.6300,    2.5600,    2.4800; ...
             3.4700,    2.7300,    2.3400,    2.3000,    2.2700,    2.2300,    2.2000; ...
             4.2300,    3.2900,    2.6300,    2.4500,    2.3500,    2.2800,    2.2300; ...
             5.3600,    2.9400,    2.0200,    1.8700,    1.8100,    1.8000,    1.7800; ...
             3.7600,    2.6500,    2.0200,    1.8400,    1.7600,    1.7300,    1.7200 ];

% SNR          5         10        25        50       100       200       500
Rel_All = [  763.0,     390.3,    176.7,    106.4,     66.1,     64.8,     43.5; ...
             764.9,     404.7,    176.9,    104.8,     69.8,     52.0,     43.8; ...
             581.5,     384.3,    560.2,    159.9,    116.1,     98.6,     79.0; ...
             416.3,     251.2,    150.4,     77.1,     56.0,     47.8,     45.7; ...
             617.4,     506.6,    329.1,    167.1,    145.6,    110.1,     98.1; ...
             356.1,     341.3,    134.0,     80.7,     71.3,     49.1,     44.2; ...
             832.2,     419.8,    199.6,    125.0,     94.2,     80.6,     71.6; ...
             496.7,     356.6,    236.2,    177.0,    130.6,    115.1,    105.4 ];


   
%% Plotting SNR comparisons

% Pull out the rows we want
npr = length(plotrows);
rlabels = rnames(plotrows);

% modified SNR
% modSNR = repmat(SNR,length(nmes),1)./repmat(sqrt(nmes)',1,length(SNR));


% Plot R2p Error
figure; box on;    
semilogx(SNR,abs(Err_R2p(plotrows,:))');
hold on;
ylabel('R_2'' Error (s^-^1)');
xlabel('SNR');
% legend(rlabels{:});
xlim([4,600]);
ylim([1,6.5]);
xticks(SNR);

% Plot DBV Error
Max_DBV = 18.5;
% Err_DBV(abs(Err_DBV) > Max_DBV) = Max_DBV;
figure; box on;
semilogx(SNR,abs(Err_DBV(plotrows,:))');
hold on;
ylabel('DBV Error (%)');
xlabel('SNR');
% legend(rlabels{:});
xlim([4,600]);
ylim([0, Max_DBV]);
xticks(SNR);

% Plot OEF Error
figure; box on;
semilogx(SNR,abs(Err_OEF(plotrows,:))');
hold on;
ylabel('OEF Error (%)');
xlabel('SNR');
% legend(rlabels{:});
xlim([4,600]);
ylim([0,32]);
xticks(SNR);

% % Plot Total Relative Error
% Max_Rel = 400;
% Rel_All(Err_DBV > Max_Rel) = Max_Rel;
% figure; box on;
% semilogx(SNR,Rel_All(plotrows,:));
% hold on;
% ylabel('Total Relative Error (%)');
% xlabel('SNR');
% legend(rlabels{:});
% xlim([4,600]);
% ylim([0, Max_Rel]);
% xticks(SNR);