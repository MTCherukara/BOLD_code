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
legtext = {'L Model','1C Model','2C Simple','2C Model','1C Model','2C Model','1C Spatial','2C Spatial','1C NLLS'};
%           1         2          3           4          5          6          7           8             9        .

% Choose which columns to plot
dpts = [1,9,5,6,7,8];

% Pick pairwise comparisons from DPTS values
grps = {[1,2],[1,3],[1,4],[1,5],[1,6]};

% Decide on additional plots
plot_FE = 0;    % Free Energy
plot_RR = 0;    % Median Residuals
plot_SN = 0;    % Model Signal-to-Noise Ratio


%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    DATA             % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
  
%       VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
R2p = [ 3.1480,    3.6560,    2.9520,    3.5170,    3.0660,    3.5430,    2.7650; ...       % Linear
        3.3100,    3.3810,    2.8400,    3.5050,    3.3010,    3.4300,    2.5890; ...       % 1C Model
        3.2950,    3.5390,    2.9720,    3.5500,    3.2780,    3.4320,    2.5460; ...       % 2C Simple Model
        3.1820,    3.3940,    2.8820,    3.3730,    3.1100,    3.3530,    2.5570 ];         % 2C Steady State MN Model

%       VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
DBV = [ 4.8760,    6.2500,    4.4210,    5.3630,    5.7620,    5.8370,    5.1960; ...
        4.3750,    5.0200,    4.5280,    6.0410,    7.1930,    4.6800,    4.4730; ...
        5.2400,    5.8390,    5.1640,    6.4470,    7.3340,    5.3400,    4.6880; ...
        5.3600,    5.4860,    5.1820,    5.9930,    6.6390,    5.3310,    4.5780; ...
        6.2150,    8.3470,    5.7530,    7.3290,    8.4550,    7.7340,    5.4440; ...
        6.3390,    8.3080,    5.6840,    7.4230,    8.6410,    7.3680,    5.3820; ...
        4.9150,    5.5610,    4.0230,    6.2350,    5.6440,    5.1550,    4.7500; ...
        5.2580,    6.0190,    4.4220,    6.3780,    6.0070,    5.5170,    4.9750; ...
        4.7460,    7.4610,    4.8200,    6.7060,    8.2100,    7.1390,    5.1800 ];

%       VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
OEF = [ 23.9600,   20.4800,   22.8200,   21.0800,   19.9900,   23.3800,   18.2400; ...
        33.0500,   31.1200,   30.7300,   24.1000,   18.6900,   28.9300,   20.4900; ...
        31.1100,   32.5800,   25.0100,   26.8500,   21.3000,   32.2500,   21.7300; ...
        32.3400,   33.8800,   26.4500,   28.1500,   21.9000,   33.0900,   22.1800; ...
        24.4100,   27.1800,   28.8100,   28.0900,   32.6500,   31.6200,   28.1800; ...
        24.4700,   27.2900,   28.8900,   28.0800,   33.2400,   31.5000,   27.9300; ...
        17.1000,   15.8400,   17.1200,   15.5800,   16.0300,   18.4400,   14.6700; ...
        16.9600,   15.7300,   16.9600,   15.4400,   16.0500,   18.1800,   14.5100; ...
        55.5400,   50.6300,   47.4100,   45.6300,   40.9800,   46.0000,   39.2600 ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    ERRORS           % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

      
%        VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
eR2p = [ 1.9700,    2.8330,    2.6720,    3.1640,    2.8880,    2.9060,    2.6130; ...
         0.6570,    0.7630,    0.6280,    0.6960,    0.6620,    0.5670,    0.5390; ...
         0.6360,    0.7580,    0.6910,    0.7450,    0.7510,    0.6130,    0.5890; ...
         0.6180,    0.6690,    0.6010,    0.5700,    0.5850,    0.6180,    0.5330 ];
    
%        VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
eDBV = [ 3.9490,    5.3660,    3.9220,    5.0780,    5.3640,    5.8220,    5.0960; ...
         2.8550,    3.7700,    3.6060,    3.8240,    2.8770,    2.5700,    2.6920; ...
         3.1730,    3.7240,    3.7660,    4.1770,    3.4510,    3.3090,    3.2080; ...
         3.4450,    3.2060,    3.3570,    3.1600,    2.6520,    3.4260,    2.7920; ...
         2.6610,    3.9400,    2.4580,    3.1060,    5.0150,    3.4810,    2.9170; ...
         2.7330,    4.1200,    2.3790,    3.1010,    5.1970,    3.7180,    3.0460; ...
         2.5860,    2.8650,    2.3110,    2.7800,    2.4710,    2.4690,    2.3790; ...
         2.7330,    3.0280,    2.4360,    2.9260,    2.6820,    2.5870,    2.4960; ...
         3.5970,    4.7050,    3.1420,    4.4870,    5.7870,    4.4660,    3.0790 ];

%        VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
eOEF = [ 16.7400,   13.7900,   17.2100,   14.2100,   14.4700,   16.5900,   14.7500; ...
         20.0100,   22.3400,   21.4500,   15.3000,   10.9900,   19.1000,   15.2900; ...
         19.0800,   23.1800,   17.4400,   17.6300,   12.2000,   21.3700,   16.7000; ...
         19.4700,   24.2100,   18.3500,   18.2800,   12.6300,   21.2200,   16.3100; ...
         20.1600,   31.0000,   31.0000,   29.0400,   38.9500,   32.9100,   34.8600; ...
         20.4000,   31.8400,   31.1900,   29.4400,   39.7400,   32.8000,   34.9400; ...
          6.8600,    6.5800,    8.0200,    6.5300,    6.4500,    7.6900,    6.5400; ...
          6.5300,    6.4100,    7.9100,    6.3100,    5.9400,    7.5300,    6.1600; ...
         56.1200,   36.1100,   70.0600,   29.8500,   30.0300,   13.4000,   42.5600 ];

      
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
sDBV = std(DBV,0,2); %mean(eDBV,2); %
aOEF = mean(OEF,2);
sOEF = std(OEF,0,2); %mean(eOEF,2); %
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

% % Plot R2p
% figure(1); hold on; box on;
% bar(1:npts,aR2p(dpts),0.6,'FaceColor',defColour(1));
% errorbar(1:npts,aR2p(dpts),sR2p(dpts),'k.','LineWidth',2,'MarkerSize',1);
% if rebase
%     axis([0.5,npts+0.5,0,2]);
% else
%     axis([0.5,npts+0.5,0,5.6]);
% end
% ylabel('R_2'' (s^-^1)');
% xticks(1:length(dpts));
% xticklabels(lbls); 

% Plot DBV
figure(2); hold on; box on;
bar(1:npts,aDBV(dpts),0.6,'FaceColor',defColour(1));
errorbar(1:npts,aDBV(dpts),sDBV(dpts),'k.','LineWidth',2,'MarkerSize',1);
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+0.5,0,10.8]);
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

% % R2p ANOVA
% [~,~,stat_R2p] = anova2(R2p(dpts,:)',1,'off');
% c_R = multcompare(stat_R2p,'display','off');

% DBV ANOVA
[~,~,stat_DBV] = anova2(DBV(dpts,:)',1,'off');
c_D = multcompare(stat_DBV,'display','off');

% OEF ANOVA
[~,~,stat_OEF] = anova2(OEF(dpts,:)',1,'off');
c_O = multcompare(stat_OEF,'display','off');

% Pull out p-values
% p_R = MC_pvalues(c_R,grps);
p_D = MC_pvalues(c_D,grps);
p_O = MC_pvalues(c_O,grps);

% % Plot R2p significance stars
% figure(1);
% HR = sigstar(grps,p_R,1);
% set(HR,'Color','k')
% set(HR(:,2),'FontSize',16);

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


