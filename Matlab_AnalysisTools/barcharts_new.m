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
legtext = {'SDR','L corr.','New Model','New Model','NL corr.','SDR SVB','tan SVB'};
%           1     2         3           4           5          6         7 

% Choose which columns to plot
dpts = [1,2,5];

% Pick pairwise comparisons from DPTS values
grps = {[1,2],[1,3]};

% Decide on additional plots
plot_FE = 0;    % Free Energy (Median)
plot_RR = 0;    % Median Residuals (Absolute)
plot_SN = 0;    % Model Signal-to-Noise Ratio


%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    DATA             % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
  

% GREY MATTER MASK >80%
%        Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
R2p = [  5.2170,    4.1690,    3.3880,    2.9000,    4.0390; ...
         9.8600,    7.1360,    6.0720,    4.7960,    7.2480; ...
        10.2340,    7.6170,    6.1070,    4.7950,    7.0010; ...
         9.7580,    7.1210,    5.8170,    4.6340,    6.9860; ...
         5.2170,    4.1690,    3.3880,    2.9000,    4.0390; ...
         4.2400,    3.0730,    2.4660,    1.9620,    2.9460; ...
         4.2400,    3.0730,    2.4660,    1.9620,    2.9460 ];       

%        Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
DBV = [  9.6380,    9.2650,    6.9690,    7.8670,    8.1920; ...
         6.9010,    6.0090,    4.9830,    5.0190,    6.5890; ...
        12.9010,   11.3460,    8.6230,    8.4170,    9.3660; ...
         7.0210,    8.1740,    6.9570,    7.8040,    6.9330; ...
         9.6380,    9.2650,    6.9690,    7.8670,    8.1920; ...
         5.1020,    4.3650,    3.5350,    2.7740,    4.5690; ...
         5.1020,    4.3650,    3.5350,    2.7740,    4.5690 ];

%       Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
OEF = [ 20.2200,   16.9400,   18.7500,   16.0600,   18.2700; ...
        45.5200,   38.1900,   37.0900,   31.3600,   34.1300; ...
        29.8300,   23.5900,   25.2700,   21.9700,   23.8300; ...
        39.0400,   29.9000,   28.8700,   24.4800,   26.8300; ...
        26.8000,   22.6400,   25.4400,   21.7800,   24.3300; ...
        27.2100,   23.1800,   24.2500,   25.1300,   20.2400; ...
        32.3800,   27.0200,   25.8300,   25.4300,   23.2800 ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    ERRORS           % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

      
%        Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
eR2p = [ 3.3220,    3.2870,    2.5780,    2.3390,    3.2010; ...
         5.1150,    4.4890,    3.6940,    2.7560,    5.6350; ...
         5.6370,    5.2910,    3.9730,    3.2970,    6.0110; ...
         5.0650,    4.6230,    3.6780,    3.0660,    5.6690; ...
         3.3220,    3.2870,    2.5780,    2.3390,    3.2010 ];
     
%         Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
eDBV = [  8.4520,    9.5530,    7.7770,    9.6040,    8.9070; ...
          5.6010,    5.5760,    4.4050,    4.7560,    6.1120; ...
         10.7910,   10.6850,    8.4240,    8.9680,    8.8690; ...
          6.7870,    8.7360,    7.5940,    8.4370,    7.6700; ...
          8.4520,    9.5530,    7.7770,    9.6040,    8.9070 ];

%        Sub 3      Sub 4      Sub 6      Sub 8      Sub 9  
eOEF = [ 13.8700,   14.4300,   15.1900,   14.1500,   14.6400; ...
         20.1100,   20.9300,   21.0100,   18.5300,   20.5300; ...
         20.0000,   18.7500,   19.1500,   17.6400,   18.7800; ...
         24.4600,   23.9300,   22.9800,   20.0800,   23.4000; ...
         18.8100,   17.9500,   20.2100,   17.6600,   18.9100 ];

      
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

% Convert R2' to dHb
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
figure(1); hold on; box on; grid on;
bar(1:npts,aR2p(dpts),0.6,'FaceColor',defColour(1));
errorbar(1:npts,aR2p(dpts),sR2p(dpts),'k.','LineWidth',2,'MarkerSize',1);
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+0.5,0,10.6]);
end
ylabel('dHb content (ml/100g)');
xticks(1:length(dpts));
xticklabels(lbls); 
% xtickangle(45);


% Plot DBV
figure(2); hold on; box on; grid on;
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
% xtickangle(45);


% Plot OEF
figure(3); hold on; box on; grid on;
bar(1:npts,aOEF(dpts),0.6,'FaceColor',defColour(1));
errorbar(1:npts,aOEF(dpts),sOEF(dpts),'k.','LineWidth',2,'MarkerSize',1);
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+0.5,0,47]);
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

% % Plot R2p significance stars
% figure(1);
% HR = sigstar(grps,p_R,1);
% set(HR,'Color','k')
% set(HR(:,2),'FontSize',18);
% 
% % Plot DBV significance stars1
% figure(2);
% HD = sigstar(grps,p_D,1);
% set(HD,'Color','k')
% set(HD(:,2),'FontSize',18);
% 
% % Plot OEF significance stars
% figure(3);
% HO = sigstar(grps,p_O,1);
% set(HO,'Color','k')
% set(HO(:,2),'FontSize',18);

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