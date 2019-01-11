% xModelComparisons.m

% Comparing the qBOLD models using various comparison methods

% MT Cherukara
% 6 December 2018

% Actively used as of 2019-01-10


clear;
close all;

setFigureDefaults;

% Data Row names
rnames = {'Linear Model'      ; ...
          'Linear (2C) Model' ; ...
          '1C Model'          ; ...
          '2C Model'          ; ...
          '1C Model'          ; ...
          '2C Model'           };

% Select the rows we want to plot
plotrows = [1,5,6];


%% Data for Comparisons across SNR levels
% Data for 1C model
SNR  = [  5    ,  10    ,  25    , 50     , 100    , 200     , 500     ];

% SNR         5          10         25         50         100        200        500
Err_OEF = [  45.5000,  100.0000,  100.0000,   75.6000,  100.0000,   26.9000,   17.0000; ...
             45.5000,  100.0000,  100.0000,   54.6000,   32.8000,   22.3000,   15.6000; ...
             71.3000,   69.3000,   51.3000,   41.7000,   36.6000,   34.0000,   34.0000; ...
             79.5000,   66.4000,   46.3000,   34.4000,   28.1000,   26.0000,   25.6000; ...
            100.0000,   81.2000,   52.4000,   41.7000,   35.5000,   32.4000,   32.3000; ...
            100.0000,   70.8000,   46.7000,   32.7000,   25.3000,   22.6000,   21.9000 ];
       
% SNR         5          10         25         50         100        200        500
Err_DBV = [  24.1000,    8.4300,    3.7300,    2.1100,    1.1600,    0.7500,    0.5800; ...
             24.1000,    8.6200,    3.6900,    2.0100,    1.1000,    0.6400,    0.4100; ...
              9.8500,    7.1000,    6.5200,    9.0000,   10.3000,   11.4000,   12.1000; ...
              9.5200,    6.8400,    6.4800,    7.8000,    9.4300,    9.0800,    9.3200; ...
              8.0300,    6.2000,    4.6900,    4.6800,    4.3600,    4.2600,    4.8800; ...
              9.1900,    6.6800,    4.5600,    3.7200,    3.7000,    3.2800,    2.9500 ];
         
% SNR         5          10         25         50         100        200        500
Err_R2p = [   8.8900,    3.0000,    1.9700,    1.8300,    1.7900,    1.7900,    1.7800; ...
              8.8700,    3.0800,    2.1600,    1.9800,    1.9500,    1.9400,    1.9500; ...
              4.1000,    3.2200,    2.9300,    2.7800,    2.7900,    2.7000,    2.7200; ...
              3.9000,    3.1200,    3.2700,    3.1700,    3.1600,    3.0900,    3.1900; ...
              3.5000,    2.2800,    1.9300,    1.9100,    1.9000,    1.8600,    1.9300; ...
              3.7300,    2.3300,    2.1200,    2.1400,    2.1900,    2.1800,    2.1500 ];



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

% Pull out the rows we want
npr = length(plotrows);
rlabels = rnames(plotrows);


% Plot R2p Error
figure; box on; 
semilogx(SNR,Err_R2p(plotrows,:));
hold on;
ylabel('R2'' Error (%)');
xlabel('SNR');
legend(rlabels{:});
xlim([0,500]);
ylim([0, 10]);
xticks(SNR);

% Plot DBV Error
figure; box on;
semilogx(SNR,Err_DBV(plotrows,:));
hold on;
ylabel('DBV Error (%)');
xlabel('SNR');
legend(rlabels{:});
xlim([0,500]);
ylim([0, 30]);
xticks(SNR);

% Plot OEF Error
figure; box on;
semilogx(SNR,Err_OEF(plotrows,:));
hold on;
ylabel('OEF Error (%)');
xlabel('SNR');
legend(rlabels{:});
xlim([0,500]);
ylim([0,100]);
xticks(SNR);