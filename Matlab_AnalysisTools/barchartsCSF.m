% barchartsCSF.m
%
% Actively used as of 2018-07-31

clear;
close all;
setFigureDefaults;

%% Plotting Information

% Key to data array columns
legtext = {'FP','NF','T_1 seg.','T_2 seg.','T_2 biexp.','FP','NF','T_1 seg.','T_2 seg.','T_2 biexp.'};

% Choose which columns to plot
dpts = [1,2,3,4,5];

% Pick the comparisons we want from DPTS values
grps = {[1,2];[1,3];[1,4];[1,5]};

% Decide on additional plots
plot_FE = 0;    % Free Energy
plot_RR = 0;    % Median Residuals
plot_SN = 0;    % Model Signal-to-Noise Ratio

%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    MEAN DATA        % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%       FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f     FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f 
R2p = [ 2.9050,    3.5750,    3.5510,    3.1490,    3.4730,    2.4880,    2.8480,    3.1170,    2.7230,    3.0310; ...
        3.3330,    4.5170,    4.2250,    3.4360,    4.1040,    2.7600,    3.5190,    3.6900,    2.8290,    3.5780; ...
        2.3050,    3.1500,    3.1160,    2.5570,    2.9640,    1.8100,    2.4480,    2.7980,    2.1690,    2.6060; ...
        2.1370,    2.6460,    2.7430,    2.5350,    2.5490,    1.8960,    2.1720,    2.2870,    2.0980,    2.1270; ...
        3.0500,    3.4940,    3.3480,    2.5460,    3.1420,    2.0550,    2.6270,    2.6970,    2.0270,    2.5440 ];
    
%       FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f     FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f 
DBV = [ 4.7300,    8.3960,    6.2220,    5.8000,    6.1280,    3.6430,    5.7720,    5.8130,    5.2860,    5.7310; ...
        5.7570,   10.5500,    7.0790,    6.2250,    6.9610,    4.3850,    7.6630,    6.2940,    5.1460,    6.1840; ...
        4.4600,    7.9050,    5.9710,    5.3060,    5.7760,    3.3830,    4.9330,    5.3600,    4.6250,    5.1320; ...
        3.8010,    5.3170,    5.1750,    4.9080,    4.8870,    2.6140,    4.4090,    4.6700,    4.3630,    4.3500; ...
        4.2610,    7.4870,    6.2560,    5.3360,    6.0410,    2.5490,    5.6640,    5.7180,    4.6230,    5.4360 ];

%       FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f     FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f 
OEF = [ 26.5100,   21.0700,   22.6800,   21.9100,   22.6400,   19.4300,   15.8900,   17.1300,   16.2900,   17.2000; ...
        25.8700,   19.5800,   23.2500,   21.5700,   22.9500,   16.9900,   14.5000,   17.4300,   15.1500,   17.0800; ...
        23.4400,   19.0900,   20.1500,   19.0200,   19.8700,   16.2100,   14.9100,   16.5400,   15.2200,   16.3900; ...
        29.1400,   19.1100,   19.5700,   19.0600,   19.1900,   19.5800,   16.1100,   16.5600,   15.9200,   16.2000; ...
        25.8800,   18.2200,   19.3400,   18.1700,   19.0800,   20.1200,   14.8300,   15.6400,   13.5900,   15.2500 ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    STANDARD DEVIATIONS        % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%        FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f     FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f 
eR2p = [ 0.7100,    1.3560,    0.7180,    0.8210,    0.7370,    3.1740,    3.7460,    3.6700,    3.3680,    3.6510; ...
         0.7370,    1.5850,    0.9230,    1.1780,    0.9450,    3.4450,    5.2150,    4.8050,    3.8110,    4.5410; ...
         0.7270,    1.3870,    0.6740,    0.8540,    0.7170,    2.5860,    3.3410,    3.4450,    3.0460,    3.3420; ...
         0.6780,    1.0970,    0.4910,    0.5560,    0.5710,    2.1030,    2.7030,    2.8360,    2.6630,    2.6830; ...
         0.8730,    1.1960,    0.6890,    0.9540,    0.7530,    3.3230,    3.6250,    3.5710,    2.8210,    3.3580 ];

%        FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f     FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f 
eDBV = [ 5.0630,    5.6980,    3.1690,    3.1530,    3.1590,    6.7170,    8.6670,    7.1410,    6.8050,    7.0050; ...
         4.9320,    7.1030,    3.9910,    3.9760,    3.9580,    7.6250,   12.2200,    8.2930,    7.4160,    8.1960; ...
         4.8850,    4.9650,    3.0250,    3.0280,    3.0120,    5.9010,    7.6380,    6.9760,    6.3200,    6.8070; ...
         4.9260,    3.5510,    2.2820,    2.2900,    2.3400,    5.0490,    5.5650,    5.5970,    5.3540,    5.3450; ...
         5.5970,    4.6180,    3.1310,    3.1550,    3.1210,    5.5220,    7.7060,    6.7980,    6.0860,    6.5970 ];

%        FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f     FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f 
eOEF = [ 24.6500,   16.8000,   15.6800,   16.7700,   15.8200,   27.3000,   20.4300,   22.3100,   22.4500,   22.4600; ...
         20.6700,   16.1500,   18.4100,   20.6400,   18.4800,   26.6900,   20.0200,   26.8900,   27.1200,   26.4900; ...
         24.4400,   16.5500,   14.5700,   16.2600,   15.0300,   24.0300,   18.6000,   19.6200,   20.1400,   19.6500; ...
         27.3000,   15.4800,   12.2700,   12.6800,   13.3500,   36.7800,   17.5800,   17.7500,   17.8600,   17.9400; ...
         28.8600,   15.0700,   13.5100,   16.8700,   14.0000,   28.5500,   17.0300,   19.2900,   18.7800,   19.4100 ];

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    RESIDUALS        % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%       FLAIR-U   NF-U       NF-T1w     NF-T2w     NF-T2f 
% FE =  [ 4.3800,    9.5300,    7.7800,    7.8700,    7.7800; ...
%         3.8200,   12.4000,   11.1300,   11.3000,   11.0800; ...
%         4.3200,   10.8100,    8.1800,    8.7600,    8.2000; ...
%         3.2300,    6.1400,    5.1800,    5.4400,    5.4300; ...
%         3.1100,    7.0000,    6.3300,    6.7500,    6.4300 ];

% %       FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f     FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f 
% RR =  [ -0.9010,   -1.5470,   -1.1730,   -1.1600,   -1.1520,   -0.3670,   -0.5610,   -0.4360,   -0.4290,   -0.3880; ...
%         -1.0360,   -2.0140,   -1.7900,   -1.5260,   -1.7730,   -0.3330,   -0.5130,   -0.5070,   -0.3890,   -0.4990; ...
%         -0.9620,   -2.6130,   -1.8570,   -1.8910,   -1.8720,   -0.4460,   -0.8820,   -0.6260,   -0.6440,   -0.6340; ...
%         -0.2720,   -1.0090,   -0.8280,   -0.7900,   -0.7760,   -0.2210,   -0.3160,   -0.2880,   -0.2790,   -0.2640; ...
%         -0.5400,   -1.0860,   -0.6300,   -0.7050,   -0.5740,   -0.2380,   -0.4090,   -0.1900,   -0.2580,   -0.1850 ];
% 
% %       FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f     FLAIR-U    NF-U       NF-T1w     NF-T2w     NF-T2f 
% SN =  [ 37.2000,   54.6000,   59.1000,   59.2000,   59.2000,   37.2000,   54.6000,   59.1000,   59.2000,   59.2000; ...
%         38.5000,   38.3000,   38.9000,   38.4000,   38.9000,   38.5000,   38.3000,   38.9000,   38.4000,   38.9000; ...
%         37.2000,   52.5000,   57.5000,   56.1000,   57.3000,   37.2000,   52.5000,   57.5000,   56.1000,   57.3000; ...
%         47.8000,   76.7000,   82.2000,   81.3000,   80.2000,   47.8000,   76.7000,   82.2000,   81.3000,   80.2000; ...
%         34.2000,   55.0000,   58.0000,   55.5000,   57.3000,   34.2000,   55.0000,   58.0000,   55.5000,   57.3000 ];

%% Calculations  

rebase = 0;

ndat = size(R2p,2); % number of datapoints

% rebase
if rebase
    eR2p = eR2p./repmat(R2p(:,dpts(1)),1,ndat);
    eDBV = eDBV./repmat(DBV(:,dpts(1)),1,ndat);
    eOEF = eOEF./repmat(OEF(:,dpts(1)),1,ndat);
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
% aFE  = mean(FE);
% sFE  = std(FE);
aRR  = mean(RR);
sRR  = std(RR);
aSN  = mean(SN);
sSN  = std(SN);


%% Bar Chart Plotting

npts = length(dpts);
lbls = legtext(dpts);

% Custom colours
T1col = [0.000, 0.608, 0.698];
T2col = [0.412, 0.569, 0.231];
BEcol = [0.514, 0.118, 0.157];
NFcol = [207, 122, 48]./256;

% Plot R2p
figure(); hold on; box on;
bar(1:npts,aR2p(dpts),0.75,'FaceColor',defColour(1));
errorbar(1:npts,aR2p(dpts),sR2p(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis([0.5,npts+0.5,0,5.6]);
ylabel('R_2'' (s^-^1)');
xticks(1:npts);
xticklabels(lbls);

% Plot DBV
figure(2); hold on; box on;
bar(1:npts,aDBV(dpts),0.75,'FaceColor',defColour(1));
errorbar(1:npts,aDBV(dpts),sDBV(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis([0.5,npts+0.5,0,12.8]);
ylabel('DBV (%)');
xticks(1:npts);
xticklabels(lbls);

% Plot OEF
figure(3); hold on; box on;
bar(1:npts,aOEF(dpts),0.75,'FaceColor',defColour(1));
errorbar(1:npts,aOEF(dpts),sOEF(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis([0.5,npts+0.5,0,43]);
ylabel('OEF (%)');
xticks(1:npts);
xticklabels(lbls);

%% Extra Plots

% Plot Free Energy
if plot_FE
    figure(); hold on; box on;
    bar(1:npts,aFE(dpts),0.6,'FaceColor',defColour(1));
    errorbar(1:npts,aFE(dpts),sFE(dpts),'k.','LineWidth',2,'MarkerSize',1);
    axis([0.5,length(dpts)+0.5,0,200]);
    ylabel('-Free Energy');
    xticks(1:length(dpts));
    xticklabels(lbls);
end

% Plot Median Residual
if plot_RR
    figure(); hold on; box on;
    bar(1:npts,aRR(dpts),0.6,'FaceColor',defColour(1));
    errorbar(1:npts,aRR(dpts),sRR(dpts),'k.','LineWidth',2,'MarkerSize',1);
    axis([0.5,length(dpts)+0.5,-1.25,0.25]);
    ylabel('Median Residual');
    xticks(1:length(dpts));
    xticklabels(lbls);
end

% Plot Model SNR
if plot_SN
    figure(); hold on; box on;
    bar(1:npts,aSN(dpts),0.6,'FaceColor',defColour(1));
    errorbar(1:npts,aSN(dpts),sSN(dpts),'k.','LineWidth',2,'MarkerSize',1);
    axis([0.5,length(dpts)+0.5,0,85]);
    ylabel('Model SNR');
    xticks(1:length(dpts));
    xticklabels(lbls);
end

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

% Pull out p-values
p_R = MC_pvalues(c_R,grps);
p_D = MC_pvalues(c_D,grps);
p_O = MC_pvalues(c_O,grps);

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


