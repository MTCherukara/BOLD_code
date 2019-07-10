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
legtext = {'FP-2C','NF-2C','NF-3C','NF-T1','NF-T2','NF-BF','NF-FC'};
%           1       2       3       4       5       6       7      .


% Choose which columns to plot
dpts = [1,2,3,4,5,6];

% Pick pairwise comparisons from DPTS values
grps = {[1,2],[1,3],[1,4],[1,5],[1,6]};

% Decide on additional plots
plot_FE = 0;    % Free Energy (Median)
plot_RR = 0;    % Median Residuals (Absolute)
plot_SN = 0;    % Model Signal-to-Noise Ratio


%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    DATA             % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


%       Sub3       Sub4       Sub6       Sub8       Sub9
R2p = [ 3.6650,    2.3840,    2.3440,    1.8270,    2.0400; ...
        3.2990,    3.1910,    3.0050,    2.3520,    2.5060; ...
        4.4040,    3.6650,    3.3050,    2.4530,    2.6810; ...
        3.4180,    3.2540,    3.0080,    2.3140,    2.5370; ...
        3.5080,    3.2620,    3.0770,    2.3590,    2.5550; ...
        3.5610,    3.2570,    3.0640,    2.3390,    2.5370; ...
        3.2800,    3.3740,    2.7180,    2.1840,    2.5860; ...
        ];

%       Sub3       Sub4       Sub6       Sub8       Sub9
DBV = [ 5.2560,    4.0590,    4.1580,    3.4940,    3.9260; ...
        6.1350,    7.5960,    4.4220,    3.6150,    4.5700; ...
        5.2810,    6.0020,    4.4500,    3.3690,    3.9280; ...
        7.7980,    8.8400,    4.8170,    3.8290,    4.7070; ...
        7.2370,    8.7310,    4.5930,    3.6730,    4.6600; ...
        7.0660,    8.9520,    4.5820,    3.6650,    4.7520; ...
        8.5440,    8.0510,    5.6550,    4.3760,    4.7500; ...
        ];

%       Sub3       Sub4       Sub6       Sub8       Sub9
OEF = [ 21.5300,   17.9000,   17.9300,   16.1400,   15.1000; ...
        23.6400,   18.1900,   23.4200,   23.8600,   21.3500; ...
        27.9200,   20.1200,   24.6400,   23.8800,   21.0800; ...
        23.2800,   17.2800,   22.4200,   22.7200,   19.6800; ...
        24.1200,   17.8300,   23.0000,   23.2900,   20.2000; ...
        24.5900,   17.3100,   22.9000,   23.0200,   19.8500; ...
        19.8600,   18.0200,   19.9800,   20.5100,   19.2600; ...
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
    axis([0.5,npts+0.5,0,9.8]);
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