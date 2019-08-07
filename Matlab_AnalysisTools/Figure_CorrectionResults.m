% Figure_CorrectionResults.m
%
% Plot a bar chart showing the errors in DHB, DBV, and OEF estimation, with each
% correction method and Rc distribution
%
% MT Cherukara
% 29 July 2019

clear;
close all;
setFigureDefaults;

% Data

%         Sharan    Frechet   Lauwers
eDHB = [  0.0976    0.0707    0.2138
          0.0294    0.0357    0.0883
          0.0209    0.0584    0.0306
          0.0559    0.0482    0.0940
          0.0203    0.0822    0.0697
          0.0200    0.0589    0.0913
          0.1106    0.1902    0.0905 ];
     
%         Sharan    Frechet   Lauwers
eDBV = [  4.4310    5.3190   13.2830
          1.9580    3.0630    3.0080
          1.5670    2.3220    2.1030
          2.2490    2.5750    3.0830
          1.7810    1.7530    2.7020
          1.8140    2.3910    5.3270
          1.7690    1.7690    2.9600 ];
    
%        Sharan    Frechet   Lauwers
eOEF = [ 32.8600   29.4100   37.4900
         26.9600   26.7400   33.0700
         23.7500   25.2800   28.0500
         28.4200   25.6200   33.3100
         26.2000   23.1700   32.0300
         26.4300   25.2400   35.3100
         22.3000   20.9500   33.2300 ];
     
% %        Sharan    Frechet   Lauwers
% rDHB = [ 35.2300   29.6600   93.2400
%          27.2600   14.8100   41.7800
%          27.5800   32.2800   52.2600 ];
% 
% %        Sharan    Frechet   Lauwers
% rDBV = [ 151.0300  181.4500  373.5700
%           59.9200   74.9300   75.7600
%           43.2700   60.7800  108.3100 ];
% 
% %        Sharan    Frechet   Lauwers
% rOEF = [ 60.6800   59.5600   75.5100
%          55.9800   57.2100   65.8600
%          56.6700   59.6300   73.7600 ];
% %

%% Plot some bar charts

% choose distribution
dnum = 3;
dname = 'Jochimsen';
oth1 = 'Sh';
oth2 = 'Jo';
xlabs = {'Uncorrected','\kappa correction','\kappa,\eta correction',...
         strcat('\kappa(',oth1,')'),strcat('\kappa(',oth1,'),\eta(,',oth1,')'),...
         strcat('\kappa(',oth2,')'),strcat('\kappa(',oth2,'),\eta(,',oth2,')')};

% DHB error
figure;
bar(1:7,eDHB(:,dnum)); hold on; grid on;
ylim([0,0.20]);
ylabel('Error in dHb (ml/100g)');
xticklabels(xlabs);
xtickangle(270+45);

% DBV error
figure;
bar(1:7,eDBV(:,dnum)); hold on; grid on;
ylim([0,6]);
ylabel('Error in DBV (%)');
xticklabels(xlabs);
xtickangle(270+45);

% OEF error
figure;
bar(1:7,eOEF(:,dnum)); hold on; grid on;
ylim([0,40]);
ylabel('Error in OEF (%)');
xticklabels(xlabs);
xtickangle(270+45);

% % DHB error
% figure;
% bar(1:3,eDHB,1); hold on; grid on;
% ylim([0,0.32]);
% legend('Sharan dist.','Jochimsen dist.','Lauwers dist.');
% ylabel('Error in dHb (ml/100g)');
% xticklabels({'Uncorrected','\kappa correction','\kappa, \eta correction'});
% 
% 
% % DBV error
% figure; 
% bar(1:3,eDBV,1); hold on; grid on;
% ylim([0,16]);
% legend('Sharan dist.','Jochimsen dist.','Lauwers dist.');
% ylabel('Error in DBV (%)');
% xticklabels({'Uncorrected','\kappa correction','\kappa, \eta correction'});
% 
% % OEF error
% figure; 
% bar(1:4,eOEF,1); hold on; grid on;
% ylim([0,40]);
% legend('Sharan dist.','Jochimsen dist.','Lauwers dist.');
% ylabel('Error in OEF (%)');
% xticklabels({'Uncorrected','\kappa correction','\kappa,\eta correction','Tan correction'});


%% Same plots but the other way around

% % DHB error
% figure;
% bar(1:3,eDHB',1);
% ylim([0,0.32]);
% legend('Uncorrected','\kappa correction','\kappa, \eta correction');
% ylabel('Error in dHb (ml/100g)');
% xticklabels({'Sharan dist.','Jochimsen dist.','Lauwers dist.'});
% 
% % DBV error
% figure;
% bar(1:3,eDBV',1);
% ylim([0,15]);
% legend('Uncorrected','\kappa correction','\kappa, \eta correction');
% ylabel('Error in DBV (%)');
% xticklabels({'Sharan dist.','Jochimsen dist.','Lauwers dist.'});
% 
% % OEF error
% figure;
% bar(1:3,eOEF',1);
% ylim([0,45]);
% legend('Uncorrected','\kappa correction','\kappa, \eta correction');
% ylabel('Error in OEF (%)');
% xticklabels({'Sharan dist.','Jochimsen dist.','Lauwers dist.'});