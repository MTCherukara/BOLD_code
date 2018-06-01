% Bar Charts
%
% Actively used as of 2018-05-11

clear;
close all;
setFigureDefaults;

%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    MEAN DATA        % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%       Simple    14.1C-N   14.2C-N   24.2C-N   24.2C-I   14.2C-I
R2p = [ 3.559,    3.401,    3.707,    3.747,    3.661,    3.595; ...
        4.362,    3.833,    4.303,    4.360,    4.225,    4.021; ...
        3.729,    3.242,    3.455,    3.419,    3.430,    3.390; ...
        3.866,    3.803,    4.201,    3.972,    3.919,    3.998; ...
        3.490,    3.364,    3.879,    3.747,    3.696,    3.597; ...
        3.857,    3.731,    4.102,    4.019,    3.968,    3.940; ...
        3.313,    2.827,    2.960,    3.105,    3.077,    2.881 ];
    
%       Simple    14.1C-N  14.2C-N   24.2C-N    24.2C-I  14.2C-I
DBV = [ 5.307,    5.671,    6.607,    6.966,    5.603,    5.237; ...
        7.653,    7.502,    9.875,   10.040,    7.000,    6.393; ...
        5.853,    5.927,    6.901,    6.944,    5.277,    5.082; ...
        6.719,    8.370,   10.140,    9.385,    6.655,    7.046; ...
        6.103,    7.847,    9.741,    9.324,    6.979,    6.835; ...
        6.529,    7.125,    8.724,    8.643,    6.112,    5.953; ...
        6.094,    6.023,    6.625,    7.426,    4.951,    4.485 ];

%       Simple   14.1C-N  14.2C-N   24.2C-N  24.2C-I  14.2C-I
OEF = [ 25.19,   31.01,   24.77,    24.52,   25.30,   26.23; ...
        20.16,   27.47,   20.05,    20.96,   22.48,   22.18; ...
        22.42,   25.56,   21.86,    23.78,   24.10,   23.38; ...
        20.83,   22.67,   18.14,    19.96,   21.50,   20.22; ...
        20.78,   24.73,   17.97,    19.60,   20.93,   20.08; ...
        23.73,   27.32,   21.98,    23.36,   24.86,   23.80; ...
        20.72,   25.88,   22.19,    22.31,   22.73,   23.05 ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    STANDARD DEVIATIONS         % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%        Simple  14.1C-N   14.2C-N   24.2C-N   24.2C-I   14.2C-I
eR2p = [ 0.40,   0.650,    0.898,    0.687,    0.581,    0.722; ...
         0.65,   0.882,    1.342,    1.024,    0.773,    0.949; ...
         0.42,   0.698,    0.925,    0.685,    0.576,    0.736; ...
         0.56,   0.793,    1.203,    0.890,    0.665,    0.858; ...
         0.45,   0.693,    1.046,    0.752,    0.622,    0.778; ...
         0.41,   0.774,    1.065,    0.775,    0.625,    0.816; ...
         0.50,   0.688,    0.860,    0.717,    0.584,    0.719 ];
     
%        Simple   14.1C-N   14.2C-N   24.2C-N   24.2C-I   14.2C-I
eDBV = [ 2.57,    4.389,    4.317,    3.383,    2.336,    2.860; ...
         4.13,    5.050,    6.697,    4.763,    2.988,    3.657; ...
         2.84,    4.288,    4.911,    3.850,    2.288,    2.858; ...
         3.66,    4.568,    5.311,    4.301,    2.595,    3.328; ...
         2.89,    4.133,    5.106,    4.155,    2.444,    3.071; ...
         2.61,    4.495,    5.527,    4.165,    2.451,    3.161; ...
         3.36,    5.089,    5.014,    4.085,    2.340,    2.883 ];

%        Simple   14.1C-N  14.2C-N   24.2C-N  24.2C-I  14.2C-I
eOEF = [ 17.19,   21.39,   16.57,    13.49,   13.36,   16.33; ...
         14.42,   20.42,   14.40,    12.68,   13.48,   15.81; ...
         15.14,   19.86,   16.29,    14.99,   14.40,   16.36; ...
         14.58,   15.62,   11.07,    11.08,   11.64,   12.20; ...
         13.37,   18.18,   11.39,    10.28,   10.82,   12.23; ...
         14.11,   19.11,   14.84,    12.97,   13.68,   15.85; ...
         15.20,   22.24,   17.93,    14.50,   14.58,   17.50 ];

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    RESIDUALS       % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%        Simple   14.1C-N  14.2C-N  24.2C-N  24.2C-I  14.2C-I
FE =  [  1.38,    2.69,    2.56,    3.00,    2.68,    2.44; ...
         2.37,    3.11,    3.35,    4.12,    3.78,    3.19; ...
         1.96,    2.49,    2.49,    3.06,    2.68,    2.35; ...
         2.12,    2.90,    2.92,    3.80,    3.34,    2.97; ...
         1.83,    3.41,    3.26,    4.05,    3.58,    3.16; ...
         1.59,    2.99,    2.89,    3.66,    3.44,    2.89; ...
         1.89,    3.48,    3.33,    4.03,    3.67,    3.18 ];
    


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
dpts = [1,2,4,5];
legtext = {'Linear','1C Model','2C Model','2C Model','2C Model (I)','2C Model (I)'};
npts = length(dpts);
lbls = legtext(dpts);


%% Bar Chart Plotting

% Plot R2p
figure(1); hold on; box on;
bar(1:npts,aR2p(dpts),0.6);
errorbar(1:npts,aR2p(dpts),sR2p(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis([0.5,npts+0.5,0,6.5]);
ylabel('R_2'' (s^-^1)');
xticks(1:length(dpts));
xticklabels(lbls);

% Plot DBV
figure(2); hold on; box on;
bar(1:npts,aDBV(dpts),0.6);
errorbar(1:npts,aDBV(dpts),sDBV(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis([0.5,npts+0.5,0,13.8]);
ylabel('DBV (%)');
xticks(1:length(dpts));
xticklabels(lbls);

% Plot OEF
figure(3); hold on; box on;
bar(1:npts,aOEF(dpts),0.6);
errorbar(1:npts,aOEF(dpts),sOEF(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis([0.5,npts+0.5,0,42]);
ylabel('OEF (%)');
xticks(1:length(dpts));
xticklabels(lbls);

% Plot OEF
figure(4); hold on; box on;
bar(1:npts,aFE(dpts),0.6);
errorbar(1:npts,aFE(dpts),sFE(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis([0.5,length(dpts)+0.5,0,5.5]);
ylabel('Residual');
xticks(1:length(dpts));
xticklabels(lbls);


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
grps = {[1,2];[1,3];[1,4];[2,3];[3,4]};%;[2,3];[2,4];[2,5]};
p_R = c_R([1,2,3,4,6],6);
p_D = c_D([1,2,3,4,6],6);
p_O = c_O([1,2,3,4,6],6);

% Plot R2p significance stars
figure(1);
HR = sigstar(grps,p_R,1);
set(HR,'Color','k')
set(HR(:,2),'FontSize',18);

% Plot DBV significance stars
figure(2);
HD = sigstar(grps,p_D,1);
set(HD,'Color','k')
set(HD(:,2),'FontSize',18);

% Plot OEF significance stars
figure(3);
HO = sigstar(grps,p_O,1);
set(HO,'Color','k')
set(HO(:,2),'FontSize',18);


%% Plotting Lines

% 
% jttr = repmat(-0.06:0.02:0.06,length(dpts),1);
% 
% % Plot R2p
% figure; hold on; box on;
% if rebase
%     ylim([0.4,1.6]);
%     ylabel('\DeltaR_2'' (s^-^1)');
%     plot([0,10],[1,1],'k--','LineWidth',1);
% else
%     ylim([1.8,5.8]);
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
%     ylim([0,17]);
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

% % % Plot Free Energy
% figure; hold on; box on;
% plot(npts,FE(:,dpts)');
% errorbar(npts(:,1),aFE(dpts),sFE(dpts),'k:','LineWidth',3);
% xlim([npts(1)-0.25,npts(end)+0.25]);
% % ylim([-6.2,-4.2]);
% ylabel(Residuals');
% xticks(1:length(dpts));
% xticklabels(lbls);

% % Plot R2p
% FabberBar(R2p(:,datapoints),'R2''',legtext(datapoints));
% 
% % Plot DBV
% FabberBar(DBV(:,datapoints),'DBV',legtext(datapoints));
% 
% % Plot OEF
% if exist('OEF','var')
%     FabberBar(OEF(:,datapoints),'OEF',legtext(datapoints));
% end
% 
