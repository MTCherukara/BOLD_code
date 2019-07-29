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
eDHB = [  0.1014    0.0860    0.2807
          0.0286    0.0346    0.0851
          0.0204    0.0614    0.0277 ];
     
%         Sharan    Frechet   Lauwers
eDBV = [  4.9400    6.2200   13.8700
          1.9700    3.2000    3.0000
          1.5300    2.5100    2.0500 ];
    
%        Sharan    Frechet   Lauwers
eOEF = [ 31.0900   29.0900   37.2300
         24.9100   26.0500   33.7400
         17.2700   23.2000   19.6300
         13.0300   16.5400   17.7800 ];
     
%        Sharan    Frechet   Lauwers
rDHB = [ 35.2300   29.6600   93.2400
         27.2600   14.8100   41.7800
         27.5800   32.2800   52.2600 ];

%        Sharan    Frechet   Lauwers
rDBV = [ 151.0300  181.4500  373.5700
          59.9200   74.9300   75.7600
          43.2700   60.7800  108.3100 ];

%        Sharan    Frechet   Lauwers
rOEF = [ 60.6800   59.5600   75.5100
         55.9800   57.2100   65.8600
         56.6700   59.6300   73.7600 ];
%

%% Plot some bar charts

% DHB error
figure;
bar(1:3,eDHB,1); hold on; grid on;
ylim([0,0.32]);
legend('Sharan dist.','Jochimsen dist.','Lauwers dist.');
ylabel('Error in dHb (ml/100g)');
xticklabels({'Uncorrected','\kappa correction','\kappa, \eta correction'});


% DBV error
figure; 
bar(1:3,eDBV,1); hold on; grid on;
ylim([0,16]);
legend('Sharan dist.','Jochimsen dist.','Lauwers dist.');
ylabel('Error in DBV (%)');
xticklabels({'Uncorrected','\kappa correction','\kappa, \eta correction'});

% OEF error
figure; 
bar(1:4,eOEF,1); hold on; grid on;
ylim([0,40]);
legend('Sharan dist.','Jochimsen dist.','Lauwers dist.');
ylabel('Error in OEF (%)');
xticklabels({'Uncorrected','\kappa correction','\kappa,\eta correction','Tan correction'});


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