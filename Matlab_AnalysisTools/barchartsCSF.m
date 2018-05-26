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

%        FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2fit
R2p = [  3.142,    2.980,    3.881,    3.246,    3.219,    2.748,    3.079; ...
         3.548,    3.295,    4.695,    3.870,    3.863,    3.041,    3.628; ...
         2.444,    2.402,    3.330,    2.787,    2.750,    2.181,    2.562; ...
         2.323,    2.308,    2.904,    2.606,    2.573,    2.300,    2.314; ...
         3.156,    2.932,    3.502,    3.083,    3.032,    2.249,    2.685 ];
    
%        FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2fit
DBV = [  6.655,    4.581,   27.11,     4.694,    4.676,    4.412,    4.599; ...
         7.290,    4.680,   25.92,     4.730,    4.727,    4.363,    4.656; ...
         5.287,    4.056,   35.43,     4.484,    4.457,    4.106,    4.341; ...
         5.122,    4.180,   18.83,     4.445,    4.426,    4.189,    4.192; ...
         6.058,    4.203,   10.48,     4.777,    4.697,    4.282,    4.574 ];

%       FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2fit
OEF = [ 20.67,    23.72,    21.72,    25.70,    25.60,    23.59,    24.90; ...
        21.19,    25.62,    21.99,    30.59,    30.56,    26.65,    29.34; ...
        19.88,    21.73,    18.24,    22.34,    22.20,    19.11,    21.34; ...
        19.37,    19.69,    19.78,    20.69,    20.58,    19.63,    19.69; ...
        20.05,    24.04,    19.78,    22.83,    22.49,    19.45,    21.13 ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    STANDARD DEVIATIONS         % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%         FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2fit
eR2p = [  0.750,    0.579,    1.061,    0.683,    0.695,    0.914,    0.767; ...
          0.772,    0.602,    1.527,    0.818,    0.822,    1.201,    0.917; ...
          0.752,    0.585,    1.108,    0.659,    0.672,    0.987,    0.773; ...
          0.707,    0.541,    0.888,    0.452,    0.471,    0.614,    0.611; ...
          0.935,    0.684,    1.070,    0.582,    0.619,    0.981,    0.759 ];
     
%         FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2fit
eDBV = [  4.778,    2.271,   12.990,    2.179,    2.178,    2.204,    2.185; ...
          4.576,    2.220,   12.490,    2.413,    2.412,    2.435,    2.416; ...
          4.714,    2.246,   16.400,    2.176,    2.176,    2.227,    2.190; ...
          4.238,    2.257,    8.384,    1.822,    1.824,    1.873,    1.877; ...
          5.393,    2.407,    5.805,    2.186,    2.261,    2.241,    2.207, ];

%        FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2fit
eOEF = [ 16.29,    15.79,    16.80,    16.15,    16.18,    17.36,    16.44; ...
         14.97,    17.13,    17.38,    20.86,    20.94,    22.08,    21.01; ...
         18.32,    16.55,    15.56,    15.21,    15.27,    17.33,    15.93; ...
         17.94,    13.28,    15.30,    11.54,    11.63,    12.59,    12.62; ...
         19.26,    17.47,    15.36,    13.77,    14.07,    15.89,    14.36 ];

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    RESIDUALS       % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%       FLAIR-U  FLAIR-I  NF-U    NF-I     NF-T1w   NF-T2w   NF-T2fit
FE =  [ 2.91,    2.81,    6.58,    7.42,    7.40,    7.53,    7.41; ...
        2.62,    2.48,    9.61,   10.79,   10.79,   10.81,   10.85; ...
        3.02,    2.92,    6.71,    7.70,    7.69,    8.25,    7.81; ...
        2.60,    2.35,    5.01,    4.67,    4.71,    4.77,    4.76; ...
        3.08,    2.88,    5.92,    6.17,    6.22,    6.24,    6.27 ];
    


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


%% Plotting

% Plot details
ndat = size(R2p,1); % number of datapoints
dpts = [1,2,3,4];
legtext = {'FLAIR','FLAIR I','NonFLAIR','NonFLAIR I','T1w Corr.','T2w Corr.','T2fit Corr.'};
npts = repmat((1:length(dpts))',1,ndat);
lbls = legtext(dpts);
jttr = repmat(-0.04:0.02:0.04,length(dpts),1);

% Plot R2p
figure; hold on; box on;
if rebase
    ylim([0.4,1.6]);
    ylabel('\DeltaR_2'' (s^-^1)');
    plot([0,10],[1,1],'k--','LineWidth',1);
else
    ylim([1.8,5.8]);
    ylabel('R_2'' (s^-^1)');
end
errorbar(npts+jttr,R2p(:,dpts)',eR2p(:,dpts)','.');
plot(npts,R2p(:,dpts)');
errorbar(npts(:,1),aR2p(dpts),sR2p(dpts),'k:','LineWidth',3);
xlim([npts(1)-0.25,npts(end)+0.25]);
ylabel('R_2'' (s^-^1)');
xticks(1:length(dpts));
xticklabels(lbls);

% Plot DBV
figure; hold on; box on;
if rebase
    ylim([0.2,1.8]);
    ylabel('\DeltaDBV');
    plot([0,10],[1,1],'k--','LineWidth',1);
else
    ylim([0,8]);
    ylabel('DBV (%)');
end
errorbar(npts+jttr,DBV(:,dpts)',eDBV(:,dpts)','.');
plot(npts,DBV(:,dpts)');
errorbar(npts(:,1),aDBV(dpts),sDBV(dpts),'k:','LineWidth',3);
xlim([npts(1)-0.25,npts(end)+0.25]);
xticks(1:length(dpts));
xticklabels(lbls);

% Plot OEF
figure; hold on; box on;
if rebase
    ylim([0,2]);
    ylabel('\DeltaOEF');
    plot([0,10],[1,1],'k--','LineWidth',1);
else
    ylim([0,52]);
    ylabel('OEF (%)');
end
errorbar(npts+jttr,OEF(:,dpts)',eOEF(:,dpts)','.');
plot(npts,OEF(:,dpts)');
errorbar(npts(:,1),aOEF(dpts),sOEF(dpts),'k:','LineWidth',3);
xlim([npts(1)-0.25,npts(end)+0.25]);

xticks(1:length(dpts));
xticklabels(lbls);

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
