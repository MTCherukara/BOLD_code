% xModelPrecComparisons.m

% Comparing Fabber Model Fit results with different precisions. Derived from
% xModelComparison.m (31 Jan 2018)

% MT Cherukara
% 6 December 2018

% Actively used as of 2019-01-31


clear;
close all;

setFigureDefaults;


%% Data for comparisons of OEF-model prior precisions (1C Model, 1C Data)

% PrecOEF = [ 1e-5, 1e-4, 1e-3, 1e-2 , 1e-1, 1e0];
% PrecDBV = [ 1e0 , 1e-1 , 1e-2 , 1e-3, 1e-4 ];
% 
% % P(OEF)      1e-3       1e-2       1e-1       1e0        1e1        1e2
% Err_OEF = [ 100.0000,    8.8000,   45.4000,    3.9900,    3.2000,    4.6600; ...
%             100.0000,    8.8000,    4.4000,    3.4600,    3.0200,    5.4500; ...
%             100.0000,    8.8000,    4.1100,    3.1800,    3.2500,    6.4000; ...
%             100.0000,    8.8000,    3.8900,    3.1200,    3.4200,    6.7400; ...
%             100.0000,    8.8000,    3.8400,    3.1100,    3.4500,    6.7900 ];
%         
% % P(OEF)      1e-3       1e-2       1e-1       1e0        1e1        1e2
% Err_DBV = [   3.9700,    3.1200,    2.0400,    0.5600,    0.4700,    0.7000; ...
%             100.0000,    4.1000,    0.5500,    0.4700,    0.4400,    0.8300; ...
%             100.0000,    4.1000,    0.5100,    0.4400,    0.4700,    1.0100; ...
%             100.0000,    4.1000,    0.4800,    0.4400,    0.4900,    1.0700; ...
%             100.0000,    4.1000,    0.4700,    0.4400,    0.4900,    1.0800 ];

%% Data for comparisons of R2'-model prior precisions (1C Model, 1C Data)

PrecR2p = [ 1e-5, 1e-4, 1e-3, 1e-2, 1e-1, 1e0, 1e1 ];
PrecDBV = [ 1e-3, 1e-2, 1e-1, 1e0, 1e1, 1e2];

% P(R2')     1e-5       1e-4       1e-3       1e-2       1e-1       1e0        1e1 
Err_OEF = [ 28.4000,   24.7000,   22.0000,   21.9000,   56.1000,   56.0000,   52.9000; ...
            45.9000,   18.4000,   23.8000,   28.8000,   47.5000,   50.2000,   40.9000; ...
            68.7000,   21.8000,   20.6000,   17.7000,   39.7000,   39.2000,   37.2000; ...
            24.9000,   20.8000,  100.0000,   44.0000,   61.8000,   45.0000,   41.2000; ...
            43.8000,   37.4000,   25.8000,   25.1000,   32.5000,   41.7000,   39.2000; ...
            62.1000,   20.4000,  100.0000,   54.0000,   65.9000,   32.7000,   37.1000 ];
       
% P(R2')     1e-5       1e-4       1e-3       1e-2       1e-1       1e0        1e1 
Err_DBV = [  9.4200,    3.7000,   37.4000,  100.0000,  100.0000,  100.0000,  100.0000; ...
           100.0000,    3.2700,    2.6700,   32.1000,  100.0000,  100.0000,  100.0000; ...
             4.2500,    1.3300,    1.5700,    4.3400,   15.2000,   32.2000,   49.5000; ...
             1.7900,    2.1900,    2.7200,    2.3100,    5.9400,   13.4000,   11.4000; ...
           100.0000,    1.4600,    1.5700,    1.5400,    3.6400,    6.6300,    5.8400; ...
           100.0000,    1.6700,    2.4900,    1.9400,    2.6500,    2.3300,    3.0800 ];
         
% P(R2')     1e-5       1e-4       1e-3       1e-2       1e-1       1e0        1e1 
Err_R2p = [  5.3000,    2.0200,    2.9800,    2.2100,    4.6600,    7.0800,    7.6600; ...
             6.6100,    2.0400,    2.3900,    1.9300,    3.3600,    6.0600,    6.9400; ...
             2.6800,    2.1800,    1.7700,    2.0900,    3.5500,    6.3700,    7.3400; ...
             8.7200,    5.7900,    1.9700,    3.1100,    4.7000,    7.2900,    8.1900; ...
            41.3000,    3.4400,    2.4400,    1.7300,    3.3800,    7.3000,    7.9200; ...
            13.2000,    2.1900,    1.7600,    2.1400,    3.2600,    7.1400,    8.1000 ];
        
% Relative Error summed across all variables
% P(R2')    1e-5       1e-4       1e-3       1e-2       1e-1       1e0        1e1 
Rel_All = [ 210.9000,  114.5000,  293.4000,  500.0000,  500.0000,  500.0000,  500.0000; ...
            500.0000,   93.0000,  101.6000,  500.0000,  500.0000,  500.0000,  500.0000; ...
            204.3000,   81.0000,   81.5000,  126.7000,  240.5000,  500.0000,  500.0000; ...
            153.1000,  118.3000,  302.0000,  140.3000,  233.3000,  305.2000,  382.0000; ...
            500.0000,  119.3000,   96.4000,   85.6000,  136.2000,  226.5000,  312.6000; ...
            500.0000,   78.5000,  226.0000,  139.7000,  208.1000,  159.4000,  283.7000 ];
        
%% Correlation Comparison (1C R2p model)
% P(R2')     1e-5       1e-4       1e-3       1e-2       1e-1       1e0        1e1 
Corr_OEF = [ 0.1930,    0.0440,    0.1830,    0.3550,    0.1070,    0     ,    0     ; ...
             0.1350,    0.2890,    0.1150,    0.3370,    0.0760,    0     ,    0     ; ...
             0.3580,    0.4730,    0.4900,    0.2740,    0.1380,    0     ,    0     ; ...
             0.5710,    0.6290,    0.3090,    0.2820,    0.1010,    0     ,    0     ; ...
             0     ,    0.3330,    0.5420,    0.3510,    0.1000,    0     ,    0     ; ...
             0.2470,    0.8030,    0.2670,    0.2310,    0     ,    0     ,    0      ];

% P(R2')     1e-5       1e-4       1e-3       1e-2       1e-1       1e0        1e1 
Corr_DBV = [ 0.5360,    0.4500,    0.0410,    0.1250,    0.0600,    0     ,    0.0780; ...
             0     ,    0.5230,    0.5960,         0,    0.0760,    0     ,    0     ; ...
             0.3990,    0.8520,    0.6280,    0.5040,    0.2290,    0     ,    0     ; ...
             0.7110,    0.2290,    0.5640,    0.7380,    0.4240,    0.7740,    0.7690; ...
             0     ,    0.8310,    0.8450,    0.8900,    0.5090,    0.5930,    0.6180; ...
             0     ,    0.7820,    0.6010,    0.7960,    0.6750,    0.7380,    0.6070 ];

% P(R2')     1e-5       1e-4       1e-3       1e-2       1e-1       1e0        1e1 
Corr_R2p = [ 0.7140,    0.9100,    0.6600,    0.7830,    0.3620,    0.0800,    0     ; ...
             0.5920,    0.9240,    0.7360,    0.8570,    0.5540,    0.1270,    0.1440; ...
             0.8020,    0.8670,    0.9240,    0.8350,    0.4800,    0.1560,    0.0890; ...
             0.5550,    0.3690,    0.9270,    0.6840,    0.5400,    0     ,    0     ; ...
             0     ,    0.6980,    0.8890,    0.9230,    0.6060,    0     ,    0     ; ...
             0.0510,    0.8600,    0.9450,    0.8420,    0.7250,    0.0960,    0.0740 ];

        
%% Data for comparisons of R2' prior precisions (2C Model) - OLD

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
        
        
%% Plotting FABBER prior comparisons (R2p)

% Plot R2p data as a function of prec(R2p)
figure; box on;
semilogx(PrecR2p,Err_R2p(1,:));
hold on;
semilogx(PrecR2p,Err_R2p(2,:));
semilogx(PrecR2p,Err_R2p(3,:));
semilogx(PrecR2p,Err_R2p(4,:));
semilogx(PrecR2p,Err_R2p(5,:));
semilogx(PrecR2p,Err_R2p(6,:));
axis([6e-6,2e1,0,20]);
ylabel('R2'' Error (s^-^1)');
xlabel('Precision (R2'')');
legend('\phi(DBV) = 10^-^5','\phi(DBV) = 10^-^4','\phi(DBV) = 10^-^3',...
       '\phi(DBV) = 10^-^2','\phi(DBV) = 10^-^1','\phi(DBV) = 10^0',...
       'Location','NorthEast');

% Plot DBV data as a function of prec(R2p)
Err_DBV(Err_DBV > 20) = 20;

figure; box on;
semilogx(PrecR2p,Err_DBV(1,:));
hold on;
semilogx(PrecR2p,Err_DBV(2,:));
semilogx(PrecR2p,Err_DBV(3,:));
semilogx(PrecR2p,Err_DBV(4,:));
semilogx(PrecR2p,Err_DBV(5,:));
semilogx(PrecR2p,Err_DBV(6,:));
axis([6e-6,2e1,0,15]);
ylabel('DBV Error (%)');
xlabel('Precision (R2'')');
legend('\phi(DBV) = 10^-^5','\phi(DBV) = 10^-^4','\phi(DBV) = 10^-^3',...
       '\phi(DBV) = 10^-^2','\phi(DBV) = 10^-^1','\phi(DBV) = 10^0',...
       'Location','NorthEast');

% Plot OEF data as a function of prec(R2p)
figure; box on;
semilogx(PrecR2p,Err_OEF(1,:));
hold on;
semilogx(PrecR2p,Err_OEF(2,:));
semilogx(PrecR2p,Err_OEF(3,:));
semilogx(PrecR2p,Err_OEF(4,:));
semilogx(PrecR2p,Err_OEF(5,:));
semilogx(PrecR2p,Err_OEF(6,:));
axis([6e-6,2e1,0,100]);
ylabel('OEF Error (%)');
xlabel('Precision (R2'')');
legend('\phi(DBV) = 10^-^5','\phi(DBV) = 10^-^4','\phi(DBV) = 10^-^3',...
       '\phi(DBV) = 10^-^2','\phi(DBV) = 10^-^1','\phi(DBV) = 10^0',...
       'Location','NorthEast');
   
% Plot Total Relative Error as a function of prec(R2p)
figure; box on;
semilogx(PrecR2p,Rel_All(1,:));
hold on;
semilogx(PrecR2p,Rel_All(2,:));
semilogx(PrecR2p,Rel_All(3,:));
semilogx(PrecR2p,Rel_All(4,:));
semilogx(PrecR2p,Rel_All(5,:));
semilogx(PrecR2p,Rel_All(6,:));
axis([6e-6,2e1,0,500]);
ylabel('Total Relative Error (%)');
xlabel('Precision (R2'')');
legend('\phi(DBV) = 10^-^5','\phi(DBV) = 10^-^4','\phi(DBV) = 10^-^3',...
       '\phi(DBV) = 10^-^2','\phi(DBV) = 10^-^1','\phi(DBV) = 10^0',...
       'Location','NorthEast');
   
%% Plot Correlations

% % Plot R2p Correlation as a function of prec(R2p)
% figure; box on;
% semilogx(PrecR2p,Corr_R2p(1,:));
% hold on;
% semilogx(PrecR2p,Corr_R2p(2,:));
% semilogx(PrecR2p,Corr_R2p(3,:));
% semilogx(PrecR2p,Corr_R2p(4,:));
% semilogx(PrecR2p,Corr_R2p(5,:));
% semilogx(PrecR2p,Corr_R2p(6,:));
% axis([6e-6,2e1,0,1]);
% ylabel('R2'' Correlation');
% xlabel('Precision (R2'')');
% legend('\phi(DBV) = 10^-^5','\phi(DBV) = 10^-^4','\phi(DBV) = 10^-^3',...
%        '\phi(DBV) = 10^-^2','\phi(DBV) = 10^-^1','\phi(DBV) = 10^0',...
%        'Location','NorthEast');
%    
% % Plot DBV Correlation as a function of prec(R2p)
% figure; box on;
% semilogx(PrecR2p,Corr_DBV(1,:));
% hold on;
% semilogx(PrecR2p,Corr_DBV(2,:));
% semilogx(PrecR2p,Corr_DBV(3,:));
% semilogx(PrecR2p,Corr_DBV(4,:));
% semilogx(PrecR2p,Corr_DBV(5,:));
% semilogx(PrecR2p,Corr_DBV(6,:));
% axis([6e-6,2e1,0,1]);
% ylabel('DBV Correlation');
% xlabel('Precision (R2'')');
% legend('\phi(DBV) = 10^-^5','\phi(DBV) = 10^-^4','\phi(DBV) = 10^-^3',...
%        '\phi(DBV) = 10^-^2','\phi(DBV) = 10^-^1','\phi(DBV) = 10^0',...
%        'Location','NorthEast');
%    
% % Plot OEF Correlation as a function of prec(R2p)
% figure; box on;
% semilogx(PrecR2p,Corr_OEF(1,:));
% hold on;
% semilogx(PrecR2p,Corr_OEF(2,:));
% semilogx(PrecR2p,Corr_OEF(3,:));
% semilogx(PrecR2p,Corr_OEF(4,:));
% semilogx(PrecR2p,Corr_OEF(5,:));
% semilogx(PrecR2p,Corr_OEF(6,:));
% axis([6e-6,2e1,0,1]);
% ylabel('OEF Correlation');
% xlabel('Precision (R2'')');
% legend('\phi(DBV) = 10^-^5','\phi(DBV) = 10^-^4','\phi(DBV) = 10^-^3',...
%        '\phi(DBV) = 10^-^2','\phi(DBV) = 10^-^1','\phi(DBV) = 10^0',...
%        'Location','NorthEast');
 
%% PREC(DBV)
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
% legend('\phi(R2p) = 10^-^1','\phi(R2p) = 10^-^2','\phi(R2p) = 10^-^3','\phi(R2p) = 10^-^4','\phi(R2p) = 10^-^5',...
%        'Location','NorthEast');
%    
% % Plot DBV data as a function of prec(DBV)
% figure; box on;
% semilogx(PrecDBV(:),Err_DBV(:,2));
% hold on;
% semilogx(PrecDBV(:),Err_DBV(:,3));
% semilogx(PrecDBV(:),Err_DBV(:,4));
% semilogx(PrecDBV(:),Err_DBV(:,5));
% semilogx(PrecDBV(:),Err_DBV(:,6));
% axis([6e-5,2e0,0,4.2]);
% ylabel('DBV Error (%)');
% xlabel('Precision (DBV)');
% legend('\phi(OEF) = 10^-^4','\phi(OEF) = 10^-^3','\phi(OEF) = 10^-^2',...
%        '\phi(OEF) = 10^-^1','\phi(OEF) = 10^0',...
%        'Location','West');
%    
% % Plot OEF data as a function of prec(DBV)
% figure; box on;
% semilogx(PrecDBV,Err_OEF(:,2));
% hold on;
% semilogx(PrecDBV(:),Err_OEF(:,3));
% semilogx(PrecDBV,Err_OEF(:,4));
% semilogx(PrecDBV,Err_OEF(:,5));
% semilogx(PrecDBV,Err_OEF(:,6));
% axis([6e-5,2e0,0,8.9]);
% ylabel('OEF Error (%)');
% xlabel('Precision (DBV)');
% legend('\phi(OEF) = 10^-^4','\phi(OEF) = 10^-^3','\phi(OEF) = 10^-^2',...
%        '\phi(OEF) = 10^-^1','\phi(OEF) = 10^0',...
%        'Location','SouthWest');
   
   
