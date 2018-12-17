% xModelComparisons.m

% Comparing the qBOLD models using various comparison methods

% MT Cherukara
% 6 December 2018

clear;
% close all;

setFigureDefaults;


%% Data for Comparisons across SNR levels
% Data for 1C model
SNR  = [  5    ,  10    ,  25    , 50     , 100    , 200     , 500     ];

% SNR         5          10         25         50         100        200        500
Err_OEF = [ 100.0000,  100.0000,  100.0000,  100.0000,  100.0000,  100.0000,  100.0000; ...
            100.0000,  100.0000,   75.2000,   62.0000,   55.2000,   52.3000,   52.4000; ...
            100.0000,  100.0000,   70.4000,   53.9000,   44.6000,   42.1000,   43.2000 ];
       
% SNR         5          10         25         50         100        200        500
Err_DBV = [ 100.0000,   11.3000,    4.7500,    2.6800,    1.4700,    0.9700,    0.7600; ...
             13.3000,    9.8400,   13.3000,   21.1000,   23.0000,   25.6000,   26.9000; ...
             12.7000,    8.8900,   15.2000,   19.9000,   24.4000,   23.6000,   23.7000 ];
         
% SNR         5          10         25         50         100        200        500
Err_R2p = [  12.9000,    4.0200,    2.5200,    2.2600,    2.1900,    2.1800,    2.1700; ...
              5.5900,    5.0300,    4.8800,    4.6500,    4.6500,    4.5600,    4.5700; ...
              5.5400,    5.0100,    5.6700,    5.5200,    5.4500,    5.3500,    5.5700 ];



%% Data for comparisons of FABBER prior precisions (1C Model)

% PrecR2p = [     1e1,       1e0,       1e-1,      1e-2,      1e-3,      1e-4,      1e-5 ];
% PrecDBV = [ 1e2, 1e1, 1e0, 1e-1, 1e-2];
% 
% % P(R2')     1e1        1e0        1e-1       1e-2       1e-3       1e-4       1e-5
% Err_OEF = [ 39.7000,   45.9000,   92.3000,   46.1000,  100.0000,  100.0000,  100.0000; ...
%             41.9000,   47.6000,   88.2000,  100.0000,   80.8000,  100.0000,   78.9000; ...
%             42.1000,   47.5000,   88.9000,   50.2000,   44.9000,   60.7000,  100.0000; ...
%             42.3000,   45.3000,   76.7000,  100.0000,   36.5000,   33.5000,   58.8000; ...
%             42.6000,   47.0000,   84.0000,   55.7000,   45.5000,   47.0000,   34.3000 ];
%        
% % P(R2')     1e1        1e0        1e-1       1e-2       1e-3       1e-4       1e-5
% Err_DBV = [  5.6600,    4.9800,    5.0600,    2.6400,    4.1700,    6.2600,    3.0200; ...
%             10.5000,    9.5300,    5.3000,    5.3500,    2.2000,    3.7000,    3.1700; ...
%             11.7000,   10.9000,   10.8000,   24.2000,   22.4000,   23.0000,    7.9700; ...
%             44.5000,   15.7000,   12.4000,   42.0000,   59.7000,   55.1000,   42.7000; ...
%            100.0000,  100.0000,  100.0000,  100.0000,  100.0000,  100.0000,  100.0000 ];
%          
% % P(R2')     1e1        1e0        1e-1       1e-2       1e-3       1e-4       1e-5
% Err_R2p = [ 10.5000,    9.9400,    7.1900,    1.8900,   10.4000,    8.1500,    9.8000; ...
%             10.5000,    9.9000,    6.3300,    3.2700,    2.3700,   30.1000,   14.1000; ...
%             10.5000,    9.9500,    6.4200,    4.5400,    4.7300,   19.2000,   54.3000; ...
%             10.5000,    9.9600,    6.5000,    2.8100,    4.5300,    3.5000,   13.6000; ...
%             10.5000,   10.2000,    9.0300,    8.7500,    5.4900,   11.2000,   32.1000 ];
        
        
%% Data for comparisons of FABBER prior precisions (2C Model)

% PrecR2p = [     1e1,       1e0,       1e-1,      1e-2,      1e-3,      1e-4,      1e-5 ];
% PrecDBV = [ 1e2, 1e1, 1e0, 1e-1, 1e-2];
% 
% % P(R2')     1e1        1e0        1e-1       1e-2       1e-3       1e-4       1e-5
% Err_OEF = [ 38.5000,   45.7000,  100.0000,  100.0000,  100.0000,  100.0000,  100.0000; ...
%             41.0000,   47.0000,  100.0000,  100.0000,  100.0000,  100.0000,  100.0000; ...
%             41.1000,   48.9000,  100.0000,   43.2000,   96.0000,   30.0000,   87.1000; ...
%             41.9000,   46.5000,   94.1000,   47.2000,   32.7000,   79.4000,   72.6000; ...
%             40.7000,   44.6000,  100.0000,   50.9000,   45.6000,   40.6000,   40.0000 ];
%        
% % P(R2')     1e1        1e0        1e-1       1e-2       1e-3       1e-4       1e-5
% Err_DBV = [  4.0200,    3.4000,    5.8100,    3.7000,    3.7300,    3.9100,  100.0000; ...
%              7.8200,    7.5300,    6.4600,    5.5700,    7.0900,    4.4700,  100.0000; ...
%             10.3000,   10.9000,   14.6000,   23.7000,   21.0000,   16.0000,  100.0000; ...
%              8.3000,   36.6000,   19.2000,   89.4000,  100.0000,   69.1000,   94.5000; ...
%            100.0000,  100.0000,  100.0000,  100.0000,  100.0000,  100.0000,  100.0000 ];
%          
% % P(R2')     1e1        1e0        1e-1       1e-2       1e-3       1e-4       1e-5
% Err_R2p = [ 10.5000,    9.8200,    5.1100,    1.8000,    5.3100,    6.6000,  120.0000; ...
%             10.5000,    9.8600,    5.1000,    5.4100,    9.9100,   32.6000,  100.0000; ...
%             10.5000,    9.9100,    4.7600,    5.5700,    9.9600,   13.9000,  107.0000; ...
%             10.5000,    9.8700,    5.3500,    4.9000,    7.0100,   44.5000,   82.0000; ...
%             10.5000,    9.9100,    5.7900,    6.5500,   12.9000,   18.3000,  140.0000 ];
        
        
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
% axis([6e-6,2e1,0,100]);
% ylabel('DBV Error (%)');
% xlabel('Precision (R2'')');
% legend('Prec(DBV) = 100','Prec(DBV) = 10','Prec(DBV) = 1','Prec(DBV) = 0.1','Prec(DBV) = 0.01',...
%        'Location','NorthEast');
% 
% % Plot OEF data as a function of prec(R2p)
% figure; box on;
% semilogx(PrecR2p,Err_OEF(1,:));
% hold on;
% semilogx(PrecR2p,Err_OEF(2,:));
% semilogx(PrecR2p,Err_OEF(3,:));
% semilogx(PrecR2p,Err_OEF(4,:));
% semilogx(PrecR2p,Err_OEF(5,:));
% axis([6e-6,2e1,0,100]);
% ylabel('OEF Error (%)');
% xlabel('Precision (R2'')');
% legend('Prec(DBV) = 100','Prec(DBV) = 10','Prec(DBV) = 1','Prec(DBV) = 0.1','Prec(DBV) = 0.01',...
%        'Location','SouthEast');
   
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
% Plot R2p Error
figure; box on;
semilogx(SNR,Err_R2p(1,:));
hold on;
semilogx(SNR,Err_R2p(2,:));
semilogx(SNR,Err_R2p(3,:));
ylabel('R2'' Error (%)');
xlabel('SNR');
legend('Linear Model','1C Model','2C Model');
xlim([0,500]);
ylim([0, 15]);
xticks(SNR);

% Plot DBV Error
figure; box on;
semilogx(SNR,Err_DBV(1,:));
hold on;
semilogx(SNR,Err_DBV(2,:));
semilogx(SNR,Err_DBV(3,:));
ylabel('DBV Error (%)');
xlabel('SNR');
legend('Linear Model','1C Model','2C Model');
xlim([0,500]);
ylim([0,100]);
xticks(SNR);

% Plot OEF Error
figure; box on;
semilogx(SNR,Err_OEF(1,:));
hold on;
semilogx(SNR,Err_OEF(2,:));
semilogx(SNR,Err_OEF(3,:));
ylabel('OEF Error (%)');
xlabel('SNR');
legend('Linear Model','1C Model','2C Model');
xlim([0,500]);
ylim([0,100]);
xticks(SNR);