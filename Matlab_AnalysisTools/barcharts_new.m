% Bar Charts New
%
% Actively used as of 2018-06-27
%
% Using FABBER data generated on 27 June 2018

clear;
close all;
setFigureDefaults;

%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    DATA             % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    
    
%       LinMean    1C.Mean    2C.Mean    LinMed.    1C.Med.    2C.Med.
R2p = [ 3.6990,    3.3100,    3.3340,    3.2070,    2.8650,    2.8930; ...
        4.4520,    3.5820,    3.6110,    3.5710,    2.8600,    2.7350; ...
        3.2880,    3.0880,    3.1230,    2.4420,    2.2510,    2.8130; ...
        3.9420,    3.6300,    3.5680,    3.1000,    2.9600,    2.7680; ...
        3.8940,    3.6660,    3.5440,    3.1050,    3.0110,    3.0730; ...
        3.9810,    3.7490,    3.7760,    3.2680,    3.1020,    3.0130; ...
        3.2530,    2.6680,    2.6630,    2.5230,    2.0580,    2.0660 ];
   
%       LinMean    1C.Mean    2C.Mean    LinMed.    1C.Med.    2C.Med.
DBV = [ 7.4340,    6.0100,    5.6200,    4.6970,    2.9830,    3.3390; ...
       10.8600,    6.1940,    6.4160,    7.2200,    3.4900,    2.6370; ...
        6.1640,    5.4580,    5.7120,    3.9680,    2.6050,    4.0480; ...
        9.1070,    6.8030,    6.8010,    6.2070,    5.3070,    4.3510; ...
        8.8460,    8.3790,    7.2450,    6.3160,    6.4340,    5.8700; ...
        8.4170,    6.2680,    6.1670,    4.9670,    3.6870,    2.9430; ...
        7.0820,    5.6470,    5.4470,    4.4080,    3.2350,    3.2680 ];

%       LinMean    1C.Mean    2C.Mean    LinMed.    1C.Med.    2C.Med.
OEF = [ 24.7900,   35.0800,   33.4500,   20.5400,   22.3500,   22.1100; ...
        17.8900,   31.2000,   34.1900,   15.2100,   16.8300,   19.7600; ...
        21.4900,   29.0000,   32.0500,   17.9200,   20.5900,   18.2800; ...
        19.4800,   24.5300,   28.1700,   16.2100,   15.5500,   16.6600; ...
        19.3600,   19.6500,   25.6800,   15.6300,   14.6300,   16.6400; ...
        24.1400,   31.2400,   33.2100,   19.8500,   19.7800,   20.7300; ...
        20.7000,   24.0100,   23.5500,   16.9000,   17.8800,   18.4500 ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    ERRORS           % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

     
%        LinStd     1C.Std     2C.Std     LinIQR     1C.IQR     2C.IQR
eR2p = [ 0.6150,    0.8150,    0.7780,    3.1270,    2.9130,    3.0310; ...
         0.6940,    0.8240,    0.8880,    4.6670,    3.5790,    3.5260; ...
         0.4610,    0.7900,    0.7100,    3.1700,    3.0720,    2.8460; ...
         0.5750,    0.6670,    0.7510,    3.6160,    3.5860,    3.6400; ...
         0.6100,    0.7350,    0.8160,    3.8240,    3.7460,    3.3220; ...
         0.6630,    0.7240,    0.7130,    3.8500,    3.5410,    3.6580; ...
         0.5960,    0.7830,    0.7000,    2.7020,    2.6140,    2.5530 ];

%        LinStd     1C.Std     2C.Std     LinIQR     1C.IQR     2C.IQR
eDBV = [ 4.0850,    7.0170,    4.8510,    6.2350,    6.3850,    6.4960; ...
         6.8450,    5.3830,    5.5210,   11.5800,    8.5440,    8.6480; ...
         3.3690,    5.5550,    4.9660,    5.7070,    5.8120,    7.7400; ...
         4.5820,    4.9880,    5.2890,    7.6840,    8.7040,    9.1310; ...
         6.0460,    4.1630,    5.0540,    9.0180,    9.8290,    8.6540; ...
         5.2610,    5.4050,    4.5420,    7.4250,    7.8070,    7.8000; ...
         5.6860,    5.7290,    4.6090,    6.0390,    5.5150,    5.3630 ];

%        LinStd     1C.Std     2C.Std     LinIQR     1C.IQR     2C.IQR
eOEF = [ 15.2400,   24.4300,   22.6500,   21.3800,   46.8200,   38.0800; ...
         10.8400,   23.2900,   26.1900,   14.5900,   43.0800,   49.8100; ...
         13.4300,   23.7700,   22.3300,   18.3700,   31.5200,   39.5700; ...
         10.4600,   18.1200,   22.3000,   14.9100,   17.2100,   31.3600; ...
         11.2300,   12.2500,   17.2700,   13.7100,   13.9600,   16.5900; ...
         13.0800,   21.1800,   22.8500,   22.3900,   33.3000,   41.0700; ...
         13.7600,   18.9000,   18.8400,   18.4000,   23.0500,   21.1400 ];
     
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    FREE ENERGY        % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% NEGATIVE
%       LinMean    1C.Mean    2C.Mean    LinMed.    1C.Med.    2C.Med.
FE = [  87.4000,  118.3000,  113.9000,   87.4000,  118.3000,  113.9000; ...
       123.8000,  165.2000,  170.1000,  123.8000,  165.2000,  170.1000; ...
        72.4000,  101.9000,  127.0000,   72.4000,  101.9000,  127.0000; ...
       100.8000,  134.9000,  139.7000,  100.8000,  134.9000,  139.7000; ...
       109.1000,  148.8000,  120.6000,  109.1000,  148.8000,  120.6000; ...
        82.7000,  137.1000,  135.2000,   82.7000,  137.1000,  135.2000; ...
       115.9000,  138.6000,  135.6000,  115.9000,  138.6000,  135.6000 ];
     
%       LinMean    1C.Mean     2C.Mean    LinMed.    1C.Med.    2C.Med.
RR = [  11.9400,    7.7700,    6.6400,    1.5300,    1.8600,    1.7800; ...
        12.3000,    6.7700,    6.2300,    2.2900,    2.4200,    2.4200; ...
         7.8300,    8.5300,    7.8600,    1.2000,    1.6800,    2.0000; ...
         9.7400,    6.8000,    6.7000,    1.6100,    2.0000,    2.0200; ...
        11.4100,    6.8400,    6.2600,    1.9700,    2.3700,    1.8700; ...
        11.6200,    7.4800,    6.6900,    1.5300,    2.1200,    2.0900; ...
        12.2900,   10.3900,    8.0600,    2.0300,    2.2600,    2.2000 ];



%% Calculations  

rebase = 0;

% rebase
if rebase
    eR2p = eR2p./repmat(R2p(:,2),1,4);
    eDBV = eDBV./repmat(DBV(:,2),1,4);
    eOEF = eOEF./repmat(OEF(:,2),1,4);

    R2p = R2p./repmat(R2p(:,2),1,4);
    DBV = DBV./repmat(DBV(:,2),1,4);
    OEF = OEF./repmat(OEF(:,2),1,4);
end
     
% averages   
aR2p = mean(R2p);
sR2p = std(R2p);
aDBV = mean(DBV);
sDBV = std(DBV);
aOEF = mean(OEF);
sOEF = std(OEF);
aFE  = mean(FE);
sFE  = std(FE);
aRR  = mean(RR);
sRR  = std(RR);

% % Calculate OEF error by adding R2' and DBV errors in quadrature
% eOEF = OEF.*sqrt(((eR2p./R2p).^2) + ((eDBV./DBV).^2));


%% Plotting Information
ndat = size(R2p,1); % number of datapoints
dpts = [1,2,3];
legtext = {'L. Model','1C. Model','2C. Model','L. Model','1C. Model','2C. Model'};
npts = length(dpts);
lbls = legtext(dpts);


%% Bar Chart Plotting

% Plot R2p
figure(1); hold on; box on;
bar(1:npts,aR2p(dpts),0.6,'FaceColor',defColour(1));
errorbar(1:npts,aR2p(dpts),sR2p(dpts),'k.','LineWidth',2,'MarkerSize',1);
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+0.5,0,5.6]);
end
ylabel('R_2'' (s^-^1)');
xticks(1:length(dpts));
xticklabels(lbls); 

% Plot DBV
figure(2); hold on; box on;
bar(1:npts,aDBV(dpts),0.6,'FaceColor',defColour(1));
errorbar(1:npts,aDBV(dpts),sDBV(dpts),'k.','LineWidth',2,'MarkerSize',1);
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+0.5,0,12.8]);
end
ylabel('DBV (%)');
xticks(1:length(dpts));
xticklabels(lbls);

% Plot OEF
figure(3); hold on; box on;
bar(1:npts,aOEF(dpts),0.6,'FaceColor',defColour(1));
errorbar(1:npts,aOEF(dpts),sOEF(dpts),'k.','LineWidth',2,'MarkerSize',1);
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+0.5,0,43]);
end
ylabel('OEF (%)');
xticks(1:length(dpts));
xticklabels(lbls);

% Plot Free Energy
figure(4); hold on; box on;
bar(1:npts,aFE(dpts),0.6,'FaceColor',defColour(1));
errorbar(1:npts,aFE(dpts),sFE(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis([0.5,length(dpts)+0.5,0,200]);
ylabel('-Free Energy');
xticks(1:length(dpts));
xticklabels(lbls);

% Plot Residuals
figure(5); hold on; box on;
bar(1:npts,aRR(dpts),0.6,'FaceColor',defColour(1));
errorbar(1:npts,aRR(dpts),sRR(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis([0.5,length(dpts)+0.5,0,15]);
ylabel('Residuals');
xticks(1:length(dpts));
xticklabels(lbls);

%% Statistics

% R2p ANOVA
[~,~,stat_R2p] = anova2(R2p(:,dpts),1,'off');
c_R = multcompare(stat_R2p,'display','off');

% DBV ANOVA
[~,~,stat_DBV] = anova2(DBV(:,dpts),1,'off');
c_D = multcompare(stat_DBV,'display','off');

% OEF ANOVA
[~,~,stat_OEF] = anova2(OEF(:,dpts),1,'off');
c_O = multcompare(stat_OEF,'display','off');


% Pick the comparisons we want (out of the sets we selected with dpts)
grps = {[1,2],[1,3],[2,3]};


% Pull out p-values
p_R = MC_pvalues(c_R,grps);
p_D = MC_pvalues(c_D,grps);
p_O = MC_pvalues(c_O,grps);


% Plot R2p significance stars
figure(1);
HR = sigstar(grps,p_R,1);
set(HR,'Color','k')
set(HR(:,2),'FontSize',16);
% set(HR(:,2),'String','^n^.^s^.')

% Plot DBV significance stars
figure(2);
HD = sigstar(grps,p_D,1);
set(HD,'Color','k')
set(HD(:,2),'FontSize',16);
% set(HD(:,2),'String','^n^.^s^.')

% Plot OEF significance stars
figure(3);
HO = sigstar(grps,p_O,1);
set(HO,'Color','k')
set(HO(:,2),'FontSize',16);
% set(HO(3,2),'String','^n^.^s^.')


