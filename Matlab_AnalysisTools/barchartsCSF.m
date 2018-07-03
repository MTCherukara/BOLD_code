% barchartsCSF.m
%
% Actively used as of 2018-05-25

clear;
close all;
setFigureDefaults;

%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    MEAN DATA        % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%       FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f 
R2p = [ 2.9050,    3.5750,    3.5510,    3.1490,    3.4730; ...
        3.3330,    4.5170,    4.2250,    3.4360,    4.1040; ...
        2.3050,    3.1500,    3.1160,    2.5570,    2.9640; ...
        2.1370,    2.6460,    2.7430,    2.5350,    2.5490; ...
        3.0500,    3.4940,    3.3480,    2.5460,    3.1420 ];
    
%       FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f 
DBV = [ 4.7300,    8.3960,    6.2220,    5.8000,    6.1280; ...
        5.7570,   10.5500,    7.0790,    6.2250,    6.9610; ...
        4.4600,    7.9050,    5.9710,    5.3060,    5.7760; ...
        3.8010,    5.3170,    5.1750,    4.9080,    4.8870; ...
        4.2610,    7.4870,    6.2560,    5.3360,    6.0410  ];

%       FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f 
OEF = [ 26.5100,   21.0700,   22.6800,   21.9100,   22.6400; ...
        25.8700,   19.5800,   23.2500,   21.5700,   22.9500; ...
        23.4400,   19.0900,   20.1500,   19.0200,   19.8700; ...
        29.1400,   19.1100,   19.5700,   19.0600,   19.1900; ...
        25.8800,   18.2200,   19.3400,   18.1700,   19.0800  ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    STANDARD DEVIATIONS        % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%        FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f 
eR2p = [ 0.7100,    1.3560,    0.7180,    0.8210,    0.7370; ...
         0.7370,    1.5850,    0.9230,    1.1780,    0.9450; ...
         0.7270,    1.3870,    0.6740,    0.8540,    0.7170; ...
         0.6780,    1.0970,    0.4910,    0.5560,    0.5710; ...
         0.8730,    1.1960,    0.6890,    0.9540,    0.7530 ];
      
%        FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f 
eDBV = [ 5.0630,    5.6980,    3.1690,    3.1530,    3.1590; ...
         4.9320,    7.1030,    3.9910,    3.9760,    3.9580; ...
         4.8850,    4.9650,    3.0250,    3.0280,    3.0120; ...
         4.9260,    3.5510,    2.2820,    2.2900,    2.3400; ...
         5.5970,    4.6180,    3.1310,    3.1550,    3.1210 ];

%        FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f 
eOEF = [ 24.6500,   16.8000,   15.6800,   16.7700,   15.8200; ...
         20.6700,   16.1500,   18.4100,   20.6400,   18.4800; ...
         24.4400,   16.5500,   14.5700,   16.2600,   15.0300; ...
         27.3000,   15.4800,   12.2700,   12.6800,   13.3500; ...
         28.8600,   15.0700,   13.5100,   16.8700,   14.0000 ];

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    RESIDUALS        % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%       FLAIR-U   NF-U       NF-T1w     NF-T2w     NF-T2f 
FE =  [ 4.3800,    9.5300,    7.7800,    7.8700,    7.7800; ...
        3.8200,   12.4000,   11.1300,   11.3000,   11.0800; ...
        4.3200,   10.8100,    8.1800,    8.7600,    8.2000; ...
        3.2300,    6.1400,    5.1800,    5.4400,    5.4300; ...
        3.1100,    7.0000,    6.3300,    6.7500,    6.4300 ];



%% Calculations  

rebase = 0;

ndat = size(R2p,1); % number of datapoints

% rebase
if rebase
    eR2p = eR2p./repmat(R2p(:,1),1,ndat);
    eDBV = eDBV./repmat(DBV(:,1),1,ndat);
    R2p = R2p./repmat(R2p(:,1),1,ndat);
    DBV = DBV./repmat(DBV(:,1),1,ndat);
    OEF = OEF./repmat(OEF(:,1),1,ndat);
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



%% Plotting Information
dpts = [1,2,4];
legtext = {'FLAIR','R_2'' fit','T_1 seg.','T_2 seg.','T_2 biexp.'};
npts = repmat((1:length(dpts))',1,ndat);
ndps = length(dpts);
lbls = legtext(dpts);


%% Bar Chart Plotting

T1col = [0.000, 0.608, 0.698];
T2col = [0.412, 0.569, 0.231];
BEcol = [0.514, 0.118, 0.157];
NFcol = [207, 122, 48]./256;

% Plot R2p
figure(); hold on; box on;
bar(1,aR2p(dpts(1)),0.6,'FaceColor',defColour(1));    % FLAIR
bar(2,aR2p(dpts(2)),0.6,'FaceColor',NFcol);           % non-FLAIR
bar(3,aR2p(dpts(3)),0.6,'FaceColor',T1col);           % T1 weighted
% bar(4,aR2p(dpts(4)),0.6,'FaceColor',T2col);           % T2 weighted
% bar(5,aR2p(dpts(5)),0.6,'FaceColor',BEcol);           % BE weighted
errorbar(1:ndps,aR2p(dpts),sR2p(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis([0.5,ndps+0.5,0,5.5]);
ylabel('R_2'' (s^-^1)');
xticks(1:ndps);
xticklabels(lbls);


% Plot DBV
figure(2); hold on; box on;
bar(1,aDBV(dpts(1)),0.6,'FaceColor',defColour(1));    % FLAIR
bar(2,aDBV(dpts(2)),0.6,'FaceColor',NFcol);           % non-FLAIR
bar(3,aDBV(dpts(3)),0.6,'FaceColor',T1col);           % T1 weighted
% bar(4,aDBV(dpts(4)),0.6,'FaceColor',T2col);           % T2 weighted
% bar(5,aDBV(dpts(5)),0.6,'FaceColor',BEcol);           % BE weighted
errorbar(1:ndps,aDBV(dpts),sDBV(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis([0.5,ndps+0.5,0,13.8]);
ylabel('DBV (%)');
xticks(1:ndps);
xticklabels(lbls);

% Plot OEF
figure(3); hold on; box on;
bar(1,aOEF(dpts(1)),0.6,'FaceColor',defColour(1));    % FLAIR
bar(2,aOEF(dpts(2)),0.6,'FaceColor',NFcol);           % non-FLAIR
bar(3,aOEF(dpts(3)),0.6,'FaceColor',T1col);           % T1 weighted
% bar(4,aOEF(dpts(4)),0.6,'FaceColor',T2col);           % T2 weighted
% bar(5,aOEF(dpts(5)),0.6,'FaceColor',BEcol);           % BE weighted
errorbar(1:ndps,aOEF(dpts),sOEF(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis([0.5,ndps+0.5,0,42]);
ylabel('OEF (%)');
xticks(1:ndps);
xticklabels(lbls);

% % Plot Residuals
% figure(4); hold on; box on;
% bar(1,aFE(dpts(1)),0.6,'FaceColor',defColour(1));    % FLAIR
% bar(2,aFE(dpts(2)),0.6,'FaceColor',defColour(2));    % non-FLAIR
% bar(3,aFE(dpts(3)),0.6,'FaceColor',T1col);           % T1 weighted
% bar(4,aFE(dpts(4)),0.6,'FaceColor',T2col);           % T2 weighted
% bar(5,aFE(dpts(5)),0.6,'FaceColor',BEcol);           % BE weighted
% errorbar(1:5,aFE(dpts),sFE(dpts),'k.','LineWidth',2,'MarkerSize',1);
% axis([0.5,length(dpts)+0.5,0,15]);
% ylabel('Residual');
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
grps = {[1,2];[1,3]};
p_R = c_R([1,3],6);
p_D = c_D([1,3],6);
p_O = c_O([1,3],6);

% Plot R2p significance stars
figure(1);
HR = sigstar(grps,p_R,1);
set(HR,'Color','k')
set(HR(:,2),'FontSize',16);

% Plot DBV significance stars
figure(2);
HD = sigstar(grps,p_D,1);
set(HD,'Color','k')
set(HD(:,2),'FontSize',16);

% Plot OEF significance stars
figure(3);
HO = sigstar(grps,p_O,1);
set(HO,'Color','k')
set(HO(:,2),'FontSize',16);


