% Bar Charts of Phenomenological Model
%
% Actively used as of 2018-09-28
%
% The data for phenomenological model, while nice-looking in this form, is
% completely wrong, as the Modelfit curve is way off

clear;
close all;
setFigureDefaults;

%% Plotting Information

% key to data array columns
legtext = {'L Model','2C Model','Ph Fixed','Ph Var.','L Model','2C Model','Ph Fixed','Ph Var.'};
%           1         2          3          4         5         6          7          8          9         10     .

% Choose which columns to plot
dpts = [1,2,3,4];

% Pick pairwise comparisons from DPTS values
grps = {};

% Decide on additional plots
plot_FE = 0;    % Free Energy
plot_RR = 0;    % Median Residuals
plot_SN = 0;    % Model Signal-to-Noise Ratio


%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    DATA             % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    
%       LinMean    2C.Mean   Ph.Mean    PhC.Mean    LinMed     2C.Med    Ph.Mean   PhC.Med
R2p = [ 3.2350,    3.3340,         0,         0,    2.8510,    2.8930,         0,         0; ...
        3.7380,    3.6110,         0,         0,    2.9970,    2.7350,         0,         0; ...
        2.9520,    3.1230,         0,         0,    2.1480,    2.8130,         0,         0; ...
        3.1890,    3.5680,         0,         0,    2.4620,    2.7680,         0,         0; ...
        3.2330,    3.5750,         0,         0,    2.6000,    2.8890,         0,         0; ...
        3.5560,    3.7760,         0,         0,    2.9340,    3.0130,         0,         0; ...
        2.7260,    2.6630,         0,         0,    2.2370,    2.0660,         0,         0 ];
    
%       LinMean    2C.Mean   Ph.Mean    PhC.Mean    LinMed     2C.Med    Ph.Mean     PhC.Med
DBV = [ 4.3600,    5.6200,   14.9800,   7.374,      3.6540,    3.3390,   10.9900,    3.625; ...
        6.0780,    6.4160,   15.6100,   8.535,      4.6740,    2.6370,   11.2400,    3.738; ...
        4.1740,    5.7120,   12.8400,   8.231,      3.1000,    4.0480,    8.8020,    3.545; ...
        4.8100,    6.8010,   15.1300,   8.182,      3.7150,    4.3510,   11.7400,    3.780; ...
        5.1110,    8.1670,   16.8900,   8.875,      4.0040,    5.9680,   11.2900,    4.301; ...
        5.1760,    6.1670,   13.0300,   8.315,      3.8800,    2.9430,    9.8780,    3.862; ...
        4.9540,    5.4470,   12.2700,   6.859,      3.6140,    3.2680,    7.6750,    2.977 ];

%       LinMean    2C.Mean    Ph.Mean    PhC.Mean   LinMed     2C.Med     Ph.Mean    PhC.Med
OEF = [ 29.7700,   33.4500,   39.5200,   42.68,     25.2500,   22.1100,   36.3500,   43.24; ...
        24.9300,   34.1900,   41.5800,   42.88,     20.7700,   19.7600,   39.2000,   44.37; ...
        27.0500,   32.0500,   38.7900,   40.12,     21.8100,   18.2800,   35.2800,   40.21; ...
        25.6900,   28.1700,   38.5400,   42.94,     22.1400,   16.6600,   36.8200,   43.47; ...
        25.7500,   23.0300,   40.4300,   43.70,     21.2800,   15.2500,   38.9800,   40.48; ...
        27.9900,   33.2100,   37.5700,   43.91,     23.8000,   20.7300,   33.1300,   44.29; ...
        25.1100,   23.5500,   37.0600,   38.59,     19.8500,   18.4500,   35.2800,   32.57 ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    ERRORS           % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%        LinMean    2C.Mean   Ph.Mean    PhC.Mean    LinMed     2C.Med     Ph.Med     PhC.Med
eR2p = [ 1.9330,    0.7780,         0,         0,    2.8510,    2.8930,         0,         0; ...
         2.8790,    0.8880,         0,         0,    2.9970,    2.7350,         0,         0; ...
         2.7210,    0.7100,         0,         0,    2.1480,    2.8130,         0,         0; ...
         2.7120,    0.7510,         0,         0,    2.4620,    2.7680,         0,         0; ...
         2.6010,    0.8320,         0,         0,    2.6000,    2.8890,         0,         0; ...
         2.6510,    0.7130,         0,         0,    2.9340,    3.0130,         0,         0; ...
         2.2300,    0.7000,         0,         0,    2.2370,    2.0660,         0,         0 ];
     
%        LinMean    2C.Mean   Ph.Mean    PhC.Mean    LinMed     2C.Med    Ph.Med     PhC.Med
eDBV = [ 3.8120,    4.8510,   14.3000,   11.75,      4.5960,    6.4960,   21.3100,    3.406; ...
         5.9700,    5.5210,   15.2500,   14.38,      5.9320,    8.6480,   23.7200,    4.665; ...
         4.3850,    4.9660,   13.0300,   14.35,      4.2330,    7.7400,   16.0700,    3.607; ...
         4.7840,    5.2890,   13.7200,   13.80,      4.6440,    9.1310,   21.7900,    4.009; ...
         4.9360,    4.4660,   17.2400,   14.65,      5.3510,    9.7920,   23.7700,    5.662; ...
         5.8540,    4.5420,   12.3800,   13.81,      5.4560,    7.8000,   18.8500,    4.048; ...
         6.4340,    4.6090,   13.2100,   12.97,      4.6560,    5.3630,   17.7100,    3.733 ];

%        LinMean    2C.Mean    Ph.Mean    PhC.Mean   LinMed     2C.Med     Ph.Med    PhC.Med
eOEF = [ 18.4500,   22.6500,   23.6100,   15.69,     29.3300,   38.0800,   43.7900,  32.51; ...
         16.2400,   26.1900,   24.1200,   16.82,     21.2700,   49.8100,   45.1300,  33.44; ... 
         19.5100,   22.3300,   24.9800,   16.31,     27.8700,   39.5700,   44.3000,  33.79; ...
         16.7400,   22.3000,   23.8700,   15.79,     23.8000,   31.3600,   43.0700,  35.14; ...
         17.3800,   14.5300,   24.7100,   18.48,     23.0300,   18.4500,   45.5900,  39.01; ...
         17.6400,   22.8500,   23.2900,   16.56,     25.4200,   41.0700,   40.0600,  35.91; ...
         17.9900,   18.8400,   23.3200,   16.26,     25.0300,   21.1400,   40.3900,  31.75 ];
     
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    FREE ENERGY        % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% NEGATIVE
%        LinMean    LinMed     2C.Mean   2C.Med    Ph.Mean   Ph.Med
FE = [  ];
     
%        LinMean    LinMed     2C.Mean   2C.Med    Ph.Mean   Ph.Med
RR = [  ];
   
%        LinMean    LinMed     2C.Mean   2C.Med    Ph.Mean   Ph.Med
SN = [ ];


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
    axis([0.5,npts+0.5,0,16.8]);
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
    axis([0.5,npts+0.5,0,53]);
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


