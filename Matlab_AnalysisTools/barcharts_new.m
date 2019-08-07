% Bar Charts New
%
% Actively used as of 2019-08-07
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
legtext = {'uncorr.'            , ...       %  1 - Uncorrected
           '\kappa corr.'       , ...       %  2 - Kappa Correction (Sharan)
           '\kappa,\eta corr.'  , ...       %  3 - KappaEta Correction (Sharan)
           'tan corr.'          , ...       %  4 - Tan Correction (Sharan)
           '\kappa corr.'       , ...       %  5 - Kappa Correction (Jochimsen)
           '\kappa,\eta corr.'  , ...       %  6 - KappaEta Correction (Jochimsen)
           'tan corr.'          , ...       %  7 - Tan Correction (Jochimsen)
           '\kappa corr.'       , ...       %  8 - Kappa Correction (Lauwers)
           '\kappa,\eta corr.'  , ...       %  9 - KappaEta Correction (Lauwers)
           'tan corr.'          , ...       % 10 - Tan Correction (Lauwers)
           };


% Choose which columns to plot
dpts = [1,5,6];

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

%       S 11       S 12       S 13       S 14       S 15       S 16
R2p = [ 3.4730,    3.2940,    3.2620,    2.8670,    3.6710,    2.6810; ...     %  1 - Unc
        5.1780,    4.6300,    4.7300,    4.1540,    5.7200,    3.9390; ...     %  2 - Kappa (sh)
        5.7320,    5.3160,    5.3610,    4.7730,    6.3690,    4.4710; ...     %  3 - KappaEta (sh)
        5.7320,    5.3160,    5.3610,    4.7730,    6.3690,    4.4710; ...     %  4 - Tan (sh)
        4.5540,    4.0720,    4.0690,    3.5640,    4.8770,    3.3590; ...     %  5 - Kappa (jo)
        5.2440,    4.7880,    4.8710,    4.2970,    5.8270,    3.9940; ...     %  6 - KappaEta (jo)
        5.2440,    4.7880,    4.8710,    4.2970,    5.8270,    3.9940; ...     %  7 - Tan (jo)
        5.3720,    4.8010,    4.9080,    4.3290,    5.9130,    4.0810; ...     %  8 - Kappa (la)
        6.9030,    6.8360,    6.6500,    6.1080,    7.4040,    5.5800; ...     %  9 - KappaEta (la)
        6.9030,    6.8360,    6.6500,    6.1080,    7.4040,    5.5800; ...     % 10 - Tan (la)
        ];

%       S 11       S 12       S 13       S 14       S 15       S 16
DBV = [ 7.9340,    6.0260,    5.5530,    5.0640,    7.4570,    7.2760; ...
        6.7840,    5.2900,    5.3470,    4.8340,    8.3220,    6.3030; ...
        6.1050,    4.8900,    4.9820,    4.5450,    7.9350,    6.1020; ...
        6.1050,    4.8900,    4.9820,    4.5450,    7.9350,    6.1020; ...
        7.2930,    5.6670,    5.5350,    5.0340,    8.4070,    6.6040; ...
        6.5380,    5.1400,    5.1700,    4.7070,    8.0750,    6.1330; ...
        6.5380,    5.1400,    5.1700,    4.7070,    8.0750,    6.1330; ...
        6.6230,    5.1850,    5.2450,    4.7680,    8.2700,    6.2670; ...
        5.1780,    4.4980,    4.2950,    4.0450,    6.7960,    5.6310; ...
        5.1780,    4.4980,    4.2950,    4.0450,    6.7960,    5.6310; ...
        ];

%       S 11       S 12       S 13       S 14       S 15       S 16
OEF = [ 15.7200,   22.4800,   23.4800,   22.4200,   15.4200,   18.8500; ...
        29.8000,   33.4000,   33.8800,   32.2100,   20.0700,   28.5200; ...
        36.0800,   39.0500,   39.3800,   37.9200,   23.8500,   32.5500; ...
        36.1500,   33.4700,   34.6800,   35.3000,   36.7700,   33.2200; ...
        25.5400,   28.6200,   29.2700,   28.2500,   16.9800,   24.2700; ...
        32.0000,   35.1100,   35.4100,   34.2100,   21.4900,   29.6900; ...
        36.2300,   33.1000,   35.0800,   35.2800,   35.4800,   41.8300; ...
        31.7000,   35.0800,   35.2400,   34.0700,   21.0900,   29.6900; ...
        49.7800,   51.4800,   52.6400,   50.1100,   34.2900,   42.5200; ...
        35.1700,   31.1200,   32.0600,   33.7900,   30.5400,   24.4500; ...
        ];
    
% % Randomly scale OEF by kappa - DONT ACTUALLY DO THIS!
% OEF(2,:) = OEF(2,:).*0.67;
% OEF(3,:) = OEF(3,:).*0.57;
% OEF(5,:) = OEF(5,:).*0.78;
% OEF(6,:) = OEF(6,:).*0.64;
% OEF(8,:) = OEF(8,:).*0.64;
% OEF(9,:) = OEF(9,:).*0.43;


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    ERRORS           % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


%        VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
eR2p = [  ];
    
%        VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
eDBV = [  ];

%        VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
eOEF = [  ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    FREE ENERGY        % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% NEGATIVE MEDIAN FREE ENERGY
%      VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
FE = [  ];
    
%      VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
RR = [  ];
   
%      VS 1       VS 2       VS 3       VS 4       VS 5       VS 6       VS 7
SN = [  ];


%% Calculations  

% % Convert R2' to dHb
R2p = R2p.*0.0361;

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
figure(1); hold on; grid on;
bar(1:npts,aR2p(dpts),0.6,'FaceColor',defColour(1));
errorbar(1:npts,aR2p(dpts),sR2p(dpts),'k.','LineWidth',2,'MarkerSize',1);
% axis square;
box on; 
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+1.5,0,0.32]);
end
ylabel('dHb content (ml/100g)');
% ylabel('R_2'' (s^-^1)');
xticks(1:length(dpts));
xticklabels(lbls); 
% yticks(0:2:8);
title('GM Mean dHb Estimates')
% xtickangle(45);


% Plot DBV
figure(2); hold on; grid on; 
bar(1:npts,aDBV(dpts),0.6,'FaceColor',defColour(1));
errorbar(1:npts,aDBV(dpts),sDBV(dpts),'k.','LineWidth',2,'MarkerSize',1);
% axis square;
box on;
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+1.5,0,9.8]);
end

ylabel('DBV (%)');
xticks(1:length(dpts));
xticklabels(lbls);
title('GM Mean DBV Estimates')
% xtickangle(45);


% Plot OEF
figure(3); hold on; grid on;
bar(1:npts,aOEF(dpts),0.6,'FaceColor',defColour(1));
errorbar(1:npts,aOEF(dpts),sOEF(dpts),'k.','LineWidth',2,'MarkerSize',1);
% axis square;
box on;
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+0.5,0,64]);
end
ylabel('OEF (%)');
xticks(1:length(dpts));
xticklabels(lbls);
title('GM Mean OEF Estimates')
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