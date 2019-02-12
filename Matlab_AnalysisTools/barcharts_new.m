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
legtext = {'L Model','1C Model','2C Model','1C Spatial','2C Spatial','5 \tau VB','5 \tau SVB','11 \tau VB','L Model VB'};
%           1         2          3          4            5            6           7            8            9          . 

% Choose which columns to plot
dpts = [1,9,2,4];

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
        3.5050,    3.9810,    3.3830,    4.0960,    3.6400,    3.9840,    3.0970; ...       % 1C Model
        3.6650,    4.1710,    3.3600,    3.9770,    3.7830,    4.0960,    2.9520; ...       % 2C Model
        3.5590,    4.1400,    3.3180,    4.0630,    3.6020,    3.8960,    3.0060; ...       % 1C Spatial
        3.5620,    4.1260,    3.2970,    4.0010,    3.5390,    3.8620,    2.9800; ...       % 2C Spatial
        3.4790,    4.6250,    3.1510,    4.4920,    3.8870,    4.0170,    3.1490; ...       % 5 taus
        3.7010,    4.4800,    3.2670,    4.6280,    3.6030,    3.9810,    3.1260; ...         % 5 taus Spatial
        4.0410,    5.2220,    3.6730,    4.7400,    4.0400,    4.5730,    4.7410; ...
        3.2450,    3.8230,    3.0450,    3.6810,    3.2020,    3.6080,    2.8410 ];

%       VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
DBV = [ 4.8760,    6.2500,    4.4210,    5.3630,    5.7620,    5.8370,    5.1960; ...
        5.8020,    6.9000,    6.4290,    7.1720,    8.6970,    6.4310,    5.9270; ...
        5.6980,    6.7300,    5.0450,    5.9100,    6.4770,    5.7030,    5.1940; ...
        6.1330,    8.6050,    5.4730,    7.2100,    7.5440,    6.4530,    5.2690; ...
        5.9180,    7.9280,    5.0030,    6.4920,    6.9220,    5.7540,    5.0390; ...
        5.9900,   11.3000,    5.4620,    9.1620,    8.8900,    7.7170,    6.7930; ...
        6.9500,   10.1800,    6.4920,   10.6000,    8.2160,    7.7280,    7.5300; ...
        8.4760,   14.9500,    8.0790,   11.4000,   11.6400,   11.1100,   11.4400; ...
        5.2780,    7.1340,    4.8770,    6.0750,    6.5030,    6.3460,    5.5450 ];

%       VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
OEF = [ 23.9600,   20.4800,   22.8200,   21.0800,   19.9900,   23.3800,   18.2400; ...
        22.0200,   19.4400,   23.6700,   21.4600,   17.5700,   22.0800,   20.1100; ...
        22.0300,   18.2300,   21.1400,   19.6900,   18.0800,   21.5100,   19.4900; ...
        21.6000,   18.1500,   21.5700,   19.3400,   17.1800,   22.1700,   19.9700; ...
        20.8600,   18.6100,   21.2300,   19.6300,   18.0900,   21.9600,   19.7900; ...
        24.1900,   17.8200,   23.8500,   20.7000,   18.4900,   22.3000,   18.8500; ...
        20.3200,   16.4200,   19.3600,   15.6000,   16.1700,   20.4300,   15.0500; ...
        20.6400,   15.7700,   19.1200,   16.0400,   16.7500,   18.8500,   17.4300; ... 
        25.9100,   21.8200,   24.3500,   22.9600,   21.5700,   25.6300,   20.4800 ];


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
FE = [   0     ,    0     ,    0     ,    0     ,    0     ,    0     ,    0     ; ...
       185.0000,  308.5000,  153.1000,  223.2000,  267.8000,  240.3000,  269.9000;
       170.9000,  291.3000,  144.2000,  207.0000,  281.6000,  242.3000,  273.5000;
       158.6000,  251.3000,  128.4000,  190.8000,  259.9000,  209.6000,  256.4000;
       156.6000,  253.3000,  128.9000,  191.6000,  254.6000,  213.5000,  251.5000 ];
   
% % NEGATIVE MEAN FREE ENERGY
% %      VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
% FE = [   0     ,    0     ,    0     ,    0     ,    0     ,    0     ,    0     ; ...
%        263.1000,  571.3000,  229.0000,  338.7000,  604.7000,  453.4000,  429.3000; ...
%        267.3000,  550.0000,  254.5000,  336.2000,  710.7000,  515.7000,  500.3000; ...
%        222.3000,  446.5000,  205.6000,  296.1000,  629.2000,  410.7000,  425.3000; ...
%        229.0000,  506.0000,  207.2000,  314.7000,  706.0000,  444.6000,  456.0000 ];
     
%      VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
RR = [ 0     ,    0     ,    0     ,    0     ,    0     ,    0     ,    0     ; ...
       0.1470,    0.7200,    0.3180,    0.3560,    0.9200,    0.7310,    0.5660; ...
       0.2110,    0.8770,    0.4310,    0.4190,    1.2270,    1.0120,    0.7810; ...
       0.0920,    0.5990,    0.2730,    0.2930,    1.0590,    0.6520,    0.5680; ...
       0.0990,    0.7570,    0.3080,    0.3390,    1.2740,    0.7910,    0.6610 ];
   
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

