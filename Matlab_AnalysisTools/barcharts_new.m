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
legtext = {'FP-2C','NF-2C','NF-3C','NF-T1','NF-T2','NF-BF','NF-FC','FP-2C'...
           'FP-2C','NF-2C','NF-3C','NF-T1','NF-T2','NF-BF','NF-FC','FP-2C'};
%            1       2       3       4       5       6       7       8     .
%            9      10      11      12      13      14      15      16     .


% Choose which columns to plot
dpts = [9,2,3,4,5,6,7];

% Pick pairwise comparisons from DPTS values
grps = {[1,2],[1,3],[1,4],[1,5],[1,6],[1,7]};

% Decide on additional plots
plot_FE = 0;    % Free Energy (Median)
plot_RR = 0;    % Median Residuals (Absolute)
plot_SN = 0;    % Model Signal-to-Noise Ratio


%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    DATA             % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


%       Sub3       Sub4       Sub6       Sub8       Sub9
R2p = [ 4.6310,    3.1300,    2.6330,    1.8450,    3.2710; ...
        1.3190,    1.0190,    1.3380,    1.1040,    0.8590; ...
        1.4490,    1.5990,    0.6890,    0.7200,    1.1640; ...
        1.6490,    1.3150,    1.6450,    1.3600,    1.0870; ...
        1.6200,    1.4770,    1.5940,    1.4370,    1.3290; ...
        1.5370,    1.2590,    1.5000,    1.2980,    1.1650; ...
        1.4650,    1.2860,    1.4660,    1.2050,    1.0740; ...
        2.6630,    2.2010,    1.3820,    0.7240,    2.8840; ...
        4.2330,    2.7480,    3.4690,    2.8750,    2.7790; ...
        2.7880,    2.7060,    3.1050,    3.5290,    2.4470; ...
        2.3790,    4.8070,    2.6070,    3.5140,    3.0120; ...
        1.7870,    4.2930,    2.8740,    3.0470,    3.6750; ...
        2.9300,    3.5660,    3.6050,    2.5220,    3.6790; ...
        3.5270,    3.0170,    3.4480,    2.9780,    2.8470; ...
        3.2990,    3.2550,    3.2050,    3.3270,    2.5480; ...
        3.1340,    3.5160,    2.7230,    3.5320,    3.2190; ...
        ];

%       Sub3       Sub4       Sub6       Sub8       Sub9
DBV = [ 6.0180,    4.4290,    4.1180,    2.8840,    4.8470; ...
        3.9060,    3.1340,    3.1100,    2.4630,    2.4960; ...
        4.8650,    4.4550,    3.6260,    2.4500,    3.2370; ...
        3.1560,    2.9030,    2.7190,    1.9300,    2.5120; ...
        3.2480,    3.1140,    2.7250,    1.9550,    2.2470; ...
        3.2850,    3.0030,    2.7490,    1.9150,    2.4020; ...
        3.1180,    3.0580,    2.5980,    1.8200,    2.3900; ...
        4.6180,    3.6570,    2.6540,    1.8570,    4.6230; ...
        6.5380,    4.3750,    9.5620,    5.8540,    6.5330; ...
        4.7810,    5.7250,    5.6340,    8.2030,    5.4990; ...
        4.2570,    5.9050,    4.8550,    9.4620,    5.7040; ...
        3.6000,    7.3580,    5.8330,    5.7940,    8.9060; ...
        5.0910,    5.0080,    7.7880,    5.1700,    9.6280; ...
        6.9170,    4.0580,    9.5530,    5.8640,    6.4010; ...
        8.3120,    4.8220,    5.2640,    8.7940,    5.1540; ...
        5.0400,    8.0980,    4.4460,    9.1970,    5.3440; ...
        ];

%       Sub3       Sub4       Sub6       Sub8       Sub9
OEF = [ 24.0000,   22.0600,   20.6600,   20.7000,   18.6600; ...
        14.9700,   16.5200,   17.8700,   17.9400,   15.9400; ...
         8.6700,   11.5800,    8.5700,   10.7800,   10.9400; ...
        18.8800,   21.1400,   23.2600,   25.9800,   19.5000; ...
        17.4700,   20.5100,   22.3600,   26.1700,   21.9300; ...
        17.0400,   19.1700,   21.2500,   24.2200,   19.5000; ...
        17.3000,   18.6300,   21.7000,   24.1800,   18.2600; ...
        14.5100,   18.3900,   15.2700,   12.4800,   18.1200; ...
        18.8500,   23.2600,   16.6900,   19.2400,   18.1900; ...
        16.9900,   19.7000,   21.0200,   19.9100,   18.7400; ...
        17.4600,   26.0800,   21.4500,   16.1900,   18.4800; ...
        15.7500,   20.0800,   18.8900,   20.2500,   17.2100; ...
        15.3700,   23.0200,   21.9400,   20.2000,   15.6700; ...
        22.1300,   24.1000,   17.0200,   18.6800,   18.3200; ...
        17.4400,   20.9200,   22.2800,   18.0000,   20.3900; ...
        22.2000,   21.0900,   22.9500,   16.2400,   19.7100; ...
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
% axis square;
box on; 
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+0.5,0,3.6]);
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
% axis square;
box on;
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+0.5,0,5.8]);
end

ylabel('DBV (%)');
xticks(1:length(dpts));
xticklabels(lbls);
% xtickangle(45);


% Plot OEF
figure(3); hold on;
bar(1:npts,aOEF(dpts),0.6,'FaceColor',defColour(1));
errorbar(1:npts,aOEF(dpts),sOEF(dpts),'k.','LineWidth',2,'MarkerSize',1);
% axis square;
box on;
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