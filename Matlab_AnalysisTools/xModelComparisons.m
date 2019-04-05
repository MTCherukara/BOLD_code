% xModelComparisons.m

% Comparing the results of Fabber ModelFits (simulated data)

% MT Cherukara
% 6 December 2018

% Actively used as of 2019-01-31


clear;
close all;

setFigureDefaults;


% Select the rows we want to plot
plotrows = [1,2,4];


%% Data for SNR comparisons using SDR model, February 2019

% Row Names
rnames = {'2C Uncorrected' ; ...   %  1 - Sharan, uncorrected
          '\kappa Correction' ; ...   %  2 - Sharan, Kappa corr on long tau only
          '\kappa and \eta Corr.'  ; ...   %  3 - Sharan, Scalar Eta correction
          '\kappa, \alpha, \beta, \eta Corr.'  ; ...   %  4 - Sharan, Kappa, Eta, Beta, Alpha
          '\kappa and \eta Corr.'   ; ...   %  5 - Sharan, Scalar Eta correction
          '\kappa and \alpha Corr.'; ...   %  6 - Sharan, alpha (geometric) correction
          'L Uncorrected'  ; ...    % 7 - Sharan, uncorrected L model
          'L \kappa Correction' ;   % 8 - Sharan, L model with Kappa corr
          };
     
% SNR values
SNR = [ 5, 10, 25, 50, 100, 200, 500 ];


% SNR        5        10        25        50       100       200       500
Err_OEF = [ 34.7800   32.1600   29.6300   28.6700   25.9700   25.6000   24.9000
            31.6900   30.1700   27.2900   23.4100   19.3800   15.7500   13.3400
            32.3100   30.9200   28.9500   29.9700   29.2300   27.3400   26.2800
            30.0300   29.1500   27.8400   24.6400   22.8300   19.5300   17.0400
            33.2300   31.7800   30.0700   31.6300   30.9100   29.5200   28.9000
            36.5600   33.0500   29.1100   23.1500   19.7600   17.6600   15.5400
            36.5700   35.9200   32.6100   27.9600   24.4900   23.1100   20.8500
            36.8900   36.5900   33.0200   27.2100   19.6700   17.3600   14.6200 ];

% SNR        5        10        25        50       100       200       500x
Err_DBV = [ 13.6400   11.3700    8.2800    6.0300    4.5300    4.1000    3.8500
             8.9300    5.9900    4.7100    4.3500    4.2300    4.2200    4.2400
            12.9300    9.1400    5.7800    4.5600    4.2500    4.1000    4.0800
             9.7800    6.5200    4.6400    4.1800    4.0200    3.9700    3.9900
            14.6600   10.9000    7.4300    5.8400    5.2600    5.0300    4.9500
            16.4100    9.8700    5.7700    4.5800    4.2600    4.1800    4.1800
            18.7400    8.4700    4.8700    4.0400    3.7800    3.7400    3.7100
            18.6500    8.4600    4.8500    4.0300    3.7700    3.7400    3.7100 ];

% SNR        5        10        25        50       100       200       500
Err_R2p = [  6.4300    5.7500    5.0400    4.8600    4.7700    4.7800    4.7800
             6.6900    4.4200    3.6100    3.4600    3.4200    3.4200    3.4200
             7.1100    4.3200    3.3200    3.1200    3.0800    3.0700    3.0700
             5.8800    3.9300    3.2300    3.0900    3.0700    3.0500    3.0500
             7.3400    4.6200    3.3100    3.0900    3.0600    3.0400    3.0300
             8.1800    4.9100    3.5200    3.0900    3.0200    3.0100    3.0000
             5.5700    4.9000    4.8600    4.8400    4.8200    4.8200    4.8200
             7.9500    4.9600    3.8400    3.6500    3.5600    3.5500    3.5300 ];

% SNR         5        10        25        50       100       200       500
Rel_All = [ 544.6000  486.2000  387.5000  345.2000  289.4000  275.9000  273.6000
            581.0000  393.8000  289.7000  249.8000  223.1000  206.6000  198.5000
            619.1000  493.5000  344.0000  310.8000  290.9000  271.2000  263.1000
            794.5000  535.8000  352.6000  277.5000  233.1000  209.7000  198.4000
            816.8000  571.9000  396.9000  325.2000  310.8000  301.9000  303.0000
            687.0000  470.7000  364.5000  307.0000  290.3000  270.3000  262.2000
            794.5000  535.8000  352.6000  277.5000  233.1000  209.7000  198.4000 ];
  
   
%% Plotting SNR comparisons

% Pull out the rows we want
npr = length(plotrows);
rlabels = rnames(plotrows);

% modified SNR
% modSNR = repmat(SNR,length(nmes),1)./repmat(sqrt(nmes)',1,length(SNR));


% Plot R2p Error
figure; box on;    
for pp = 1:npr
    semilogx(SNR,abs(Err_R2p(plotrows(pp),:))','Color',defColour(pp));
    hold on;
end

ylabel('R_2'' Error (s^-^1)');
xlabel('SNR');
legend(rlabels{:});
xlim([4,600]);
ylim([0,8.5]);
xticks(SNR);

% Plot DBV Error
Max_DBV = 17.5;
% Err_DBV(abs(Err_DBV) > Max_DBV) = Max_DBV;
figure; box on;
for pp = 1:npr
    semilogx(SNR,abs(Err_DBV(plotrows(pp),:))','Color',defColour(pp));
    hold on;
end

ylabel('DBV Error (%)');
xlabel('SNR');
legend(rlabels{:});
xlim([4,600]);
ylim([0, Max_DBV]);
xticks(SNR);

% Plot OEF Error
figure; box on;
for pp = 1:npr
    semilogx(SNR,abs(Err_OEF(plotrows(pp),:))','Color',defColour(pp));
    hold on;
end

ylabel('OEF Error (%)');
xlabel('SNR');
legend(rlabels{:},'Location','SouthWest');
xlim([4,600]);
ylim([10,38]);
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