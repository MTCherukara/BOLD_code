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
% % %    MEAN DATA        % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%       LongT.0C   14T.1C     14T.2C     LongT.2C 
R2p = [ 3.3910,    3.3770,    3.3140,    3.6450; ...
        4.0680,    3.9700,    3.8150,    4.5230; ...
        3.2260,    3.3050,    3.2560,    3.4240; ...
        3.6000,    3.9530,    3.7930,    4.0350; ...
        3.3550,    3.6940,    3.5680,    3.6770; ...
        3.6870,    3.9060,    3.7800,    3.9650; ...
        2.9560,    2.8840,    2.9150,    3.2500 ];
   
%       LongT.0C   14T.1C     14T.2C     LongT.2C 
DBV = [ 5.2610,    6.0800,    5.7470,    6.5960; ...
        7.5720,    7.2200,    6.6090,   10.9700; ...
        5.6020,    5.9270,    5.9050,    7.0330; ...
        6.4200,    8.4690,    7.7150,    9.0180; ...
        6.1520,    8.4840,    8.3220,    8.6580; ...
        6.4620,    7.2280,    6.9130,    8.1850; ...
        5.7650,    6.1630,    5.6400,    7.2790 ];

%       LongT.0C   14T.1C     14T.2C     LongT.2C 
OEF = [ 25.1400   29.6900   34.3000   24.2200
        20.0700   25.3400   34.4700   18.2000
        22.1800   25.1800   28.2300   21.2800
        20.8000   21.4600   27.1000   18.9100
        20.7400   19.2000   20.0800   18.8300
        23.6800   26.5500   29.0800   22.6500
        20.7200   22.4500   22.5600   20.5300 ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    STANDARD DEVIATIONS          % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%        LongT.0C   14T.1C     14T.2C     LongT.2C 
eR2p = [ 0.3830,    0.7220,    0.7750,    0.6760; ...
         0.6250,    0.8490,    0.8530,    0.8270; ...
         0.3910,    0.7230,    0.8170,    0.5630; ...
         0.5260,    0.7720,    0.8010,    0.7040; ...
         0.4300,    0.8250,    0.8330,    0.6170; ...
         0.3890,    0.7450,    0.8470,    0.6090; ...
         0.4370,    0.8070,    0.7660,    0.6140 ];

%        LongT.0C   14T.1C     14T.2C     LongT.2C 
eDBV = [ 2.5400,    5.5940,    5.5970,    4.7660; ...
         4.0320,    4.9320,    5.1210,    5.7050; ...
         2.6520,    4.8930,    5.5530,    4.2080; ...
         3.3770,    5.0400,    5.6640,    5.1100; ...
         2.9630,    5.1000,    4.8260,    4.3420; ...
         2.5900,    4.6780,    5.4980,    4.8100; ...
         3.0410,    5.3530,    4.8410,    4.6050 ];

%        LongT.0C   14T.1C     14T.2C     LongT.2C 
eOEF = [ 17.4100,   20.1700,   24.1800,   16.4100; ...
         14.2700,   18.5400,   26.2700,   11.7800; ...
         15.0500,   19.9900,   24.3000,   13.3200; ...
         14.5300,   14.3600,   20.7900,   11.7700; ...
         13.4600,   12.1800,   13.3300,   11.2300; ...
         14.2900,   17.6200,   20.4700,   13.3400; ...
         15.3800,   18.1800,   18.5600,   14.2900 ];

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    FREE ENERGY        % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% NEGATIVE
%       LongT.0C   14T.1C     14T.2C      LongT.2C 
FE =  [ 64.3000,   119.3000,  120.7000,   63.8000; ...
        92.4000,   164.7000,  166.4000,   88.0000; ...
        62.7000,   102.4000,  110.4000,   61.3000; ...
        79.2000,   144.5000,  152.4000,   73.6000; ...
        68.3000,   166.1000,  166.4000,   63.5000; ...
        61.0000,   141.8000,  114.5000,   58.9000; ...
        68.6000,   167.2000,  155.4000,   68.8000 ];



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

% % Calculate OEF error by adding R2' and DBV errors in quadrature
% eOEF = OEF.*sqrt(((eR2p./R2p).^2) + ((eDBV./DBV).^2));


%% Plotting Information
ndat = size(R2p,1); % number of datapoints
dpts = [1,2,3];
legtext = {'L. Model','1C. Model','2C. Model','2C Linear'};
npts = length(dpts);
lbls = legtext(dpts);


%% Bar Chart Plotting

% Plot R2p
figure(1); hold on; box on;
BR = bar(1:npts,aR2p(dpts),0.6);
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
bar(1:npts,aDBV(dpts),0.6);
errorbar(1:npts,aDBV(dpts),sDBV(dpts),'k.','LineWidth',2,'MarkerSize',1);
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+0.5,0,11.8]);
end
ylabel('DBV (%)');
xticks(1:length(dpts));
xticklabels(lbls);

% Plot OEF
figure(3); hold on; box on;
bar(1:npts,aOEF(dpts),0.6);
errorbar(1:npts,aOEF(dpts),sOEF(dpts),'k.','LineWidth',2,'MarkerSize',1);
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+0.5,0,48]);
end
ylabel('OEF (%)');
xticks(1:length(dpts));
xticklabels(lbls);

% % Plot Free Energy
% figure(4); hold on; box on;
% bar(1:npts,aFE(dpts),0.6);
% errorbar(1:npts,aFE(dpts),sFE(dpts),'k.','LineWidth',2,'MarkerSize',1);
% axis([0.5,length(dpts)+0.5,0,200]);
% ylabel('-Free Energy');
% xticks(1:length(dpts));
% xticklabels(lbls);


%% Statistics

% R2p ANOVA
[~,~,stat_R2p] = anova2(R2p,1,'off');
c_R = multcompare(stat_R2p,'display','off');

% DBV ANOVA
[~,~,stat_DBV] = anova2(DBV,1,'off');
c_D = multcompare(stat_DBV,'display','off');

% OEF ANOVA
[~,~,stat_OEF] = anova2(OEF,1,'off');
c_O = multcompare(stat_OEF,'display','off');


% Pick the comparisons we want 
grps = {[1,2];[1,3];[2,3]};%;[2,3];[2,4];[2,5]};
p_R = c_R([1,2,4],6);
p_D = c_D([1,2,4],6);
p_O = c_O([1,2,4],6);

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


