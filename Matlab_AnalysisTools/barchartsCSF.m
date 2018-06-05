% barchartsCSF.m
%
% Actively used as of 2018-05-25

clear;
close all;
setFigureDefaults;

%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    MEAN DATA        % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%        FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2f    NFU-T2w 
R2p = [  2.874,    3.082,    3.568,    3.545,    3.518,    3.124,    3.443,    3.547; ...
         3.281,    3.396,    4.337,    4.167,    4.162,    3.395,    4.045,    4.134; ...
         2.305,    2.441,    3.144,    3.133,    3.108,    2.552,    2.958,    3.118; ...
         2.139,    2.372,    2.610,    2.751,    2.729,    2.529,    2.542,    2.663; ...
         2.290,    2.982,    3.369,    3.335,    3.307,    2.530,    3.107,    2.878 ];
    
%        FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2f    NFU-T2w
DBV = [  4.730,    5.720,    8.735,    6.249,    6.222,    5.800,    6.128,    8.764; ...
         5.796,    6.125,   10.690,    7.067,    7.079,    6.225,    6.961,   11.480; ...
         4.460,    4.729,    8.124,    5.991,    5.971,    5.306,    5.776,    8.650; ...
         3.831,    4.758,    5.343,    5.185,    5.175,    4.908,    4.887,    5.780; ...
         4.073,    5.037,    7.503,    6.283,    6.256,    5.336,    6.041,    7.671 ];

%        FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2f    NFU-T2w
OEF = [  31.60,    22.01,    22.72,    24.13,    24.23,    23.33,    24.25,    23.40; ...
         32.76,    23.47,    21.70,    26.17,    26.11,    24.92,    25.95,    22.98; ...
         26.47,    20.62,    20.52,    20.97,    20.87,    19.89,    20.62,    18.88; ...
         32.81,    20.15,    19.60,    19.96,    19.90,    19.53,    19.55,    18.37; ...
         32.33,    21.25,    19.18,    20.96,    20.70,    19.52,    20.47,    18.74 ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    STANDARD DEVIATIONS         % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%         FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2f    NFU-T2w
eR2p = [  0.717,    0.675,    1.316,    0.717,    0.712,    0.814,    0.730,    0.930; ...
          0.727,    0.677,    1.554,    0.927,    0.917,    1.173,    0.939,    1.538; ...
          0.734,    0.702,    1.365,    0.674,    0.670,    0.849,    0.712,    1.246; ...
          0.668,    0.648,    1.037,    0.499,    0.488,    0.552,    0.567,    0.897; ...
          0.666,    0.811,    1.181,    0.681,    0.685,    0.948,    0.747,    0.931 ];
      
%         FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2f    NFU-T2w
eDBV = [  4.730,    3.205,    5.795,    3.192,    3.169,    3.153,    3.159,    6.093; ...
          4.963,    3.048,    7.152,    4.010,    3.991,    3.976,    3.958,    8.841; ...
          4.885,    3.189,    4.985,    3.033,    3.025,    3.028,    3.012,    7.769; ...
          4.944,    3.103,    3.551,    2.315,    2.282,    2.290,    2.340,    4.622; ...
          4.743,    3.722,    4.625,    3.121,    3.131,    3.155,    3.121,    5.735 ];

%         FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w   NF-T2f    NFU-T2w
eOEF = [  27.17,    16.08,    17.19,    16.02,    15.96,    17.00,   16.19,    16.56; ...
          24.49,    15.65,    16.64,    18.96,    18.71,    21.18,   18.83,    18.34; ...
          25.37,    18.12,    16.86,    14.71,    14.74,    16.42,   15.21,    18.68; ...
          28.85,    16.73,    15.58,    12.64,    12.34,    12.79,   13.41,    17.92; ...
          26.89,    19.08,    15.24,    13.79,    13.89,    17.12,   14.33,    17.31 ];

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    RESIDUALS       % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%       FLAIR-U  FLAIR-I  NF-U     NF-I     NF-T1w   NF-T2w   NF-T2f   NFU-T2w
FE =  [ 4.38,    3.36,     9.53,    7.84,    7.78,    7.87,    7.78,    8.58; ...
        3.82,    3.13,    12.40,   11.11,   11.13,   11.30,   11.08,   13.14; ...
        4.32,    3.46,    10.81,    8.15,    8.18,    8.76,    8.20,   10.04; ...
        3.23,    2.73,     6.14,    5.24,    5.18,    5.44,    5.43,    5.86; ...
        3.11,    3.48,     7.00,    6.26,    6.33,    6.75,    6.43,    5.31 ];



%% Calculations  

rebase = 0;

% rebase
if rebase
    eR2p = eR2p./repmat(R2p(:,1),1,8);
    eDBV = eDBV./repmat(DBV(:,1),1,8);
    R2p = R2p./repmat(R2p(:,1),1,8);
    DBV = DBV./repmat(DBV(:,1),1,8);
    OEF = OEF./repmat(OEF(:,1),1,8);
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

% % Calculate OEF error by adding R2' and DBV errors in quadrature
% eOEF = OEF.*sqrt(((eR2p./R2p).^2) + ((eDBV./DBV).^2));


%% Plotting Information
ndat = size(R2p,1); % number of datapoints
dpts = [1,3,5,6,7];
legtext = {'FLAIR','FLAIR(I)','nonFLAIR','NF(I)','T_1 seg.','T_2 seg.','T_2 biexp.','T2 corr.'};
npts = repmat((1:length(dpts))',1,ndat);
lbls = legtext(dpts);


%% Bar Chart Plotting

T1col = [0.000, 0.608, 0.698];
T2col = [0.412, 0.569, 0.231];
BEcol = [0.514, 0.118, 0.157];
NFcol = [207, 122, 48]./256;

% Plot R2p
figure(); hold on; box on;
bar(1,aR2p(dpts(1)),0.6,'FaceColor',defColour(1));    % FLAIR
bar(2,aR2p(dpts(2)),0.6,'FaceColor',NFcol);           % non-FLAIR
bar(3,aR2p(dpts(3)),0.6,'FaceColor',T1col);           % T1 weighted
bar(4,aR2p(dpts(4)),0.6,'FaceColor',T2col);           % T2 weighted
bar(5,aR2p(dpts(5)),0.6,'FaceColor',BEcol);           % BE weighted
errorbar(1:5,aR2p(dpts),sR2p(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis([0.5,length(dpts)+0.5,0,5.5]);
ylabel('R_2'' (s^-^1)');
xticks(1:length(dpts));
xticklabels(lbls);


% Plot DBV
figure(2); hold on; box on;
bar(1,aDBV(dpts(1)),0.6,'FaceColor',defColour(1));    % FLAIR
bar(2,aDBV(dpts(2)),0.6,'FaceColor',NFcol);           % non-FLAIR
bar(3,aDBV(dpts(3)),0.6,'FaceColor',T1col);           % T1 weighted
bar(4,aDBV(dpts(4)),0.6,'FaceColor',T2col);           % T2 weighted
bar(5,aDBV(dpts(5)),0.6,'FaceColor',BEcol);           % BE weighted
errorbar(1:5,aDBV(dpts),sDBV(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis([0.5,length(dpts)+0.5,0,13.8]);
ylabel('DBV (%)');
xticks(1:length(dpts));
xticklabels(lbls);

% % Plot OEF
% figure(3); hold on; box on;
% bar(1,aOEF(dpts(1)),0.6,'FaceColor',defColour(1));    % FLAIR
% bar(2,aOEF(dpts(2)),0.6,'FaceColor',defColour(2));    % non-FLAIR
% bar(3,aOEF(dpts(3)),0.6,'FaceColor',T1col);           % T1 weighted
% bar(4,aOEF(dpts(4)),0.6,'FaceColor',T2col);           % T2 weighted
% bar(5,aOEF(dpts(5)),0.6,'FaceColor',BEcol);           % BE weighted
% errorbar(1:5,aOEF(dpts),sOEF(dpts),'k.','LineWidth',2,'MarkerSize',1);
% axis([0.5,length(dpts)+0.5,0,42]);
% ylabel('OEF (%)');
% xticks(1:length(dpts));
% xticklabels(lbls);
% 
% % Plot Residuals
% figure(4); hold on; box on;
% bar(1,aFE(dpts(1)),0.6,'FaceColor',defColour(1));    % FLAIR
% bar(2,aFE(dpts(2)),0.6,'FaceColor',defColour(2));    % non-FLAIR
% bar(3,aFE(dpts(3)),0.6,'FaceColor',T1col);           % T1 weighted
% bar(4,aFE(dpts(4)),0.6,'FaceColor',T2col);           % T2 weighted
% bar(5,aFE(dpts(5)),0.6,'FaceColor',BEcol);           % BE weighted
% errorbar(1:5,aFE(dpts),sFE(dpts),'k.','LineWidth',2,'MarkerSize',1);
% axis([0.5,length(dpts)+0.5,0,15]);
% ylabel('Residual');
% xticks(1:length(dpts));
% xticklabels(lbls);


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

% Pick the comparisons we want 
grps = {[1,2];[1,3];[1,4];[1,5]};%;[2,3];[2,4];[2,5]};
p_R = c_R(1:4,6);
p_D = c_D(1:4,6);
p_O = c_O(1:4,6);

% Plot R2p significance stars
figure(1);
HR = sigstar(grps,p_R,1);
set(HR,'Color','k')
set(HR(:,2),'FontSize',14);
set(HR(3,:),'Color',[1,1,1]);

% Plot DBV significance stars
figure(2);
HD = sigstar(grps,p_D,1);
set(HD,'Color','k')
set(HD(:,2),'FontSize',14);
set(HD(3,:),'Color',[1,1,1]);

% % Plot OEF significance stars
% figure(3);
% HO = sigstar(grps,p_O,1);
% set(HO,'Color','k')
% set(HO(:,2),'FontSize',14);


%% Line Graph Plotting
% jttr = repmat(-0.04:0.02:0.04,length(dpts),1);
% 
% % Plot R2p
% figure; hold on; box on;
% if rebase
%     ylim([0.4,1.6]);
%     ylabel('\DeltaR_2'' (s^-^1)');
%     plot([0,10],[1,1],'k--','LineWidth',1);
% else
%     ylim([0.8,6.2]);
%     ylabel('R_2'' (s^-^1)');
% end
% errorbar(npts+jttr,R2p(:,dpts)',eR2p(:,dpts)','.');
% plot(npts,R2p(:,dpts)');
% errorbar(npts(:,1),aR2p(dpts),sR2p(dpts),'k:','LineWidth',3);
% xlim([npts(1)-0.25,npts(end)+0.25]);
% ylabel('R_2'' (s^-^1)');
% xticks(1:length(dpts));
% xticklabels(lbls);
% 
% % Plot DBV
% figure; hold on; box on;
% if rebase
%     ylim([0.2,1.8]);
%     ylabel('\DeltaDBV');
%     plot([0,10],[1,1],'k--','LineWidth',1);
% else
%     ylim([0,14.5]);
%     ylabel('DBV (%)');
% end
% errorbar(npts+jttr,DBV(:,dpts)',eDBV(:,dpts)','.');
% plot(npts,DBV(:,dpts)');
% errorbar(npts(:,1),aDBV(dpts),sDBV(dpts),'k:','LineWidth',3);
% xlim([npts(1)-0.25,npts(end)+0.25]);
% xticks(1:length(dpts));
% xticklabels(lbls);
% 
% % Plot OEF
% figure; hold on; box on;
% if rebase
%     ylim([0,2]);
%     ylabel('\DeltaOEF');
%     plot([0,10],[1,1],'k--','LineWidth',1);
% else
%     ylim([0,52]);
%     ylabel('OEF (%)');
% end
% errorbar(npts+jttr,OEF(:,dpts)',eOEF(:,dpts)','.');
% plot(npts,OEF(:,dpts)');
% errorbar(npts(:,1),aOEF(dpts),sOEF(dpts),'k:','LineWidth',3);
% xlim([npts(1)-0.25,npts(end)+0.25]);
% 
% xticks(1:length(dpts));
% xticklabels(lbls);
% 
% % % % Plot Free Energy
% % figure; hold on; box on;
% % plot(npts,FE(:,dpts)');
% % errorbar(npts(:,1),aFE(dpts),sFE(dpts),'k:','LineWidth',3);
% % xlim([npts(1)-0.25,npts(end)+0.25]);
% % % ylim([-6.2,-4.2]);
% % ylabel(Residuals');
% % xticks(1:length(dpts));
% % xticklabels(lbls);
% 
% % % Plot R2p
% % FabberBar(R2p(:,datapoints),'R2''',legtext(datapoints));
% % 
% % % Plot DBV
% % FabberBar(DBV(:,datapoints),'DBV',legtext(datapoints));
% % 
% % % Plot OEF
% % if exist('OEF','var')
% %     FabberBar(OEF(:,datapoints),'OEF',legtext(datapoints));
% % end
% % 
