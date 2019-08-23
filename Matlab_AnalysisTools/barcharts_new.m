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
legtext = {'Core'           , ...       %  1 - Uncorrected
           'Growth'         , ...       %  2 - Kappa Correction (Sharan)
           'Contra'         , ...       %  3 - KappaEta Correction (Sharan)
           'Core'           , ...       %  4 - Tan Correction (Sharan)
           'Growth'         , ...       %  5 - Kappa Correction (Jochimsen)
           'Contra'         , ...       %  6 - KappaEta Correction (Jochimsen)
           };


% Choose which columns to plot
dpts = [1,2,3];

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

%       P 1        P 2        P 3        P 4        P 5        P 6
R2p = [ 2.9560,    6.8540,    3.7560,    4.1650,    5.1550,    8.5070; ...
        4.8800,    6.1140,    4.1190,    6.6520,    5.1460,    4.2770; ...
        3.3530,    3.3590,    3.1190,    3.4390,    3.4410,    3.5150; ...
        4.3380,    9.7720,    6.6260,    5.4090,    7.5480,    8.6810; ...
        7.5240,    9.5100,    6.0270,    9.3630,    7.2760,    7.5140; ...
        5.2470,    5.1180,    4.7150,    5.3350,    4.7610,    5.3850; ...
        ];

%       P 1        P 2        P 3        P 4        P 5        P 6
DBV = [ 7.0700,   14.1010,   13.4780,    6.3570,   10.6150,   13.9830; ...
        6.6970,   10.8780,    9.7490,   11.6960,    9.8770,   17.2650; ...
        9.6910,    9.8080,    8.3550,   11.0900,    8.3410,   14.8100; ...
        2.0590,    9.6300,    9.4960,    4.4130,    8.1060,    9.8740; ...
        6.0090,    8.8610,    7.6950,    9.9550,    8.2020,   11.2300; ...
        8.1330,    6.9170,    6.8430,    9.6720,    7.8320,   10.9370; ...
        ];

%       P 1        P 2        P 3        P 4        P 5        P 6
OEF = [ 45.6100,   16.7600,   26.8700,   26.3600,   26.1300,   30.2000; ...
        33.3400,   23.3100,   22.5300,   34.0700,   27.0800,   23.2000; ...
        21.3500,   20.4500,   21.1200,   20.1600,   23.0400,   20.6400; ...
        65.2500,   31.8800,   21.7300,   60.9200,   37.9400,   46.3900; ...
        54.2200,   35.0200,   33.1800,   43.9400,   39.5200,   29.8900; ...
        31.8900,   30.2400,   29.3300,   27.9600,   29.4000,   25.6000; ...
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