% Bar Charts New
%
% Actively used as of 2019-01-14
%
% Using FABBER data generated on 6 November 2018 (for 2019 ISMRM Abstract)

clear;
close all;
setFigureDefaults;

%% Plotting Information

% key to data array columns
legtext = {'Linear','1C Model','2C Simple','2C Model'};
%           1        2          3           4     

% Choose which columns to plot
dpts = [1,2,4];

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
  
%       Linear     1C         2C-S       2C-MN
R2p = [ 3.0860,    3.3100,    3.2950,    3.4860; ...
        3.5350,    3.3810,    3.5390,    3.5830; ...
        2.8040,    2.8400,    2.9720,    2.9720; ...
        3.3670,    3.5050,    3.5500,    3.5400; ...
        2.9620,    3.3010,    3.2780,    3.2370; ...
        3.3900,    3.4300,    3.4320,    3.5090; ...
        2.5780,    2.5890,    2.5460,    2.6230 ];

%       Linear     1C         2C-S       2C-MN
DBV = [ 4.5910,    4.3750,    5.2400,    5.5560; ...
        5.8100,    5.0200,    5.8390,    6.0650; ...
        4.0380,    4.5280,    5.1640,    5.2440; ...
        5.0600,    6.0410,    6.4470,    6.2770; ...
        5.2380,    7.1930,    7.3340,    7.3870; ...
        5.2680,    4.6800,    5.3400,    5.4000; ...
        4.8010,    4.4730,    4.6880,    4.7470 ];

%       Linear     1C         2C-S       2C-MN
OEF = [ 27.1300,   33.0500,   31.1100,   29.9200; ...
        24.0300,   31.1200,   32.5800,   32.4900; ...
        26.3200,   30.7300,   25.0100,   24.0700; ...
        24.7200,   24.1000,   26.8500,   27.6100; ...
        23.1500,   18.6900,   21.3000,   22.0900; ...
        26.4000,   28.9300,   32.2500,   32.9200; ...
        21.2900,   20.4900,   21.7300,   22.1800 ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    ERRORS           % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

     
%        Linear     1C         2C-S       2C-MN
eR2p = [ 1.9830,    0.6570,    0.6360,    0.7410; ...
         2.8350,    0.7630,    0.7580,    0.7220; ...
         2.6410,    0.6280,    0.6910,    0.5850; ...
         3.1420,    0.6960,    0.7450,    0.7250; ...
         2.8680,    0.6620,    0.7510,    0.6500; ...
         2.8880,    0.5670,    0.6130,    0.6470; ...
         2.5600,    0.5390,    0.5890,    0.5640 ];
     
%        Linear     1C         2C-S       2C-MN
eDBV = [ 3.8470,    2.8550,    3.1730,    3.6700; ...
         5.2850,    3.7700,    3.7240,    3.2900; ...
         3.8310,    3.6060,    3.7660,    3.1590; ...
         4.9730,    3.8240,    4.1770,    3.9890; ...
         5.2610,    2.8770,    3.4510,    3.0580; ...
         5.4820,    2.5700,    3.3090,    3.1980; ...
         5.0990,    2.6920,    3.2080,    2.7260 ];

%        Linear     1C         2C-S       2C-MN
eOEF = [ 19.0700,   20.0100,   19.0800,   18.2500; ...
         16.5000,   22.3400,   23.1800,   22.7900; ...
         19.6700,   21.4500,   17.4400,   16.5700; ...
         16.7200,   15.3000,   17.6300,   18.7800; ...
         17.4400,   10.9900,   12.2000,   13.3900; ...
         18.8600,   19.1000,   21.3700,   21.2800; ...
         16.8600,   15.2900,   16.7000,   16.6800 ];

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

ndat = size(R2p,2);

% REBASE = 1 will normalize each data array to the first column (removing the
% effect of intersubject variability) in order to make comparison solely on the
% models themselves
rebase = 0;

if rebase
    eR2p = eR2p./repmat(R2p(:,dpts(1)),1,ndat);
    eDBV = eDBV./repmat(DBV(:,dpts(1)),1,ndat);
    eOEF = eOEF./repmat(OEF(:,dpts(1)),1,ndat);

    R2p = R2p./repmat(R2p(:,dpts(1)),1,ndat);
    DBV = DBV./repmat(DBV(:,dpts(1)),1,ndat);
    OEF = OEF./repmat(OEF(:,dpts(1)),1,ndat);
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
aSN  = mean(SN);
sSN  = std(SN);


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
[~,~,stat_R2p] = anova2(R2p(:,dpts),1,'off');
c_R = multcompare(stat_R2p,'display','off');

% DBV ANOVA
[~,~,stat_DBV] = anova2(DBV(:,dpts),1,'off');
c_D = multcompare(stat_DBV,'display','off');

% OEF ANOVA
[~,~,stat_OEF] = anova2(OEF(:,dpts),1,'off');
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


