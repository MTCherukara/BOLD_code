% xModelComparisons.m

% Comparing the qBOLD models using various comparison methods

% MT Cherukara
% 6 December 2018

clear;
close all;

setFigureDefaults;


%% Data for Comparisons across SNR levels
% % Data for 1C model
% SNR  = [  5    ,  10    ,  25    , 50     , 100    , 200     , 500     ];
% OC_L = [  0    ,   0.15 ,   0.082,   0.070,   0.096,   0.224 ,   0.936 ];
% OC_1 = [  0.241,   0.269,   0.287,   0.326,   0.416,   0.449 ,   0.458 ];
% OE_L = [  0    , 302.5  , 848.9  , 678.5  , 278.6  , 139.2   ,  16.8   ];
% OE_1 = [104.2  ,  94.6  ,  69.3  ,  63.4  ,  53.3  ,  43.6   ,  38.3   ];
% DC_L = [  0    ,   0    ,   0.298,   0.621,   0.814,   0.894 ,   0.924 ];
% DC_1 = [  0    ,   0    ,   0.18 ,   0.294,   0.338,   0.308 ,   0.309 ];
% DE_L = [  0    ,  11.9  ,   4.3  ,   2.6  ,   1.7  ,   1.3   ,   1.2   ];
% DE_1 = [ 18.6  ,  10.5  ,  11.9  ,  14.1  ,  15.7  ,  17.9   ,  19.2   ];

% Data for 2C model
SNR  = [  5    ,  10    ,  25    , 50     , 100    , 200     , 500     ];
OE_L = [  302  , 736    ,  2696   , 1065   , 112    , 34  , 385 ];
OE_1 = [  109  , 95.9   , 70.5   , 62.6   ,  60.8 , 53.3, 41.5 ];
OE_2 = [  114, 99.1, 75.4, 64.4, 50.8, 48.8, 47.8];
DE_L = [ 25.4, 10.9, 4.7, 2.6, 1.6, 1.16, 0.99];
DE_1 = [ 17.5, 9.32, 8.67, 10.7, 17.5, 17.8, 17.3];
DE_2 = [ 17, 9.18, 10.7, 13.5, 15.1, 16.6, 15.2];


%% Data for comparisons of FABBER prior precisions

PrecR2p = [     1e1,       1e0,       1e-1,      1e-2,      1e-3,      1e-4,      1e-5 ];
PrecDBV = [ 1e2, 1e1, 1e0, 1e-1, 1e-2];

% P(R2')     1e1        1e0        1e-1       1e-2       1e-3       1e-4       1e-5
Err_OEF = [ 43.5000,   50.1000,   94.3000,   19.9000,  107.0000,  106.0000,   18.4000; ...
            45.3000,   51.2000,   87.0000,   66.9000,   90.8000,  300.0000,   52.9000; ...
            45.0000,   50.3000,   94.7000,   44.6000,   38.3000,   57.1000,   79.7000; ...
            46.4000,   48.8000,   73.2000,   77.4000,   40.9000,   44.1000,   57.1000; ...
            47.3000,   51.1000,   79.2000,   57.3000,   50.7000,   41.4000,   43.2000 ];
       
% P(R2')     1e1        1e0        1e-1       1e-2       1e-3       1e-4       1e-5
Err_DBV = [  6.1100,    5.2500,    2.9400,    1.0100,    2.2200,    5.3400,    1.1500; ...
             9.6100,    8.5000,    4.7400,    4.2700,    2.0100,    2.5400,    1.8700; ...
            10.7000,    9.6100,   10.5000,   19.3000,   19.2000,   10.3000,   12.2000; ...
            47.8000,   17.2000,   13.4000,   35.0000,   34.9000,   35.4000,   29.3000; ...
            50     ,   50     ,   50     ,   50     ,   50     ,   50     ,   50      ];
         
% P(R2')     1e1        1e0        1e-1       1e-2       1e-3       1e-4       1e-5
Err_R2p = [  6.9800,    6.3400,    3.7500,    1.5500,    1.4400,    5.9700,    1.8100; ...
             6.9900,    6.3500,    3.3800,    2.7100,    1.6400,   17.8000,   12.6000; ...
             6.9900,    6.3900,    3.3500,    3.1400,    5.6100,   13.7000,   39.3000; ...
             6.9900,    6.4100,    3.4400,    2.0700,    2.7500,    3.0300,   15.2000; ...
             7.0100,    6.6400,    5.2300,    5.0300,    2.9100,    9.0700,   21.0000 ];
        
%% Plotting FABBER prior comparisons

% % Plot R2p data as a function of prec(R2p)
% figure; box on;
% semilogx(PrecR2p,Err_R2p(1,:));
% hold on;
% semilogx(PrecR2p,Err_R2p(2,:));
% semilogx(PrecR2p,Err_R2p(3,:));
% semilogx(PrecR2p,Err_R2p(4,:));
% semilogx(PrecR2p,Err_R2p(5,:));
% axis([6e-6,2e1,0,30]);
% ylabel('R2'' Error (%)');
% xlabel('Precision (R2'')');
% legend('Prec(DBV) = 100','Prec(DBV) = 10','Prec(DBV) = 1','Prec(DBV) = 0.1','Prec(DBV) = 0.01',...
%        'Location','NorthEast');
% 
% % Plot DBV data as a function of prec(R2p)
% figure; box on;
% semilogx(PrecR2p,Err_DBV(1,:));
% hold on;
% semilogx(PrecR2p,Err_DBV(2,:));
% semilogx(PrecR2p,Err_DBV(3,:));
% semilogx(PrecR2p,Err_DBV(4,:));
% semilogx(PrecR2p,Err_DBV(5,:));
% axis([6e-6,2e1,0,50]);
% ylabel('DBV Error (%)');
% xlabel('Precision (R2'')');
% legend('Prec(DBV) = 100','Prec(DBV) = 10','Prec(DBV) = 1','Prec(DBV) = 0.1','Prec(DBV) = 0.01',...
%        'Location','NorthWest');
% 
% % Plot OEF data as a function of prec(R2p)
% figure; box on;
% semilogx(PrecR2p,Err_OEF(1,:));
% hold on;
% semilogx(PrecR2p,Err_OEF(2,:));
% semilogx(PrecR2p,Err_OEF(3,:));
% semilogx(PrecR2p,Err_OEF(4,:));
% semilogx(PrecR2p,Err_OEF(5,:));
% axis([6e-6,2e1,0,200]);
% ylabel('OEF Error (%)');
% xlabel('Precision (R2'')');
% legend('Prec(DBV) = 100','Prec(DBV) = 10','Prec(DBV) = 1','Prec(DBV) = 0.1','Prec(DBV) = 0.01',...
%        'Location','NorthEast');
   
% % Plot R2p data as a function of prec(DBV)
% figure; box on;
% semilogx(PrecDBV,Err_R2p(:,3));
% hold on;
% semilogx(PrecDBV,Err_R2p(:,4));
% semilogx(PrecDBV,Err_R2p(:,5));
% semilogx(PrecDBV,Err_R2p(:,6));
% semilogx(PrecDBV,Err_R2p(:,7));
% axis([6e-3,2e2,0,40]);
% ylabel('R2'' Error (%)');
% xlabel('Precision (DBV)');
% legend('Prec(R2p) = 10^-^1','Prec(R2p) = 10^-^2','Prec(R2p) = 10^-^3','Prec(R2p) = 10^-^4','Prec(R2p) = 10^-^5',...
%        'Location','NorthEast');
%    
% % Plot DBV data as a function of prec(DBV)
% figure; box on;
% semilogx(PrecDBV(1:4),Err_DBV(1:4,3));
% hold on;
% semilogx(PrecDBV(1:4),Err_DBV(1:4,4));
% semilogx(PrecDBV(1:4),Err_DBV(1:4,5));
% semilogx(PrecDBV(1:4),Err_DBV(1:4,6));
% semilogx(PrecDBV(1:4),Err_DBV(1:4,7));
% axis([6e-3,2e2,0,40]);
% ylabel('DBV Error (%)');
% xlabel('Precision (DBV)');
% legend('Prec(R2p) = 10^-^1','Prec(R2p) = 10^-^2','Prec(R2p) = 10^-^3','Prec(R2p) = 10^-^4','Prec(R2p) = 10^-^5',...
%        'Location','NorthEast');
%    
% % Plot OEF data as a function of prec(DBV)
% figure; box on;
% semilogx(PrecDBV,Err_OEF(:,3));
% hold on;
% semilogx(PrecDBV,Err_OEF(:,4));
% semilogx(PrecDBV,Err_OEF(:,5));
% semilogx(PrecDBV,Err_OEF(:,6));
% semilogx(PrecDBV,Err_OEF(:,7));
% axis([6e-3,2e2,0,200]);
% ylabel('OEF Error (%)');
% xlabel('Precision (DBV)');
% legend('Prec(R2p) = 10^-^1','Prec(R2p) = 10^-^2','Prec(R2p) = 10^-^3','Prec(R2p) = 10^-^4','Prec(R2p) = 10^-^5',...
%        'Location','NorthWest');
   
   
%% Plotting SNR comparisons
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
