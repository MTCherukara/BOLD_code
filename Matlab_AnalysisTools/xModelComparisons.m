% xModelComparisons.m

% Comparing the results of Fabber ModelFits (simulated data)

% MT Cherukara
% 6 December 2018

% Actively used as of 2019-01-31


clear;
close all;

setFigureDefaults;


% Select the rows we want to plot
plotrows = [1,2,4,6];


%% Data for SNR comparisons using SDR model, February 2019

% Row Names
rnames = {'Uncorrected' ; ...   %  1 - Sharan, uncorrected
          '\kappa Correction' ; ...   %  2 - Sharan, Kappa corr on long tau only
          'All \kappa'  ; ...   %  3 - Sharan, Kappa corr on all taus
          '\kappa and \eta Corr.'  ; ...   %  4 - Sharan, Scalar Eta correction
          '\eta(DBV)'   ; ...   %  5 - Sharan, eta(DBV) correction
          '\kappa and \alpha Corr.'; ...   %  6 - Sharan, alpha (geometric) correction
          };
     
% SNR values
SNR = [ 5, 10, 25, 50, 100, 200, 500 ];


% SNR        5        10        25        50       100       200       500
Err_OEF = [ 31.6000   33.9500   34.9800   35.5000   34.3600   34.1600   34.1500
            35.2500   34.3000   31.4500   26.6000   21.1500   17.3100   15.4300
            37.4900   36.2700   32.3700   25.3500   19.9600   17.4300   15.0900
            35.4800   35.6600   29.7100   25.0700   25.3000   26.0800   26.1400
            31.6000   29.9200   28.4000   28.2300   26.3600   26.7600   25.7200
            36.5600   33.0500   29.1100   23.1500   19.7600   17.6600   15.5400 ];

% SNR        5        10        25        50       100       200       500
Err_DBV = [ 13.6400   11.3700    8.2800    6.0300    4.5300    4.1000    3.8500
            14.5900    9.4700    6.0400    5.0500    4.6800    4.4700    4.4300
            16.6000    9.9400    5.9300    4.7900    4.4000    4.3100    4.3000
            16.8400   10.1700    5.9000    4.5300    3.9500    3.7800    3.7100
            12.7000    9.1000    5.6700    4.5200    4.0700    3.9100    3.8100
            16.4100    9.8700    5.7700    4.5800    4.2600    4.1800    4.1800 ];

% SNR        5        10        25        50       100       200       500
Err_R2p = [  6.4300    5.7500    5.0400    4.8600    4.7700    4.7800    4.7800
             6.1100    4.0100    3.2500    3.0500    3.0100    3.0000    3.0100
             7.2500    4.3000    3.2300    3.0000    2.9800    2.9700    2.9900
             7.8700    4.6100    3.3400    3.1000    3.0300    3.0200    3.0100
             7.1400    4.3200    3.3000    3.0700    3.0400    3.0300    3.0300
             8.1800    4.9100    3.5200    3.0900    3.0200    3.0100    3.0000 ];

% SNR         5        10        25        50       100       200       500
Rel_All = [ 544.6000  486.2000  387.5000  345.2000  289.4000  275.9000  273.6000
            698.6000  502.7000  335.7000  279.4000  252.2000  208.7000  202.5000
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