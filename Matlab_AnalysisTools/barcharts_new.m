% Bar Charts New
%
% Actively used as of 2018-06-27
%
% Using FABBER data generated on 27 June 2018

clear;
close all;
setFigureDefaults;

%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    MEAN DATA        % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%       14T.1C    LongT.0C  14T.2C    LongT.2C 
R2p = [ 3.469,    3.463,    3.399,    3.808; ...
        4.075,    4.199,    3.925,    5.044; ...
        3.541,    3.408,    3.363,    3.747; ...
        4.092,    3.741,    3.904,    4.521; ...
        3.795,    3.416,    3.644,    4.111; ...
        4.050,    3.766,    3.891,    4.228; ...
        3.063,    3.159,    3.006,    3.587 ];
   
%       14T.1C    LongT.0C  14T.2C    LongT.2C 
DBV = [ 6.192,    5.261,    5.864,    6.808; ...
        7.220,    7.715,    6.694,   11.920; ...
        6.174,    6.018,    5.955,    7.314; ...
        8.469,    6.711,    7.767,    9.925; ...
        8.618,    6.218,    8.322,    9.302; ...
        7.363,    6.526,    7.118,    8.822; ...
        6.214,    6.009,    5.795,    7.820 ];

%       14T.1C    LongT.0C  14T.2C    LongT.2C 
OEF = [ 36.21,    25.19,    41.33,    25.04; ...
        31.94,    20.07,    41.93,    18.80; ...
        30.82,    22.49,    33.58,    22.19; ...
        25.28,    20.88,    32.84,    19.78; ...
        21.89,    20.80,    23.38,    19.26; ...
        31.73,    23.79,    35.82,    23.18; ...
        25.56,    20.85,    25.26,    21.30 ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    STANDARD DEVIATIONS         % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%        LongT.0C  14T.1C    14T.2C    LongT.2C 
eR2p = [ 0.620,    0.398,    0.675,    0.582; ...
         0.845,    0.648,    0.890,    0.965; ...
         0.665,    0.408,    0.727,    0.574; ...
         0.756,    0.549,    0.795,    0.813; ...
         0.734,    0.452,    0.787,    0.694; ...
         0.749,    0.418,    0.826,    0.642; ...
         0.715,    0.489,    0.726,    0.705  ];
     
%        14T.1C    LongT.0C  14T.2C    LongT.2C 
eDBV = [ 5.593,    2.540,    5.613,    4.840;
         4.932,    4.103,    5.175,    5.810;
         4.892,    2.802,    5.600,    4.331;
         5.040,    3.545,    5.662,    5.236;
         5.215,    2.974,    4.826,    4.428;
         4.709,    2.602,    5.608,    5.090;
         5.352,    3.214,    4.920,    4.724  ];

%        14T.1C    LongT.0C  14T.2C    LongT.2C 
eOEF = [ 24.12,    17.46,    28.13,    16.35;
         22.67,    14.27,    30.95,    11.82;
         23.15,    15.24,    27.28,    13.39
         17.04,    14.60,    24.97,    11.89;
         13.55,    13.51,    15.72,    11.21;
         21.16,    14.41,    24.63,    13.29;
         19.52,    15.49,    19.90,    14.32 ];

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    FREE ENERGY        % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% NEGATIVE
%       14T.1C     LongT.0C   14T.2C     LongT.2C 
FE =  [ 119.3000,   64.3000,  120.7000,   63.8000; ...
        164.7000,   92.4000,  166.4000,   88.0000; ...
        102.4000,   62.7000,  110.4000,   61.3000; ...
        144.5000,   79.2000,  152.4000,   73.6000; ...
        166.1000,   68.3000,  166.4000,   63.5000; ...
        141.8000,   61.0000,  114.5000,   58.9000; ...
        167.2000,   68.6000,  155.4000,   68.8000 ];



%% Calculations  

rebase = 0;

% rebase
if rebase
    eR2p = eR2p./repmat(R2p(:,2),1,4);
    eDBV = eDBV./repmat(DBV(:,2),1,4);
    eOEF = eOEF./repmat(OEF(:,2),1,4);

    R2p = R2p./repmat(R2p(:,2),1,4);
    DBV = DBV./repmat(DBV(:,2),1,4);
    OEF = OEF./repmat(OEF(:,2),1,4);
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
dpts = [2,1,3];
legtext = {'1C. Model','L. Model','2C. Model','2C Linear'};
npts = length(dpts);
lbls = legtext(dpts);


%% Bar Chart Plotting

% Plot R2p
figure(1); hold on; box on;
BR = bar(1:npts,aR2p(dpts),0.6);
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
bar(1:npts,aDBV(dpts),0.6);
errorbar(1:npts,aDBV(dpts),sDBV(dpts),'k.','LineWidth',2,'MarkerSize',1);
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+0.5,0,11.8]);
end
ylabel('DBV (%)');
xticks(1:length(dpts));
xticklabels(lbls);

% Plot OEF
figure(3); hold on; box on;
bar(1:npts,aOEF(dpts),0.6);
errorbar(1:npts,aOEF(dpts),sOEF(dpts),'k.','LineWidth',2,'MarkerSize',1);
if rebase
    axis([0.5,npts+0.5,0,2]);
else
    axis([0.5,npts+0.5,0,48]);
end
ylabel('OEF (%)');
xticks(1:length(dpts));
xticklabels(lbls);

% % Plot Free Energy
% figure(4); hold on; box on;
% bar(1:npts,aFE(dpts),0.6);
% errorbar(1:npts,aFE(dpts),sFE(dpts),'k.','LineWidth',2,'MarkerSize',1);
% axis([0.5,length(dpts)+0.5,0,200]);
% ylabel('-Free Energy');
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
grps = {[1,2];[1,3];[2,3]};%;[2,3];[2,4];[2,5]};
p_R = c_R([1,2,3],6);
p_D = c_D([1,2,3],6);
p_O = c_O([1,2,3],6);

% Plot R2p significance stars
figure(1);
HR = sigstar(grps,p_R,1);
set(HR,'Color','k')
set(HR(:,2),'FontSize',16);
% set(HR(:,2),'String','^n^.^s^.')

% Plot DBV significance stars
figure(2);
HD = sigstar(grps,p_D,1);
set(HD,'Color','k')
set(HD(:,2),'FontSize',16);
% set(HD(:,2),'String','^n^.^s^.')

% Plot OEF significance stars
figure(3);
HO = sigstar(grps,p_O,1);
set(HO,'Color','k')
set(HO(:,2),'FontSize',16);
% set(HO(3,2),'String','^n^.^s^.')


