% xModelPrecComparisons.m

% Comparing Fabber Model Fit results with different precisions. Derived from
% xModelComparison.m (31 Jan 2018)

% MT Cherukara
% 6 December 2018

% Actively used as of 2019-01-31


clear;
close all;

setFigureDefaults;



%% Data for comparisons of R2'-model prior precisions (2C Model, 2C Data)

PrecR2p = [ 1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 1e-1, 1e0, 1e1 ];
PrecDBV = [ 1e-3, 1e-2, 1e-1, 1e0 , 1e1 , 1e2 ];

% P(R2')     1e-6       1e-5       1e-4       1e-3       1e-2       1e-1       1e0        1e1 
Err_OEF = [ 13.4000,   13.6000,   13.7000,   13.4000,   13.8000,   14.6000,   16.0000,   19.6000; ...
            13.9000,   14.0000,   13.8000,   13.3000,   13.8000,   14.6000,   16.1000,   19.6000; ...
            13.6000,   13.6000,   13.7000,   13.4000,   13.7000,   14.6000,   16.0000,   19.6000; ...
            13.4000,   13.4000,   13.5000,   13.6000,   13.7000,   14.6000,   15.9000,   19.7000; ...
            13.4000,   13.4000,   13.3000,   13.5000,   13.6000,   14.3000,   16.1000,   19.7000; ...
            13.6000,   13.6000,   13.6000,   13.6000,   13.6000,   13.9000,   22.3000,   33.1000 ];
       
% P(R2')     1e-6       1e-5       1e-4       1e-3       1e-2       1e-1       1e0        1e1 
Err_DBV = [  0.7400,    0.7500,    0.8800,    0.7500,    0.9900,    1.8200,    3.8200,    7.2500; ...
             0.7700,    1.0800,    0.9200,    0.7100,    0.9500,    1.8700,    3.9800,    7.2500; ...
             0.8400,    0.8300,    0.7300,    0.7100,    0.9400,    1.9500,    3.9500,    7.5000; ...
             0.7400,    0.7400,    0.7600,    0.7600,    0.8500,    1.6600,    3.5200,    8.1100; ...
             0.7400,    0.7400,    0.7400,    0.7400,    0.7900,    1.3100,    5.1800,    5.9100; ...
             0.7600,    0.7600,    0.7600,    0.7500,    0.7600,    1.2600,    8.6800,   16.8100 ];
         
% P(R2')     1e-6       1e-5       1e-4       1e-3       1e-2       1e-1       1e0        1e1 
Err_R2p = [  2.3500,    2.7000,    2.5100,    2.2200,    2.2100,    2.0800,    5.9700,    7.7700; ...
             2.3700,    2.4000,    2.4300,    2.1900,    2.2000,    2.0800,    5.9700,    7.7700; ...
             2.2000,    2.2000,    2.2000,    2.1800,    2.2000,    2.0900,    5.9700,    7.7800; ...
             2.1900,    2.1900,    2.1800,    2.1800,    2.1900,    2.0900,    5.9800,    7.7900; ...
             2.1900,    2.1800,    2.1900,    2.1900,    2.1900,    2.0100,    6.0000,    7.7900; ...
             2.1800,    2.1800,    2.1800,    2.1800,    2.1800,    1.9400,    6.5000,    8.0300 ];
        
% Relative Error summed across all variables
% P(R2')    1e-5       1e-4       1e-3       1e-2       1e-1       1e0        1e1 
Rel_All = [  ];
        
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

       
        
%% Plotting FABBER prior comparisons (R2p)

VarR2p = 1./PrecR2p;

% Plot R2p data as a function of prec(R2p)
figure; box on;
semilogx(VarR2p,Err_R2p(1,:));
hold on;
semilogx(VarR2p,Err_R2p(2,:));
semilogx(VarR2p,Err_R2p(3,:));
semilogx(VarR2p,Err_R2p(4,:));
semilogx(VarR2p,Err_R2p(5,:));
semilogx(VarR2p,Err_R2p(6,:));
axis([6e-2,2e6,1,8.5]);
ylabel('R''_2 Error (s^-^1)');
xlabel('Standard Devation  \sigma(R''_2)');
xticks([1e0,1e2,1e4,1e6]);
xticklabels({'1', '10', '100', '1000'});
% legend('\phi_0(DBV) = 10^-^5','\phi_0(DBV) = 10^-^4','\phi_0(DBV) = 10^-^3',...
%        '\phi_0(DBV) = 10^-^2','\phi_0(DBV) = 10^-^1','\phi_0(DBV) = 10^0',...
%        'Location','NorthWest');
   
% Plot DBV data as a function of prec(R2p)
Err_DBV(Err_DBV > 20) = 20;

figure; box on;
semilogx(VarR2p,Err_DBV(1,:));
hold on;
semilogx(VarR2p,Err_DBV(2,:));
semilogx(VarR2p,Err_DBV(3,:));
semilogx(VarR2p,Err_DBV(4,:));
semilogx(VarR2p,Err_DBV(5,:));
semilogx(VarR2p,Err_DBV(6,:));
axis([6e-2,2e6,0,12.5]);
ylabel('_ DBV Error (%)^ ');
xlabel('Standard Devation  \sigma(R''_2)');
xticks([1e0,1e2,1e4,1e6]);
xticklabels({'1', '10', '100', '1000'});
% legend('\sigma_0(DBV) = 10^5^/^2','\sigma_0(DBV) =^ 100',...
%        '\sigma_0(DBV) = 10^3^/^2','\sigma_0(DBV) =^ 10' ,...
%        '\sigma_0(DBV) = 10^1^/^2','\sigma_0(DBV) =^ 1'  ,...
%        'Location','North');

% Plot OEF data as a function of prec(R2p)
figure; box on;
semilogx(VarR2p,Err_OEF(1,:));
hold on;
semilogx(VarR2p,Err_OEF(2,:));
semilogx(VarR2p,Err_OEF(3,:));
semilogx(VarR2p,Err_OEF(4,:));
semilogx(VarR2p,Err_OEF(5,:));
semilogx(VarR2p,Err_OEF(6,:));
axis([6e-2,2e6,10,37]);
ylabel('_ OEF Error (%)^ ');
xlabel('Standard Devation  \sigma(R''_2)');
xticks([1e0,1e2,1e4,1e6]);
xticklabels({'1', '10', '100', '1000'});
legend('\sigma_0(DBV) = 10^5^/^2','\sigma_0(DBV) =^ 100',...
       '\sigma_0(DBV) = 10^3^/^2','\sigma_0(DBV) =^ 10' ,...
       '\sigma_0(DBV) = 10^1^/^2','\sigma_0(DBV) =^ 1'  ,...
       'Location','North');
%    
% % Plot Total Relative Error as a function of prec(R2p)
% figure; box on;
% semilogx(PrecR2p,Rel_All(1,:));
% hold on;
% semilogx(PrecR2p,Rel_All(2,:));
% semilogx(PrecR2p,Rel_All(3,:));
% semilogx(PrecR2p,Rel_All(4,:));
% semilogx(PrecR2p,Rel_All(5,:));
% semilogx(PrecR2p,Rel_All(6,:));
% axis([6e-6,2e1,0,500]);
% ylabel('Total Relative Error (%)');
% xlabel('Precision (R2'')');
% legend('\phi(DBV) = 10^-^5','\phi(DBV) = 10^-^4','\phi(DBV) = 10^-^3',...
%        '\phi(DBV) = 10^-^2','\phi(DBV) = 10^-^1','\phi(DBV) = 10^0',...
%        'Location','NorthEast');
   
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
 