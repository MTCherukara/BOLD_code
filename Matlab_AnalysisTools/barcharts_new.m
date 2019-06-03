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
legtext = {'L','1C','M.N.R.','1C(s)','2C(s)','5 \tau VB','5 \tau SVB','11 \tau VB','L Model VB','Powder','Powder(s)','Linear'};
%           1   2    3        4       5       6           7            8            9            10       11          12     . 

% Choose which columns to plot
dpts = [12,10,3];

% Pick pairwise comparisons from DPTS values
grps = {[1,2],[1,3],[2,3]};

% Decide on additional plots
plot_FE = 0;    % Free Energy (Median)
plot_RR = 0;    % Median Residuals (Absolute)
plot_SN = 0;    % Model Signal-to-Noise Ratio


%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    DATA             % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


%       VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
R2p = [ 3.1480,    3.6560,    2.9520,    3.5170,    3.0660,    3.5430,    2.7650; ...       % Linear
        3.5700,    3.8610,    3.1920,    3.9070,    3.3730,    3.8660,    2.8550; ...       % 1C Model (NEW)
        3.7180,    4.0980,    3.4700,    4.1920,    4.2430,    3.9960,    3.5060; ...       % 2C Model (NEW)
        3.7500,    3.6540,    4.1540,    3.3650,    4.3450,    3.5010,    4.1370; ...       % 1C Spatial
        3.0390,    4.1940,    3.4920,    4.4260,    3.4010,    4.1750,    2.8420; ...       % 2C Spatial
        3.4790,    4.6250,    3.1510,    4.4920,    3.8870,    4.0170,    3.1490; ...       % 5 taus
        3.7010,    4.4800,    3.2670,    4.6280,    3.6030,    3.9810,    3.1260; ...       % 5 taus Spatial
        4.0410,    5.2220,    3.6730,    4.7400,    4.0400,    4.5730,    4.7410; ...       % 11 taus
        3.2450,    3.8230,    3.0450,    3.6810,    3.2020,    3.6080,    2.8410; ...       % L model VB
        3.8060,    4.3270,    3.6460,    4.5240,    3.9760,    4.2820,    3.4150; ...       % Powder VB
        3.3350,    3.6450,    3.1180,    3.9140,    3.0060,    3.7060,    2.5790; ...       % Powder SVB
        3.7280,    4.3360,    3.8200,    4.3450,    4.3110,    4.4120,    3.3100; ...       % L-blood VB
        ];

%       VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
DBV = [ 4.8760,    6.2500,    4.4210,    5.3630,    5.7620,    5.8370,    5.1960; ...
        6.3520,    6.2550,    5.7930,    6.5700,    5.4570,    5.9920,    5.5170; ...
        6.4010,    7.0070,    6.4720,    6.7580,    6.4130,    6.2730,    6.7320; ...
        7.4580,    6.8770,    8.6190,    7.0110,    8.5250,    7.3220,    7.3360; ...
        7.4020,    7.4210,    6.9160,    7.7990,    6.5330,    6.6890,    6.2690; ...
        5.9900,   11.3000,    5.4620,    9.1620,    8.8900,    7.7170,    6.7930; ...
        6.9500,   10.1800,    6.4920,   10.6000,    8.2160,    7.7280,    7.5300; ...
        8.4760,   14.9500,    8.0790,   11.4000,   11.6400,   11.1100,   11.4400; ...
        5.2780,    7.1340,    4.8770,    6.0750,    6.5030,    6.3460,    5.5450; ...
        7.5060,    8.1970,    7.1190,    9.2030,    8.0430,    7.3050,    7.0360; ...
        6.9190,    8.3160,    6.5790,    9.5890,    8.1790,    7.5310,    6.8220; ...
        8.4720,    9.6370,    9.1950,   10.8730,   10.1370,    9.6900,   10.4390; ...
        ];

%       VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
OEF = [ 23.9600,   20.4800,   22.8200,   21.0800,   19.9900,   23.3800,   18.2400; ...
        19.4900,   16.6000,   16.1300,   17.1800,   16.2600,   18.9400,   15.8300; ...
        20.1000,   17.4000,   17.3100,   18.9100,   17.5600,   21.2500,   16.3900; ...
        20.1100,   21.8100,   17.8900,   18.8900,   17.1300,   18.4700,   20.2800; ...
        16.3200,   20.3000,   19.3700,   18.3400,   19.7200,   21.8900,   17.5700; ...
        24.1900,   17.8200,   23.8500,   20.7000,   18.4900,   22.3000,   18.8500; ...
        20.3200,   16.4200,   19.3600,   15.6000,   16.1700,   20.4300,   15.0500; ...
        20.6400,   15.7700,   19.1200,   16.0400,   16.7500,   18.8500,   17.4300; ... 
        25.9100,   21.8200,   24.3500,   22.9600,   21.5700,   25.6300,   20.4800; ...
        18.4500,   17.4300,   17.6200,   17.3500,   17.4800,   18.6900,   16.5500; ...
        20.3600,   19.0600,   18.9700,   17.3100,   17.4300,   20.2100,   16.7200; ...
        20.0400,   18.7700,   18.3800,   18.2800,   17.6400,   20.5900,   16.2700; ...
        ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    ERRORS           % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


%        VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
eR2p = [ 1.9700,    2.8330,    2.6720,    3.1640,    2.8880,    2.9060,    2.6130; ...
         0.6690,    1.1570,    0.8340,    1.5160,    0.9740,    1.0030,    0.8780; ...
         0.9640,    1.0010,    0.9100,    0.7930,    1.2240,    0.9680,    0.8250; ...
         0.4800,    0.6580,    0.4500,    0.5600,    0.5660,    0.5540,    0.5190; ...
         0.4860,    0.6750,    0.4610,    0.5720,    0.5660,    0.5470,    0.5220 ];
    
%        VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
eDBV = [ 3.9490,    5.3660,    3.9220,    5.0780,    5.3640,    5.8220,    5.0960; ...
         5.9730,    6.7330,    6.9480,    9.8800,    4.7800,    6.1630,    5.3240; ...
         3.2270,    4.4050,    3.5810,    3.2640,    4.1660,    4.6390,    3.7720; ...
         2.1770,    2.9980,    2.0350,    2.4850,    2.5640,    2.4550,    2.3060; ...
         2.1380,    2.9230,    1.9900,    2.4480,    2.4530,    2.3230,    2.2810 ];

%        VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
eOEF = [ 16.7400,   13.7900,   17.2100,   14.2100,   14.4700,   16.5900,   14.7500; ...
         15.9800,   16.8600,   18.6200,   17.7500,   16.4800,   18.7100,   16.5800; ...
         13.5500,   14.8000,   15.4200,   14.8900,   16.9800,   16.7300,   15.2500; ...
         11.6400,   12.1800,   14.9600,   12.6200,   13.5900,   14.0800,   14.0000; ...
         10.9400,   12.3000,   13.6300,   12.9900,   15.0500,   13.4900,   14.0600 ];


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

% % Convert R2' to dHb
% R2p = R2p.*0.0361;

% R2p(2:end,:) = R2p(2:end,:).*0.44;

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
figure(1); hold on;
bar(1:npts,aR2p(dpts),0.6,'FaceColor',defColour(1));
errorbar(1:npts,aR2p(dpts),sR2p(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis square; box on; grid on;
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+0.5,0,5.6]);
end
% ylabel('dHb content (ml/100g)');
ylabel('R_2'' (s^-^1)');
xticks(1:length(dpts));
xticklabels(lbls); 
% xtickangle(45);


% Plot DBV
figure(2); hold on; 
bar(1:npts,aDBV(dpts),0.6,'FaceColor',defColour(1));
errorbar(1:npts,aDBV(dpts),sDBV(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis square; box on; grid on;
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+0.5,0,12.8]);
end

ylabel('DBV (%)');
xticks(1:length(dpts));
xticklabels(lbls);
% xtickangle(45);


% Plot OEF
figure(3); hold on;
bar(1:npts,aOEF(dpts),0.6,'FaceColor',defColour(1));
errorbar(1:npts,aOEF(dpts),sOEF(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis square; box on; grid on;
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+0.5,0,32]);
end
ylabel('OEF (%)');
xticks(1:length(dpts));
xticklabels(lbls);
% xtickangle(45);

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

% Plot DBV significance stars1
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

% Plot up to here %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 26 lines high - for 3 datasets

% Plot up to here %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 26 lines high - for 4 datasets