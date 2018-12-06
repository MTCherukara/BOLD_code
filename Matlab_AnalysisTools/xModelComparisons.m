% xModelComparisons.m

% Comparing the qBOLD models using various comparison methods

% MT Cherukara
% 6 December 2018

clear;
close all;

setFigureDefaults;

% Data
SNR  = [  5    ,  10    ,  25    , 50     , 100    , 500     ];
OC_L = [  0    ,   0.15 ,   0.082,   0.070,   0.096,   0.936 ];
OC_1 = [  0.241,   0.269,   0.287,   0.326,   0.416,   0.458 ];
OE_L = [  0    , 302.5  , 848.9  , 678.5  , 278.6  ,  16.8   ];
OE_1 = [104.2  ,  94.6  ,  69.3  ,  63.4  ,  53.3  ,  38.3   ];
DC_L = [  0    ,   0    ,   0.298,   0.621,   0.814,   0.924 ];
DC_1 = [  0    ,   0    ,   0.18 ,   0.294,   0.338,   0.309 ];
DE_L = [  0    ,  11.9  ,   4.3  ,   2.6  ,   1.7  ,   1.2   ];
DE_1 = [ 18.6  ,  10.5  ,  11.9  ,  14.1  ,  15.7  ,  19.2   ];

% Plot OEF Error
figure; box on;
semilogx(SNR(2:end),OE_L(2:end));
hold on;
semilogx(SNR,OE_1);
ylabel('OEF Error (%)');
xlabel('SNR');
legend('Linear Model','1C Model');
xlim([0,500]);
xticks(SNR);

% Plot DBV Error
figure; box on;
semilogx(SNR(2:end),DE_L(2:end));
hold on;
semilogx(SNR,DE_1);
ylabel('DBV Error (%)');
xlabel('SNR');
legend('Linear Model','1C Model');
xlim([0,500]);
xticks(SNR);

% Plot OEF Correlation
figure; box on;
semilogx(SNR,OC_L);
hold on;
semilogx(SNR,OC_1);
ylabel('OEF Correlation');
xlabel('SNR');
legend('Linear Model','1C Model');
xlim([0,500]);
xticks(SNR);

% Plot DBV Correlation
figure; box on;
semilogx(SNR,DC_L);
hold on;
semilogx(SNR,DC_1);
ylabel('DBV Correlation');
xlabel('SNR');
legend('Linear Model','1C Model');
xlim([0,500]);
xticks(SNR);
