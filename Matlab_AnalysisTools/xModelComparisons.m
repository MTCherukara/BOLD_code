% xModelComparisons.m

% Comparing the results of Fabber ModelFits (simulated data)

% MT Cherukara
% 6 December 2018

% Actively used as of 2019-01-31


clear;
close all;

setFigureDefaults;


% Select the rows we want to plot
plotrows = [3,4,5];


%% Comparisons of SNR Levels (R2p model, 2C simulation, 24 taus)

% Row Names
rnames = {'Uncorr'    ; ...   % 1 - Uncorrected, std thresholding
          'k = 0.52'  ; ...   % 2 - Kappa correction, std thresholding
          'Uncorr'    ; ...   % 3 - Uncorrected
          'k = 0.52'  ; ...   % 4 - Kappa correction
          'k = 0.52'  ; ...   % 5 - Kappa correction, different implementation
         };
     
% SNR values
SNR = [ 5, 10, 25, 50, 100, 200, 500 ];


% SNR        5         10         25         50        100        200        500
Err_OEF = [ 32.2000,   28.9000,   27.2000,   26.1000,   25.4000,   24.6000,   24.4000; ...
            23.7000,   18.8000,   15.5000,   15.7000,   17.9000,   20.1000,   21.0000; ...
            26.3000,   23.8000,   24.7000,   24.9000,   24.7000,   24.2000,   24.0000; ...
            24.3000,   19.5000,   15.5000,   15.6000,   17.9000,   20.0000,   21.1000; ...
            24.3000,   21.4000,   18.1000,   16.0000,   14.3000,   13.4000,   11.8000 ];

% SNR        5         10         25         50        100        200        500
Err_DBV = [ 18.9000,   13.4000,    8.5000,    5.8600,    4.4600,    4.1000,    3.8600; ...
            18.1000,    9.0800,    4.9000,    3.8100,    3.8100,    3.9800,    4.0700; ...
            13.6000,   11.0000,    8.2400,    6.0100,    4.5000,    4.0900,    3.8500; ...
            14.3000,    8.0200,    5.0800,    4.0300,    4.0600,    4.1500,    4.1100; ...
            12.7000,   10.6000,    7.7500,    5.5700,    4.3000,    4.0200,    3.7900 ];

% SNR        5         10         25         50        100        200        500
Err_R2p = [  6.0100,    5.7300,    5.1800,    5.0400,    4.9200,    4.9100,    4.9000; ...
             8.9900,    5.4100,    3.7300,    3.2200,    3.1500,    3.1100,    3.0900; ...
             6.2900,    5.5500,    4.9500,    4.8600,    4.7800,    4.7800,    4.7800; ...
             7.2900,    4.8300,    3.6400,    3.2500,    3.1500,    3.1100,    3.0900; ...
             6.5500,    5.5700,    4.8000,    4.2000,    3.8500,    3.7600,    3.6800 ];

% SNR         5         10         25         50        100        200        500
Rel_All = [ 770.4000,  543.9000,  372.6000,  308.2000,  263.0000,  248.8000,  246.2000; ...
            884.9000,  550.4000,  352.2000,  245.4000,  215.1000,  221.8000,  227.8000; ...
            549.0000,  472.5000,  373.1000,  325.5000,  268.6000,  254.0000,  250.2000; ...
            720.9000,  502.8000,  350.2000,  250.7000,  237.1000,  228.5000,  229.1000; ...
            606.4000,  520.8000,  431.7000,  345.7000,  286.9000,  267.9000,  258.700 ];


   
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
legend(rlabels{:});
xlim([4,600]);
ylim([0,7.5]);
xticks(SNR);

% Plot DBV Error
Max_DBV = 18.5;
% Err_DBV(abs(Err_DBV) > Max_DBV) = Max_DBV;
figure; box on;
semilogx(SNR,abs(Err_DBV(plotrows,:))');
hold on;
ylabel('DBV Error (%)');
xlabel('SNR');
legend(rlabels{:});
xlim([4,600]);
ylim([0, Max_DBV]);
xticks(SNR);

% Plot OEF Error
figure; box on;
semilogx(SNR,abs(Err_OEF(plotrows,:))');
hold on;
ylabel('OEF Error (%)');
xlabel('SNR');
legend(rlabels{:});
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