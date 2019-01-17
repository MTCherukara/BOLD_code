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
legtext = {'FLAIR 2C','NF 2C','NF 3C','NFC T2w','NFC T2seg','NFC T1seg','NFC T2fit'};
%           1          2       3       4         5           6           7

% Choose which columns to plot
dpts = [1,2,3,6,5];

% Pick pairwise comparisons from DPTS values
grps = {[1,2],[1,3],[1,4],[1,5],[3,4]};

% Decide on additional plots
plot_FE = 0;    % Free Energy
plot_RR = 0;    % Median Residuals
plot_SN = 0;    % Model Signal-to-Noise Ratio


%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    DATA             % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
  
%       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
R2p = [ 4.2020,    3.0390,    1.8310,    1.9490,    2.4960; ...     % FLAIR 2C
        4.2160,    4.2520,    3.1520,    2.4450,    2.7280; ...     % NF 2C 
        5.0740,    4.6250,    4.3840,    3.5490,    3.5130; ...     % NF 3C
        3.6680,    3.2110,    3.2400,    2.3690,    2.4370; ...     % NFC T2w
        5.7070,    4.6980,    5.0440,    3.0160,    3.3690; ...     % NFC T2w
        5.6820,    5.0670,    5.2430,    3.7260,    3.7850; ...     % NFC T1w
        6.1990,    5.1270,    5.4230,    4.3320,    4.0560 ];       % NFC T1fit

%       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
DBV = [ 7.0270,    4.9990,    2.7060,    3.4020,    4.3760; ...
        7.0640,    5.9420,    6.0100,    4.5800,    5.4980; ...
        5.3110,    3.8070,    6.0380,    5.5290,    6.9390; ...
        5.0600,    5.0200,    4.9600,    4.4930,    4.9490; ...
        6.9050,    4.6540,    6.8710,    5.3960,    5.2070; ...
        7.1530,    5.4690,    6.8480,    5.9370,    6.3740; ...
        8.1620,    5.1990,    7.1430,    5.6480,    5.7480 ];

%       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
OEF = [ 18.2000,   17.5600,   13.5700,   14.3100,   14.5400; ...
        18.8500,   18.9000,   16.9700,   17.2200,   15.5300; ...
        15.7100,   14.5800,   14.3100,   14.6800,   13.4300; ...
        15.5200,   14.6700,   13.9300,   15.2100,   13.4200; ...
        14.0200,   12.9300,   12.2100,   13.3700,   11.7000; ...
        14.3600,   12.9500,   12.6400,   13.0800,   11.5400; ...
        14.1700,   12.3800,   12.1700,   12.5000,   10.8900 ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    ERRORS           % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

      
%        Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
eR2p = [ 0.9590,    0.7860,    1.0010,    0.8340,    1.0540; ...
         0.6660,    0.8680,    0.6180,    0.5220,    0.6380; ...
         6.1550,    6.2080,    6.1330,    5.8430,    6.0600; ...
         2.3770,    2.3320,    2.3670,    2.0900,    2.1330; ...
         5.3860,    5.0080,    5.4680,    4.0740,    4.3180; ...
         5.4760,    5.2360,    5.3080,    4.5520,    4.6440; ...
         5.7690,    5.3440,    5.5580,    4.8900,    4.6300 ];
     
%        Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
eDBV = [  3.6290,    2.8500,    3.6760,    3.0140,    4.1840; ...
          2.9090,    3.5650,    2.6180,    2.2460,    2.8430; ...
         14.9000,   15.0800,   15.9600,   14.9400,   16.2300; ...
          6.8420,    7.2190,    8.2650,    5.6700,    6.3890; ...
         12.5800,   12.1100,   13.6100,   11.2600,   12.5700; ...
         12.4300,   12.7800,   14.2700,   12.6700,   13.3800; ...
         13.4700,   12.9800,   15.2000,   14.0600,   13.6600 ];

%        Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
eOEF = [ 10.2900,   10.1000,   12.1300,   11.2300,   12.3900; ...
          7.8300,    8.8500,    7.3300,    8.0400,    8.1000; ...
         17.2500,   18.9200,   19.3400,   23.4100,   22.5000; ...
         12.5200,   13.6000,   12.6000,   14.6800,   13.4300; ...
         16.8600,   18.4100,   16.8100,   23.0600,   20.4100; ...
         16.7100,   17.4700,   16.1000,   21.3400,   19.1400; ...
         16.3900,   17.1700,   16.1600,   20.1900,   19.2900 ];

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


