% PartialVolumeLines.m

% Plot line graphs showing how estimates of a parameter (R2') change with
% respect to the partial volume threshold used to determine the ROI, comparing
% subjects, CSF-correction methods, and GM partial volume estimates.

% MT Cherukara
% 18 March 2019

% CHANGELOG:

clear;
setFigureDefaults;

% Choose Subject
subj = 5;

% PVEs
PVEs = {'99', '90', '80', '70', '60', '50'};
npv = length(PVEs);

%% R2p Data
% Dimensions [ PVE x SUBJECT ]

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
data_FP2 = [ 5.3500    3.8460    3.1810    2.3980    3.7090
             5.3400    3.8540    3.1810    2.4020    3.7310
             5.2850    3.8770    3.0490    2.3990    3.7650
             4.8810    3.9010    2.8320    2.3740    3.7460
             4.6710    3.9350    2.7680    2.3960    3.7760
             4.4730    3.5390    2.4560    2.2620    3.2340
             4.2340    4.2120    2.6220    2.4960    3.9440 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
data_NF2 = [ 6.1620    5.0850    4.3630    3.8400    3.9150
             6.1130    5.0960    4.3730    3.8380    3.9450
             5.9080    5.1460    4.2700    3.8450    3.9470
             5.5870    5.2320    4.0880    3.8020    3.9200
             5.3060    5.3190    3.9450    3.8630    3.9580
             5.0510    4.5760    3.7080    3.1030    3.3480
             4.7890    5.7230    3.6060    3.9190    4.0300 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
data_NF3 = [ 2.8760    4.1930    2.7070    2.8030    2.7110
             2.8520    4.1900    2.6960    2.7870    2.7160
             2.8480    4.2430    2.6020    2.8090    2.7450
             3.0500    4.3620    2.7240    2.8330    2.7810
             3.2440    4.6270    2.8480    2.9280    2.8160
             3.2380    4.4700    3.4680    3.0180    3.1650
             3.3040    6.1100    2.9520    3.1120    3.1200 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
data_T1w = [ 3.0320    4.0080    2.6760    2.7370    2.5790
             2.9680    3.9980    2.6600    2.7460    2.5930
             2.8550    4.0250    2.5740    2.7480    2.6210
             2.8940    4.1620    2.6420    2.7590    2.6920
             2.9610    4.4330    2.6970    2.7500    2.7510
             2.9620    4.3440    3.2790    2.9420    3.0530
             2.9490    5.8810    2.9270    2.8220    3.0190 ];

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
data_T2s = [ 3.2300    4.2110    2.9890    2.8110    2.4330
             3.2170    4.2110    2.9800    2.8040    2.4400
             2.9610    4.2440    3.0070    2.7830    2.4620
             2.9430    4.3690    2.8430    2.7760    2.4970
             3.0310    4.5690    2.8700    2.8080    2.5910
             3.1270    4.6630    3.3830    3.0600    3.0540
             3.1070    5.7990    2.9460    2.8820    3.0950 ];

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
data_T2f = [ 2.9460    3.9880    2.7120    2.7410    3.3460
             2.9430    4.0140    2.7040    2.7230    3.3430
             2.8700    4.0400    2.6810    2.7580    3.3660
             2.7710    4.1620    2.8600    2.7740    3.3570
             2.7840    4.4730    2.9320    2.7830    3.3680
             2.8330    4.3870    3.5030    3.0510    3.7770
             2.8110    6.1030    3.1670    2.8690    3.4150 ];
         
         
%% DBV Data
% Dimensions [ PVE x SUBJECT ]

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dDBV_FP2 = [  9.1820    8.2720    6.0360    5.1290    6.1150
              9.1930    8.2840    6.0480    5.1270    6.1410
              9.1900    8.3210    5.8500    5.1090    6.1870
              8.6270    8.3060    5.5950    5.0640    6.1830
              8.4450    8.2810    5.4610    5.0490    6.2220
              8.3280    7.6420    4.7210    5.2720    6.0950
              8.0970    8.3060    5.4120    5.0340    6.6350 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dDBV_NF2 = [ 11.8550   10.4380    9.8280    8.5800    8.3920
             11.8130   10.4340    9.8760    8.5900    8.4100
             11.5480   10.4030    9.6510    8.5550    8.4340
             10.9300   10.2790    9.3240    8.4630    8.3860
             10.5120   10.1530    9.0890    8.6190    8.3700
             10.2280    8.4240    9.4000    7.9020    7.8960
              9.7910    9.2280    8.6370    8.8990    8.4420 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dDBV_NF3 = [ 11.2820   10.2620   10.1520    7.9970    8.0900
             11.2760   10.2640   10.1240    7.9960    8.1120
             10.9400   10.2320    9.9020    7.9700    8.1120
             10.3840   10.0940    9.3140    7.9270    7.9640
              9.9600    9.9630    9.0310    7.9490    7.8470
              9.5970    8.0160    9.0610    6.8990    6.7980
              9.1280    8.7400    8.2680    7.9820    7.3870 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dDBV_T1w = [ 11.0650   10.1370    9.7570    7.9460    7.8170
             11.1080   10.1430    9.7750    7.9480    7.8310
             10.7150   10.1020    9.5850    7.9430    7.8090
             10.1820    9.9540    8.8640    7.8450    7.6760
              9.7430    9.7870    8.5980    7.8940    7.5400
              9.3390    7.9170    8.7070    6.8390    6.6470
              8.8780    8.5750    7.9130    7.8160    6.9980 ];

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dDBV_T2s = [ 11.4870   10.5410   10.3200    7.8090    8.0200
             11.4310   10.5430   10.3060    7.8030    8.0310
             11.0690   10.4950    9.9440    7.7870    7.9930
             10.3550   10.3330    9.1840    7.7270    7.8480
              9.9240   10.1460    8.8980    7.7780    7.7100
              9.5560    8.2230    8.9400    6.7750    6.6670
              9.0370    8.8430    8.0890    7.8410    7.0890 ];

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dDBV_T2f = [ 11.1530   10.2680   10.4460    7.9450    9.6850
             11.0830   10.2660   10.4410    7.9420    9.6830
             10.8400   10.2070   10.0360    7.9180    9.6460
             10.2380   10.0340    9.2630    7.8520    9.4930
              9.8630    9.8810    8.9050    7.9680    9.3640
              9.5060    8.0330    8.9570    6.9490    8.6630
              9.0630    8.6080    8.0510    8.1260    8.7950 ];

          
%% OEF Data
% Dimensions [ PVE x SUBJECT ]

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dOEF_FP2 = [ 22.8290   18.9690   22.9070   20.3350   22.1600
             22.7910   18.9670   22.9070   20.3560   22.1790
             22.8370   18.9740   22.7470   20.4130   22.0670
             22.6540   19.1400   22.1450   20.2700   21.9440
             21.9880   19.3100   21.9680   20.4660   22.0100
             21.1790   19.1380   20.9530   18.2930   19.0040
             20.7330   20.5230   20.7450   21.0580   21.3730 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dOEF_NF2 = [ 17.0230   18.3180   15.9110   16.2700   17.0580
             16.9730   18.3450   15.8700   16.2040   17.0870
             15.9070   18.5970   16.1870   16.2550   17.0780
             16.0220   19.1270   15.9350   16.3660   17.0480
             16.5610   19.5740   16.1790   16.3340   17.1350
             16.8160   22.9300   15.3600   15.0580   15.7340
             16.7520   22.6000   15.9760   16.2630   16.5840 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dOEF_NF3 = [ 25.1180   21.9470   20.1680   16.1280   18.9900
             24.9190   22.0200   20.2640   16.1310   18.9960
             24.5130   21.9810   19.7320   16.1770   18.8270
             22.5020   21.8030   19.4370   16.1880   18.6820
             21.2920   21.7410   18.8780   16.5600   18.7360
             20.6780   21.7520   20.4860   17.1930   20.4540
             19.5940   21.8710   17.9670   17.0760   18.7120 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dOEF_T1w = [ 24.0060   21.9080   19.9790   16.8360   19.6060
             23.7030   21.9470   20.0980   16.8230   19.6950
             23.2650   21.9580   19.8460   16.7890   19.7300
             21.5830   21.9900   20.1390   16.6560   19.4990
             20.6860   21.9940   19.4220   16.5770   19.5690
             20.3760   22.3430   20.8100   17.4580   21.3180
             19.5270   22.9350   18.7360   16.6140   20.0110 ];

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dOEF_T2s = [ 23.8520   20.7160   18.9130   15.6830   19.6710
             23.9670   20.7520   19.0140   15.7290   19.6640
             22.9910   20.7930   19.1260   15.7760   19.5060
             21.8450   20.8840   19.1050   15.6440   19.4510
             20.7270   21.0120   18.8820   15.8230   19.3560
             20.1230   22.1450   20.7530   16.9060   21.2840
             19.1940   22.4630   18.5780   16.5420   19.0100 ];

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dOEF_T2f = [ 26.6970   22.4640   19.3550   16.4880   18.1690
             26.7170   22.5470   19.4620   16.4310   18.1900
             25.9650   22.5720   19.0170   16.5860   18.2040
             23.1650   22.4330   19.5610   16.5390   18.0660
             21.9330   22.5190   18.8220   16.5690   17.9360
             20.5300   23.2300   20.6080   17.3040   18.7370
             19.0090   22.9600   18.1960   16.7230   17.9080 ];
          
         
%% Further Analysis

% what do we normalize to:
normdata = dOEF_FP2;                        % all FLAIR
% normdata = repmat(data_FP2(1,:),7,1);       % FLAIR 99%

% normalize
norm_NF2 = dOEF_NF2./normdata;
norm_NF3 = dOEF_NF3./normdata;
norm_T1w = dOEF_T1w./normdata;
norm_T2f = dOEF_T2f./normdata;
norm_T2s = dOEF_T2s./normdata;
norm_FP2 = dOEF_FP2./normdata;

% compute sum of square differences
diffs = [ sum( (norm_FP2 - norm_NF2).^2, 1 ) ; ...
          sum( (norm_FP2 - norm_NF3).^2, 1 ) ; ...
          sum( (norm_FP2 - norm_T1w).^2, 1 ) ; ...
          sum( (norm_FP2 - norm_T2s).^2, 1 ) ; ...
          sum( (norm_FP2 - norm_T2f).^2, 1 ) ];

% find which index corresponds to the minimum difference
[~,mins] = min(diffs);

% correction names
corrects = {'2C (no correction)','3C Free Fitting','3C T1w CSF','3C T2w CSF','3C T2-fit CSF'};

% print results:
for ss = 1:5
    disp(['Subject ',num2str(ss),' best correction: ',corrects{mins(ss)}]);
end


%% Plot Lines for R2p
% figure;
% plot(1:npv,data_FP2(1:6,subj),'x-','Color',defColour(1));
% hold on;
% plot(1:npv,data_NF2(1:6,subj),'x-','Color',defColour(2));
% plot(1:npv,data_NF3(1:6,subj),'x-','Color',defColour(3));
% plot(1:npv,data_T1w(1:6,subj),'x-','Color',defColour(4));
% plot(1:npv,data_T2s(1:6,subj),'x-','Color',defColour(5));
% plot(1:npv,data_T2f(1:6,subj),'x-','Color',defColour(6));
% 
% % Labels and stuff
% xlabel('GM PV Threshold (%)');
% xticklabels(PVEs);
% xlim([0.5,npv+0.5]);
% % ylim([2.0,7.5]);
% ylabel('R_2'' (s^-^1)');
% title(['Subject ',num2str(subj)]);
% legend('FLAIR','NF 2C','NF 3C','NF T1w','NF T2s','NF T2fit',...
%        'Location','NorthEast');

   
%% Plot Lines for DBV
% figure;
% plot(1:npv,dDBV_FP2(1:6,subj),'x-','Color',defColour(1));
% hold on;
% plot(1:npv,dDBV_NF2(1:6,subj),'x-','Color',defColour(2));
% plot(1:npv,dDBV_NF3(1:6,subj),'x-','Color',defColour(3));
% plot(1:npv,dDBV_T1w(1:6,subj),'x-','Color',defColour(4));
% plot(1:npv,dDBV_T2s(1:6,subj),'x-','Color',defColour(5));
% plot(1:npv,dDBV_T2f(1:6,subj),'x-','Color',defColour(6));
% 
% % Labels and stuff
% xlabel('GM PV Threshold (%)');
% xticklabels(PVEs);
% xlim([0.5,npv+0.5]);
% ylim([0.0,12.5]);
% ylabel('^ DBV (%)_ ');
% title(['Subject ',num2str(subj)]);
% legend('FLAIR','NF 2C','NF 3C','NF T1w','NF T2s','NF T2fit',...
%        'Location','SouthWest');


%% Plot Lines for OEF
% figure;
% plot(1:npv,dOEF_FP2(1:6,subj),'x-','Color',defColour(1));
% hold on;
% plot(1:npv,dOEF_NF2(1:6,subj),'x-','Color',defColour(2));
% plot(1:npv,dOEF_NF3(1:6,subj),'x-','Color',defColour(3));
% plot(1:npv,dOEF_T1w(1:6,subj),'x-','Color',defColour(4));
% plot(1:npv,dOEF_T2s(1:6,subj),'x-','Color',defColour(5));
% plot(1:npv,dOEF_T2f(1:6,subj),'x-','Color',defColour(6));
% 
% % Labels and stuff
% xlabel('GM PV Threshold (%)');
% xticklabels(PVEs);
% xlim([0.5,npv+0.5]);
% ylim([8,32]);
% ylabel('^ OEF (%)_ ');
% title(['Subject ',num2str(subj)]);
% legend('FLAIR','NF 2C','NF 3C','NF T1w','NF T2s','NF T2fit',...
%        'Location','SouthWest');

  



