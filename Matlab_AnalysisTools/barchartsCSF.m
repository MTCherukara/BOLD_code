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

%       FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2fit
R2p = [ 2.780,    2.702,    3.2070    2.9230    2.9100    2.4650    2.7630
        2.989,    2.862,    3.8750    3.3250    3.3240    2.5100    3.0790
        1.982,    1.991,    2.5890    2.5460    2.5190    1.9370    2.3170
        2.134,    2.176,    2.3520    2.2880    2.2700    2.0440    2.0490
        2.379,    2.222,    2.7900    2.5700    2.5300    1.8270    2.2210
    
%       FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2fit
DBV = [  ];

%       FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2fit
OEF = [  ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    STANDARD DEVIATIONS         % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%       FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2fit
eR2p = [  ];
     
%       FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2fit
eDBV = [ ];

%       FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2fit
eOEF = [  ];

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    RESIDUALS       % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%       FLAIR-U   FLAIR-I   NF-U      NF-I      NF-T1w    NF-T2w    NF-T2fit
FE =  [  ];
    


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
dpts = [1,2,4,5];
% legtext = {'14\tau-Linear','14\tau-1C','14\tau-2C','24\tau-2C','24\tau-2C-I','14\tau-2C-I'};
legtext = {'Linear','1C Model','2C Model','2C Model','2C Model (I)','2C Model (I)'};
npts = repmat((1:length(dpts))',1,7);
lbls = legtext(dpts);
jttr = repmat(-0.06:0.02:0.06,length(dpts),1);

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
    ylim([0,17]);
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
