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
legtext = {'FLAIR','NF 2C','NF 3C','NFC T1w','NFC T2w','NFC T2fit','NF 3C'};
%           1       2       3       4         5         6           7

% Choose which columns to plot
dpts = [1,7,4,5,6];

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
  

% GREY MATTER MASK >99%
%       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
R2p = [ 5.4710,    3.9560,    3.1760,    2.4570,    3.7880; ...     % FLAIR 2C
        4.9870,    4.7000,    3.6980,    3.2690,    3.5530; ...     % NF 2C
        5.3240,    4.8940,    3.7480,    3.2830,    3.6850; ...     % NF 3C
        5.3740,    4.9240,    3.7760,    3.3330,    3.6760; ...     % NFC T1w
        5.3110,    4.9010,    3.7160,    3.2500,    3.6550; ...     % NFC T2w
        5.4690,    5.0100,    3.8000,    3.3950,    3.7250; ...     % NFC T2fit
        5.7760,    5.2920,    4.0300,    3.5970,    3.9280 ];       % NF 3C DF

%       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
DBV = [ 9.8830,    8.3000,    6.0660,    5.8470,    6.8460; ...
        9.4720,   11.7230,   10.2550,    8.7750,    7.8660; ...
        8.8330,    8.7950,    7.2900,    6.9470,    6.7700; ...
        9.0800,    8.7690,    7.1910,    6.7870,    6.8550; ...
        8.8880,    9.0720,    7.3160,    7.0790,    6.9190; ...
        9.0600,    8.5780,    6.7700,    6.7980,    6.8400; ...
        9.6520,    9.0100,    7.8170,    7.3820,    7.9190 ];

%       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
OEF = [ 24.6100,   21.9200,   24.7100,   20.7000,   22.8800; ...
        26.5000,   23.4900,   22.9000,   20.9600,   21.0100; ...
        26.6900,   24.6300,   23.5500,   21.5900,   24.5000; ...
        26.8600,   25.3100,   23.8800,   22.5200,   23.5500; ...
        26.5500,   24.0600,   23.2600,   21.2200,   23.0800; ...
        27.6800,   26.1700,   25.0600,   23.4100,   24.6800; ...
        26.9900,   26.8800,   22.7000,   21.6100,   21.3900 ];



% % GREY MATTER MASK 80-99%
% %       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
% R2p = [ 5.3110,    4.6650,    2.7090,    2.5920,    5.1490; ...
%         4.4350,    6.1970,    3.8060,    3.2970,    3.8400; ...
%         4.6130,    6.4100,    3.6870,    3.3900,    4.1060; ...
%         4.6780,    6.5110,    3.6460,    3.3090,    4.1280; ...
%         4.7020,    6.4730,    3.7120,    3.3550,    3.9850; ...
%         4.7470,    6.5130,    3.8120,    3.2880,    4.2480 ];
% 
% %       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
% DBV = [ 9.7970,    8.6480,    5.2050,    5.7660,    8.8250; ...
%         8.0540,    8.9170,    7.0640,    6.4540,    9.1130; ...
%         9.1120,    9.1840,    7.6410,    7.8350,   10.1680; ...
%         9.1120,    9.8230,    6.9240,    7.1610,    8.5560; ...
%         9.3330,    9.2540,    7.4730,    7.9060,    8.1860; ...
%         8.3240,    8.7270,    7.3840,    6.4580,    8.6820 ];
% 
% %       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
% OEF = [ 25.2270,   24.3230,   23.6170,   21.4670,   23.4310; ...
%         21.7410,   27.9050,   21.1590,   17.4770,   20.4590; ...
%         22.9500,   31.8950,   22.6270,   19.6390,   23.8310; ...
%         23.8540,   29.3450,   24.4000,   21.0990,   20.9450; ...
%         23.4660,   29.9070,   24.0930,   20.9790,   23.0180; ...
%         23.2800,   28.6420,   22.9630,   20.8940,   23.7930 ];


% % GREY MATTER MASK 50-99%
% %       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
% R2p = [ 4.2920,    4.2700,    2.7190,    2.6220,    3.9370; ...
%         4.0730,    5.1220,    3.2830,    3.4510,    3.5770; ...
%         4.2370,    5.3460,    3.2760,    3.5110,    3.6690; ...
%         4.2800,    5.4050,    3.3160,    3.5850,    3.7440; ...
%         4.3000,    5.4510,    3.3350,    3.5980,    3.7470; ...
%         4.3210,    5.4790,    3.3800,    3.5710,    3.8050; ...
%         4.6640,    5.7910,    3.5540,    3.8250,    3.9120 ];
% 
% %       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
% DBV = [ 8.7980,    8.0240,    6.1240,    6.2490,    7.4060; ...
%         9.9170,    9.2490,   10.0930,    9.2250,    7.5130; ...
%         8.0440,    7.9060,    6.7420,    6.9020,    6.7170; ...
%         7.9770,    7.9180,    6.6360,    6.8920,    7.0570; ...
%         7.9600,    7.9390,    6.7170,    6.9810,    6.7720; ...
%         7.9780,    7.9140,    6.7040,    7.1160,    6.9560; ...
%         8.9380,    8.4400,    7.5290,    7.8480,    7.8890 ];
% 
% %       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
% OEF = [ 22.8300,   22.8100,   20.8500,   20.2400,   21.3300; ...
%         23.0000,   24.9600,   20.0100,   20.1300,   20.7800; ...
%         24.0700,   26.4600,   21.7600,   21.8200,   25.8300; ...
%         24.8100,   26.8200,   23.1900,   22.8100,   23.9500; ...
%         25.6600,   26.7300,   23.3900,   23.7900,   23.7800; ...
%         24.7700,   27.3700,   22.9200,   22.2900,   25.7200; ...
%         23.7500,   27.0400,   21.5400,   21.3200,   21.2700 ];

    

% % GREY MATTER MASK 50-80%
% %       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
% R2p = [ 4.2880,    4.3120,    2.7690,    2.6570,    4.0390; ...
%         4.1670,    5.1880,    3.3550,    3.5830,    3.6290; ...
%         4.2560,    5.3390,    3.2530,    3.5440,    3.7220; ...
%         4.2930,    5.4120,    3.3260,    3.6460,    3.8200; ...
%         4.3220,    5.4570,    3.3360,    3.6610,    3.8070; ...
%         4.3800,    5.5100,    3.3830,    3.7120,    3.8830 ];
% 
% %       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
% DBV = [ 8.5980,    8.3460,    5.7250,    6.0170,    7.3930; ...
%         7.5640,    8.2340,    6.7060,    7.0920,    7.8380; ...
%         8.2430,    8.8880,    7.2560,    7.6340,    8.1570; ...
%         8.3100,    8.9440,    7.1230,    7.7570,    8.1570; ...
%         8.3280,    8.8720,    7.2600,    7.7110,    8.0660; ...
%         8.1420,    8.7710,    7.0570,    7.6530,    8.0970 ];
% 
% %       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
% OEF = [ 22.5500,   22.6750,   20.5150,   20.0940,   21.1090; ...
%         23.1480,   24.7210,   19.8620,   20.4420,   20.8190; ...
%         24.2030,   26.0210,   21.6530,   22.0730,   26.0450; ...
%         24.9170,   26.6220,   23.0350,   23.0040,   24.2620; ...
%         25.9100,   26.4800,   23.3020,   24.1210,   23.8600; ...
%         24.9360,   27.2660,   22.9130,   22.4540,   25.9210 ];

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
xtickangle(45);


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
xtickangle(45);


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
xtickangle(45);

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

