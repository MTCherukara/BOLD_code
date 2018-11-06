% Bar Charts New
%
% Actively used as of 2018-11-06
%
% Using FABBER data generated on 6 November 2018 (for 2019 ISMRM Abstract)

clear;
close all;
setFigureDefaults;

%% Plotting Information

% key to data array columns
legtext = {'Uncorrected','Scalar \kappa''','Scalar \kappa'',\beta','\kappa''(OEF)','Uncorrected','Scalar \kappa''','Scalar \kappa'',\beta'};
%           1             2                 3                       4

% Choose which columns to plot
dpts = [1,5,2,6];

% Pick pairwise comparisons from DPTS values
grps = {[1,2],[1,3],[1,4]};

% Decide on additional plots
plot_FE = 0;    % Free Energy
plot_RR = 0;    % Median Residuals
plot_SN = 0;    % Model Signal-to-Noise Ratio


%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    DATA             % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
  
%       SVB        SVB        SVB        SVB        VB         VB         VB
%       Uncorr     Const A    Const A,B  Prop A     Uncorr     Const A    Const A,B
R2p = [ 2.7300,    4.9940,    3.3020,    2.8430,    3.1150,    5.4920,    3.8230; ...
        3.0400,    5.3340,    3.7080,    2.9110,    3.4780,    6.1630,    4.2400; ...
        1.9810,    3.6920,    2.4080,    2.1280,    2.4130,    4.2230,    2.8690; ...
        1.7990,    3.4410,    2.2690,    1.8320,    2.0920,    3.9450,    2.5990; ...
        2.6490,    4.7790,    3.1670,    2.3590,    3.4220,    5.7040,    4.1500 ];

%       SVB        SVB        SVB        SVB        VB         VB         VB
%       Uncorr     Const A    Const A,B  Prop A     Uncorr     Const A    Const A,B
DBV = [ 4.3980,    3.7150,    3.9670,    2.9190,    5.9940,    6.7150,    6.2750; ...
        4.6920,    3.9440,    4.2700,    3.0000,    6.8260,    7.3800,    6.8080; ...
        3.5600,    3.4440,    3.4290,    2.6760,    5.4200,    6.2230,    5.5260; ...
        2.7530,    2.8780,    2.9200,    1.8670,    3.8640,    5.0780,    4.2670; ...
        3.4060,    3.5750,    3.2860,    2.4560,    6.3680,    6.9130,    6.6020 ];

%       SVB        SVB        SVB        SVB        VB         VB         VB
%       Uncorr     Const A    Const A,B  Prop A     Uncorr     Const A    Const A,B
OEF = [ 23.6800,   35.4200,   26.3300,   34.1700,   23.7600,   28.3500,   24.6200; ...
        23.7500,   36.2200,   26.7000,   34.4600,   27.7700,   30.8800,   28.6700; ...
        21.1500,   29.2100,   23.5400,   28.0200,   22.2000,   24.9300,   23.8000; ...
        25.4000,   35.7900,   28.2500,   31.4600,   29.1100,   27.8600,   26.9400; ...
        23.3500,   31.1300,   24.6300,   30.6900,   22.5300,   26.5500,   22.1100 ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    ERRORS           % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

     
%        SVB        SVB        SVB        SVB        VB         VB         VB
%        Uncorr     Const A    Const A,B  Prop A     Uncorr     Const A    Const A,B
eR2p = [ 1.7700,    2.9530,    2.0640,    2.0830,    1.7110,    2.0500,    1.9060; ...
         1.9720,    3.2600,    2.3900,    2.0290,    1.6600,    1.9170,    1.8380; ...
         1.5650,    2.7480,    1.8460,    3.4330,    1.5810,    2.0400,    1.8100; ...
         0.9990,    1.6070,    1.1870,    1.4110,    1.5510,    2.0460,    1.6350; ...
         2.4020,    3.9530,    2.7410,    1.8820,    1.7360,    2.2710,    1.8160 ];
     
%        SVB        SVB        SVB        SVB        VB         VB         VB
%        Uncorr     Const A    Const A,B  Prop A     Uncorr     Const A    Const A,B
eDBV = [ 2.8940,    2.4950,    2.6600,    2.1860,    6.8790,    6.9550,    7.2860; ...
         3.2070,    2.7470,    2.8030,    2.2710,    7.0470,    6.0790,    7.3160; ...
         2.3480,    2.3150,    2.2060,    1.9690,    6.9660,    6.9620,    7.0960; ...
         1.8220,    1.8040,    1.8570,    1.3500,    6.2900,    6.3450,    6.0330; ...
         2.2960,    2.3680,    2.1570,    1.8780,    8.1780,    7.5850,    7.4210 ];

%        SVB        SVB        SVB        SVB        VB         VB         VB
%        Uncorr     Const A    Const A,B  Prop A     Uncorr     Const A    Const A,B
eOEF = [ 19.9900,   21.0300,   20.1200,   19.5800,   22.5200,   21.8100,   22.6500; ...
         19.6600,   21.5000,   19.4700,   20.1800,   24.3100,   22.3100,   24.8900; ...
         19.4300,   21.1100,   20.4000,   19.0800,   23.8800,   23.6900,   24.6200; ...
         19.5600,   19.9200,   20.3700,   16.0100,   30.1800,   24.9800,   27.6900; ...
         20.1800,   21.0800,   20.2800,   20.6300,   25.9600,   25.0000,   24.2000 ];

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
    axis([0.5,npts+0.5,0,12.8]);
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


