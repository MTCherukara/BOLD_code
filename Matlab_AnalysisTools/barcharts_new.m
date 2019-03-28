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
legtext = {'FLAIR 2C','NF 2C','NF 3C','NFC T1w','NFC T2w','NFC T2fit'};
%           1          2       3       4         5         6  

% Choose which columns to plot
dpts = [1,3,4,5,6];

% Pick pairwise comparisons from DPTS values
grps = {[1,2],[1,3],[1,4],[1,5]};

% Decide on additional plots
plot_FE = 0;    % Free Energy (Median)
plot_RR = 0;    % Median Residuals (Absolute)
plot_SN = 0;    % Model Signal-to-Noise Ratio


%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    DATA             % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
  

%       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
R2p = [ 5.4710,    3.9560,    3.1760,    2.4570,    3.7880; ...     % FLAIR 2C
        4.9870,    4.7000,    3.6980,    3.2690,    3.5530; ...     % NF 2C
        5.3240,    4.8940,    3.7480,    3.2830,    3.6850; ...     % NF 3C
        5.3740,    4.9240,    3.7760,    3.3330,    3.6760; ...     % NFC T1w
        5.3110,    4.9010,    3.7160,    3.2500,    3.6550; ...     % NFC T2w
        5.4690,    5.0100,    3.8000,    3.3950,    3.7250 ];       % NFC T2fit

%       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
DBV = [ 9.8830,    8.3000,    6.0660,    5.8470,    6.8460; ...
        9.4720,   11.7230,   10.2550,    8.7750,    7.8660; ...
        8.8330,    8.7950,    7.2900,    6.9470,    6.7700; ...
        9.0800,    8.7690,    7.1910,    6.7870,    6.8550; ...
        8.8880,    9.0720,    7.3160,    7.0790,    6.9190; ...
        9.0600,    8.5780,    6.7700,    6.7980,    6.8400 ];

%       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
OEF = [ 24.6100,   21.9200,   24.7100,   20.7000,   22.8800; ...
        26.5000,   23.4900,   22.9000,   20.9600,   21.0100; ...
        26.6900,   24.6300,   23.5500,   21.5900,   24.5000; ...
        26.8600,   25.3100,   23.8800,   22.5200,   23.5500; ...
        26.5500,   24.0600,   23.2600,   21.2200,   23.0800; ...
        27.6800,   26.1700,   25.0600,   23.4100,   24.6800 ];




% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    ERRORS           % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

      
%        Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
eR2p = [ 3.7350,    3.2010,    2.2140,    1.8580,    3.2420; ...
         3.0810,    3.1060,    1.7650,    1.9360,    2.3600; ...
         3.6550,    3.5490,    2.1040,    2.2020,    2.5420; ...
         3.6680,    3.6220,    2.1210,    2.2280,    2.6210; ...
         3.6710,    3.5670,    2.0780,    2.1590,    2.5270; ...
         3.8130,    3.7710,    2.1290,    2.2300,    2.7330 ];
     
%        Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
eDBV = [ 8.9120,    8.8120,    6.0860,    6.3410,    6.9380; ...
         8.6880,   10.8240,   11.1950,    7.7460,    6.0260; ...
         7.3860,    7.7930,    5.5150,    6.0300,    6.0230; ...
         7.7590,    7.9070,    5.5750,    6.1100,    6.1510; ...
         7.2460,    7.7770,    5.1030,    6.0130,    6.0370; ...
         8.1000,    8.1800,    5.0840,    6.2920,    6.5190 ];

%        Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
eOEF = [ 16.3900,   17.5400,   18.8200,   17.4000,   17.5500; ...
         21.6700,   21.2800,   18.8700,   17.5700,   17.4000; ...
         20.2700,   20.3700,   18.6900,   17.3400,   18.3400; ...
         20.2000,   20.6900,   18.5100,   17.4000,   17.5900; ...
         20.4700,   20.4800,   18.6500,   17.3100,   17.3400; ...
         20.8400,   20.6600,   18.5900,   18.0200,   18.5200 ];

      
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    FREE ENERGY        % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% NEGATIVE MEDIAN FREE ENERGY
%      VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
FE = [  ];
   
% % NEGATIVE MEAN FREE ENERGY
% %      VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
% FE = [   0     ,    0     ,    0     ,    0     ,    0     ,    0     ,    0     ; ...
%        263.1000,  571.3000,  229.0000,  338.7000,  604.7000,  453.4000,  429.3000; ...
%        267.3000,  550.0000,  254.5000,  336.2000,  710.7000,  515.7000,  500.3000; ...
%        222.3000,  446.5000,  205.6000,  296.1000,  629.2000,  410.7000,  425.3000; ...
%        229.0000,  506.0000,  207.2000,  314.7000,  706.0000,  444.6000,  456.0000 ];
     
%      VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
RR = [  ];
   
%      VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
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
sR2p = std(R2p,0,2); %mean(eR2p,2); %
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
    axis([0.5,npts+0.5,0,37]);
end
ylabel('OEF (%)');
xticks(1:length(dpts));
xticklabels(lbls);

%% Extra Plots

% Plot Free Energy
if plot_FE
    figure(11); hold on; box on;
    bar(1:npts,aFE(dpts),0.6,'FaceColor',defColour(1));
    errorbar(1:npts,aFE(dpts),sFE(dpts),'k.','LineWidth',2,'MarkerSize',1);
    axis([0.5,length(dpts)+0.5,0,400]);
    ylabel('-Free Energy');
    xticks(1:length(dpts));
    xticklabels(lbls);
end

% Plot Median Residual
if plot_RR
    figure(12); hold on; box on;
    bar(1:npts,aRR(dpts),0.6,'FaceColor',defColour(1));
    errorbar(1:npts,aRR(dpts),sRR(dpts),'k.','LineWidth',2,'MarkerSize',1);
    axis([0.5,length(dpts)+0.5,0,1.5]);
    ylabel('Median Residual');
    xticks(1:length(dpts));
    xticklabels(lbls);
end

% Plot Model SNR
if plot_SN
    figure(13); hold on; box on;
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
set(HR(:,2),'FontSize',18);

% Plot DBV significance stars
figure(2);
HD = sigstar(grps,p_D,1);
set(HD,'Color','k')
set(HD(:,2),'FontSize',18);

% Plot OEF significance stars
figure(3);
HO = sigstar(grps,p_O,1);
set(HO,'Color','k')
set(HO(:,2),'FontSize',18);

% FE ANOVA
if plot_FE
    [~,~,stat_FE] = anova2(FE(dpts,:)',1,'off');
    c_FE = multcompare(stat_FE,'display','off');
    p_FE = MC_pvalues(c_FE,grps);

    figure(11);
    HFE = sigstar(grps,p_FE,1);
    set(HFE,'Color','k')
    set(HFE(:,2),'FontSize',16);
end

if plot_RR
    [~,~,stat_RR] = anova2(RR(dpts,:)',1,'off');
    c_RR = multcompare(stat_RR,'display','off');
    p_RR = MC_pvalues(c_RR,grps);

    figure(12);
    HRR = sigstar(grps,p_R,1);
    set(HRR,'Color','k')
    set(HRR(:,2),'FontSize',16);
end

if plot_SN
    [~,~,stat_SN] = anova2(SN(dpts,:)',1,'off');
    c_SN = multcompare(stat_SN,'display','off');
    p_SN = MC_pvalues(c_SN,grps);

    figure(12);
    HSN = sigstar(grps,p_SN,1);
    set(HSN,'Color','k')
    set(HSN(:,2),'FontSize',16);
end

