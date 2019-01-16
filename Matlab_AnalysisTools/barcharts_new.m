% Bar Charts New
%
% Actively used as of 2019-01-14
%
% Using FABBER data generated on 6 November 2018 (for 2019 ISMRM Abstract)
%
% Changelog:
%
% 2019-01-16 (MTC). Switched the layout of the data matrices so that subjects go
%       along the columns, and datasets along the rows. This makes adding new
%       datasets much easier.

clear;
close all;
setFigureDefaults;

%% Plotting Information

% key to data array columns
legtext = {'Linear','1C Model','2C Simple','2C Model','2C Model','1C Model','2C Model'};
%           1        2          3           4          5          6          7

% Choose which columns to plot
dpts = [1,6,7];

% Pick pairwise comparisons from DPTS values
grps = {[1,2],[1,3],[2,3]};

% Decide on additional plots
plot_FE = 0;    % Free Energy
plot_RR = 0;    % Median Residuals
plot_SN = 0;    % Model Signal-to-Noise Ratio


%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    DATA             % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
  
%       VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
R2p = [ 3.0860,    3.5350,    2.8040,    3.3670,    2.9620,    3.3900,    2.5780; ...       % Linear
        3.3100,    3.3810,    2.8400,    3.5050,    3.3010,    3.4300,    2.5890; ...       % 1C Model
        3.2950,    3.5390,    2.9720,    3.5500,    3.2780,    3.4320,    2.5460; ...       % 2C Simple Model
        3.4860,    3.5830,    2.9720,    3.5400,    3.2370,    3.5090,    2.6230; ...       % 2C M.N. Model
        3.1820,    3.3940,    2.8820,    3.3730,    3.1100,    3.3530,    2.5570; ...       % 2C Steady State MN Model
        3.3550,    3.6160,    2.7750,    3.5340,    3.0490,    3.4480,    2.4080; ...       % 1C no abs
        3.2760,    3.4040,    2.6820,    3.3820,    2.9390,    3.3180,    2.3790 ];         % 2C no abs

%       VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
DBV = [ 4.5910,    5.8100,    4.0380,    5.0600,    5.2380,    5.2680,    4.8010; ...
        4.3750,    5.0200,    4.5280,    6.0410,    7.1930,    4.6800,    4.4730; ...
        5.2400,    5.8390,    5.1640,    6.4470,    7.3340,    5.3400,    4.6880; ...
        5.5560,    6.0650,    5.2440,    6.2770,    7.3870,    5.4000,    4.7470; ...
        5.3600,    5.4860,    5.1820,    5.9930,    6.6390,    5.3310,    4.5780; ...
        5.5180,    5.0240,    3.4130,    6.2950,    6.2300,    5.5080,    4.3190; ...
        3.7080,    4.7010,    4.6020,    4.7620,    3.1540,    3.2090,    2.4300 ];

%       VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
OEF = [ 27.1300,   24.0300,   26.3200,   24.7200,   23.1500,   26.4000,   21.2900; ...
        33.0500,   31.1200,   30.7300,   24.1000,   18.6900,   28.9300,   20.4900; ...
        31.1100,   32.5800,   25.0100,   26.8500,   21.3000,   32.2500,   21.7300; ...
        29.9200,   32.4900,   24.0700,   27.6100,   22.0900,   32.9200,   22.1800; ...
        32.3400,   33.8800,   26.4500,   28.1500,   21.9000,   33.0900,   22.1800; ...
        20.7500,   17.6500,   21.1900,   18.0300,   16.3300,   21.0500,   17.8200; ...
        20.5100,   17.7900,   20.5000,   18.2900,   16.3200,   20.6000,   17.9200 ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    ERRORS           % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

      
%        VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
eR2p = [ 1.9830,    2.8350,    2.6410,    3.1420,    2.8680,    2.8880,    2.5600; ...
         0.6570,    0.7630,    0.6280,    0.6960,    0.6620,    0.5670,    0.5390; ...
         0.6360,    0.7580,    0.6910,    0.7450,    0.7510,    0.6130,    0.5890; ...
         0.7410,    0.7220,    0.5850,    0.7250,    0.6500,    0.6470,    0.5640; ...
         0.6180,    0.6690,    0.6010,    0.5700,    0.5850,    0.6180,    0.5330; ...
         0.5970,    0.7670,    0.5530,    0.6590,    0.6710,    0.6070,    0.5930; ...
         0.5460,    0.6660,    0.4960,    0.5840,    0.6910,    0.5640,    0.5390 ];
    
%        VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
eDBV = [ 3.8470,    5.2850,    3.8310,    4.9730,    5.2610,    5.4820,    5.0990; ...
         2.8550,    3.7700,    3.6060,    3.8240,    2.8770,    2.5700,    2.6920; ...
         3.1730,    3.7240,    3.7660,    4.1770,    3.4510,    3.3090,    3.2080; ...
         3.6700,    3.2900,    3.1590,    3.9890,    3.0580,    3.1980,    2.7260; ...
         3.4450,    3.2060,    3.3570,    3.1600,    2.6520,    3.4260,    2.7920; ...
         2.1780,    2.7660,    1.9200,    2.2020,    2.2690,    2.2180,    2.0720; ...
         2.1260,    2.4430,    1.8200,    1.9630,    2.2450,    2.0530,    2.0700 ];

%        VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
eOEF = [ 19.0700,   16.5000,   19.6700,   16.7200,   17.4400,   18.8600,   16.8600; ...
         20.0100,   22.3400,   21.4500,   15.3000,   10.9900,   19.1000,   15.2900; ...
         19.0800,   23.1800,   17.4400,   17.6300,   12.2000,   21.3700,   16.7000; ...
         18.2500,   22.7900,   16.5700,   18.7800,   13.3900,   21.2800,   16.6800; ...
         19.4700,   24.2100,   18.3500,   18.2800,   12.6300,   21.2200,   16.3100; ...
          9.3400,    8.0200,    9.9800,    7.4300,    6.0900,    9.6000,    9.5500; ...
          9.2400,    8.2500,    9.1700,    7.3600,    6.0500,    9.1600,    9.4200 ];

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    FREE ENERGY        % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% NEGATIVE
%      LinMean   
FE = [  ];
     
%      LinMean   
RR = [  ];
   
%      LinMean    
SN = [  ];


%% Calculations  

ndat = size(R2p,1);

% REBASE = 1 will normalize each data array to the first column (removing the
% effect of intersubject variability) in order to make comparison solely on the
% models themselves
rebase = 0;

if rebase
    eR2p = eR2p./repmat(R2p(dpts(1),:),1,ndat);
    eDBV = eDBV./repmat(DBV(dpts(1),:),1,ndat);
    eOEF = eOEF./repmat(OEF(dpts(1),:),1,ndat);

    R2p = R2p./repmat(R2p(dpts(1),:),1,ndat);
    DBV = DBV./repmat(DBV(dpts(1),:),1,ndat);
    OEF = OEF./repmat(OEF(dpts(1),:),1,ndat);
end
     
% averages   
aR2p = mean(R2p,2);
sR2p = std(R2p,0,2);
aDBV = mean(DBV,2);
sDBV = std(DBV,0,2);
aOEF = mean(OEF,2);
sOEF = std(OEF,0,2);
aFE  = mean(FE,2);
sFE  = std(FE,0,2);
aRR  = mean(RR,2);
sRR  = std(RR,0,2);
aSN  = mean(SN,2);
sSN  = std(SN,0,2);


%% Bar Chart Plotting

% pull out labels
lbls = legtext(dpts);

% number of bars
npts = length(dpts);

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
    axis([0.5,npts+0.5,0,8.8]);
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
    axis([0.5,length(dpts)+0.5,-0.35,0.35]);
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
[~,~,stat_R2p] = anova2(R2p(dpts,:)',1,'off');
c_R = multcompare(stat_R2p,'display','off');

% DBV ANOVA
[~,~,stat_DBV] = anova2(DBV(dpts,:)',1,'off');
c_D = multcompare(stat_DBV,'display','off');

% OEF ANOVA
[~,~,stat_OEF] = anova2(OEF(dpts,:)',1,'off');
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


