% xModelComparisons.m

% Comparing the qBOLD models using various comparison methods

% MT Cherukara
% 6 December 2018

clear;
close all;

setFigureDefaults;

% % Data for 1C model
% SNR  = [  5    ,  10    ,  25    , 50     , 100    , 200     , 500     ];
% OC_L = [  0    ,   0.15 ,   0.082,   0.070,   0.096,   0.224 ,   0.936 ];
% OC_1 = [  0.241,   0.269,   0.287,   0.326,   0.416,   0.449 ,   0.458 ];
OE_L = [  0    , 302.5  , 848.9  , 678.5  , 278.6  , 139.2   ,  16.8   ];
% OE_1 = [104.2  ,  94.6  ,  69.3  ,  63.4  ,  53.3  ,  43.6   ,  38.3   ];
% DC_L = [  0    ,   0    ,   0.298,   0.621,   0.814,   0.894 ,   0.924 ];
% DC_1 = [  0    ,   0    ,   0.18 ,   0.294,   0.338,   0.308 ,   0.309 ];
% DE_L = [  0    ,  11.9  ,   4.3  ,   2.6  ,   1.7  ,   1.3   ,   1.2   ];
% DE_1 = [ 18.6  ,  10.5  ,  11.9  ,  14.1  ,  15.7  ,  17.9   ,  19.2   ];

% Data for 2C model
SNR  = [  5    ,  10    ,  25    , 50     , 100    , 200     , 500     ];
% OE_L = [  302  , 736    ,  2696   , 1065   , 112    , 34  , 385 ];
OE_1 = [  109  , 95.9   , 70.5   , 62.6   ,  60.8 , 53.3, 41.5 ];
OE_2 = [  114, 99.1, 75.4, 64.4, 50.8, 48.8, 47.8];
DE_L = [ 25.4, 10.9, 4.7, 2.6, 1.6, 1.16, 0.99];
DE_1 = [ 17.5, 9.32, 8.67, 10.7, 17.5, 17.8, 17.3];
DE_2 = [ 17, 9.18, 10.7, 13.5, 15.1, 16.6, 15.2];

% Plot OEF Error
figure; box on;
semilogx(SNR(1:end),OE_L(1:end));
hold on;
semilogx(SNR,OE_1);
semilogx(SNR,OE_2);
ylabel('OEF Error (%)');
xlabel('SNR');
legend('Linear Model','1C Model','2C Model');
xlim([0,500]);
ylim([0, 700]);
xticks(SNR);

% Plot DBV Error
figure; box on;
semilogx(SNR(1:end),DE_L(1:end));
hold on;
semilogx(SNR,DE_1);
semilogx(SNR,DE_2);
ylabel('DBV Error (%)');
xlabel('SNR');
legend('Linear Model','1C Model','2C Model');
xlim([0,500]);
xticks(SNR);

% % Plot OEF Correlation
% figure; box on;
% semilogx(SNR,OC_L);
% hold on;
% semilogx(SNR,OC_1);
% ylabel('OEF Correlation');
% xlabel('SNR');
% legend('Linear Model','1C Model','Location','NorthWest');
% xlim([0,500]);
% xticks(SNR);
% 
% % Plot DBV Correlation
% figure; box on;
% semilogx(SNR,DC_L);
% hold on;
% semilogx(SNR,DC_1);
% ylabel('DBV Correlation');
% xlabel('SNR');
% legend('Linear Model','1C Model','Location','NorthWest');
% xlim([0,500]);
% xticks(SNR);
