% PartialVolumeLines.m

% Plot line graphs showing how estimates of a parameter (R2') change with
% respect to the partial volume threshold used to determine the ROI, comparing
% subjects, CSF-correction methods, and GM partial volume estimates.

% MT Cherukara
% 18 March 2019

% CHANGELOG:

clear;
% close all;
setFigureDefaults;

% Choose Subject
subj = 5;

% PVEs
PVEs = {'>99%', '>80%', '99-80%', '>60%', '80-50%', '>50%'};
npv = length(PVEs);
pts = [1,2,4,6,3,5];

%% R2p Data
% Dimensions [ PVE x SUBJECT ]

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
data_FP2 = [ 5.5560    4.0310    3.2800    2.4940    3.9240
             5.4970    4.0520    3.1380    2.5000    3.9890
             5.3110    4.6650    2.7090    2.5920    5.1490
             4.8470    4.1050    2.8870    2.5080    3.9740
             4.2880    4.3120    2.7690    2.6570    4.0390
             4.6450    3.6530    2.6510    2.4130    3.5450 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
data_NF2 = [ 5.1130    4.8250    3.7680    3.4120    3.6450
             4.9340    4.8720    3.7780    3.4040    3.6550
             4.4350    6.1970    3.8060    3.2970    3.8400
             4.5640    4.9650    3.5770    3.4480    3.6220
             4.1670    5.1880    3.3550    3.5830    3.6290
             4.3930    4.5710    3.5750    3.0170    3.2690 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
data_NF3 = [ 5.3790    4.9550    3.7670    3.3280    3.7390
             5.1750    5.0040    3.7470    3.3320    3.7570
             4.6130    6.4100    3.6870    3.3900    4.1060
             4.7030    5.1000    3.5040    3.3690    3.7130
             4.2560    5.3390    3.2530    3.5440    3.7220
             4.5260    4.7260    3.6230    3.0000    3.3350 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
data_T1w = [ 5.4390    4.9910    3.7940    3.3690    3.7430
             5.2380    5.0420    3.7570    3.3650    3.7610
             4.6780    6.5110    3.6460    3.3090    4.1280
             4.7580    5.1420    3.5530    3.4100    3.7350
             4.2930    5.4120    3.3260    3.6460    3.8200
             4.5700    4.7580    3.6960    3.0290    3.3470 ];

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
data_T2s = [ 5.3730    4.9500    3.7410    3.2930    3.7020
             5.1960    5.0010    3.7340    3.2970    3.7150
             4.7020    6.4730    3.7120    3.3550    3.9850
             4.7640    5.1120    3.5250    3.3630    3.6950
             4.3220    5.4570    3.3360    3.6610    3.8070
             4.5790    4.7330    3.7270    2.9970    3.3350 ];

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
data_T2f = [ 5.5940    5.1240    3.8260    3.4340    3.8090
             5.3650    5.1720    3.8230    3.4250    3.8310
             4.7470    6.5130    3.8120    3.2880    4.2480
             4.8550    5.2690    3.6110    3.4710    3.8040
             4.3800    5.5100    3.3830    3.7120    3.8830
             4.6670    4.8400    3.7760    3.0760    3.4280 ];
         
         
%% DBV Data
% Dimensions [ PVE x SUBJECT ]

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dDBV_FP2 = [ 9.7940    8.3840    5.8500    5.6860    6.8480
             9.8080    8.3880    5.6930    5.6910    6.9570
             9.7970    8.6480    5.2050    5.7660    8.8250
             9.1410    8.3500    5.6260    5.7430    6.9770
             8.5980    8.3460    5.7250    6.0170    7.3930
             8.9600    7.6120    5.6230    5.8180    7.0290 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dDBV_NF2 = [ 8.2100    9.0390    6.7350    6.6580    7.2940
             8.1740    9.0380    6.8170    6.6460    7.3830
             8.0540    8.9170    7.0640    6.4540    9.1130
             7.9430    8.8510    6.7850    6.7470    7.3980
             7.5640    8.2340    6.7060    7.0920    7.8380
             7.7470    7.4950    7.3500    6.6870    7.1310 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dDBV_NF3 = [ 9.3250    9.7280    7.4070    7.3750    7.7490
             9.2700    9.7100    7.4650    7.4050    7.8760
             9.1120    9.1840    7.6410    7.8350   10.1680
             8.7890    9.5410    7.3580    7.4200    7.8230
             8.2430    8.8880    7.2560    7.6340    8.1570
             8.5510    7.9890    8.0530    7.1140    7.2110 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dDBV_T1w = [ 9.5350    9.6900    7.4240    7.3000    7.5600
             9.4260    9.7000    7.2950    7.2920    7.6150
             9.1120    9.8230    6.9240    7.1610    8.5560
             8.8550    9.5480    7.2500    7.3860    7.6330
             8.3100    8.9440    7.1230    7.7570    8.1570
             8.6440    8.1380    7.7640    7.0590    7.0800 ];

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dDBV_T2s = [ 9.4050    9.7850    7.3690    7.2390    7.7770
             9.3860    9.7680    7.3950    7.2820    7.8000
             9.3330    9.2540    7.4730    7.9060    8.1860
             8.9300    9.5440    7.3160    7.3820    7.7320
             8.3280    8.8720    7.2600    7.7110    8.0660
             8.6410    8.0420    7.7980    7.1530    7.2450 ];

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dDBV_T2f = [ 9.3110    9.4470    7.3030    7.3440    7.6770
             9.0410    9.4220    7.3240    7.2860    7.7350
             8.3240    8.7270    7.3840    6.4580    8.6820
             8.6060    9.2550    7.2140    7.3380    7.7130
             8.1420    8.7710    7.0570    7.6530    8.0970
             8.4070    7.9290    7.6410    7.0660    7.1830 ];

          
%% OEF Data
% Dimensions [ PVE x SUBJECT ]

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dOEF_FP2 = [ 24.6060   21.9220   24.7110   20.7010   22.8830
             24.8030   22.0060   24.4430   20.7520   22.8920
             25.2270   24.3230   23.6170   21.4670   23.4310
             23.7860   22.2490   22.4430   20.4250   22.4270
             22.5500   22.6750   20.5150   20.0940   21.1090
             23.2100   22.0890   19.7280   19.0630   19.9060 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dOEF_NF2 = [ 26.5040   23.4870   22.8970   20.9570   21.0060
             25.2110   23.6230   22.4680   20.7240   20.9800
             21.7410   27.9050   21.1590   17.4770   20.4590
             24.0320   24.0330   20.9880   20.6310   21.1880
             23.1480   24.7210   19.8620   20.4420   20.8190
             23.7450   27.5200   19.6540   18.7780   20.7340 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dOEF_NF3 = [ 26.6950   24.6330   23.5520   21.5860   24.4990
             25.6780   24.8610   23.3230   21.4560   24.4690
             22.9500   31.8950   22.6270   19.6390   23.8310
             24.8940   25.1750   22.2840   21.5030   24.9230
             24.2030   26.0210   21.6530   22.0730   26.0450
             24.6300   29.0250   22.3820   22.7940   24.7900 ];
         
%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dOEF_T1w = [ 26.8590   25.3090   23.8790   22.5180   23.5450
             26.0080   25.4350   24.0080   22.4240   23.4080
             23.8540   29.3450   24.4000   21.0990   20.9450
             25.4890   25.7550   23.4440   22.5090   23.6020
             24.9170   26.6220   23.0350   23.0040   24.2620
             25.2330   28.9200   23.3880   22.7340   23.6270 ];

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dOEF_T2s = [ 26.5480   24.0600   23.2560   21.2170   23.0800
             25.7230   24.2430   23.4630   21.2000   23.0820
             23.4660   29.9070   24.0930   20.9790   23.0180
             26.1340   24.7930   23.6490   22.1110   23.2700
             25.9100   26.4800   23.3020   24.1210   23.8600
             25.8560   28.4040   23.4820   22.1830   24.1030 ];

%            Sub 3     Sub 4     Sub 6     Sub 8     Sub 9
dOEF_T2f = [ 27.6780   26.1720   25.0630   23.4050   24.6840
             26.4840   26.2460   24.5450   23.2390   24.6420
             23.2800   28.6420   22.9630   20.8940   23.7930
             25.5010   26.5280   23.4520   22.9430   24.9840
             24.9360   27.2660   22.9130   22.4540   25.9210
             25.3820   29.3250   21.9600   23.3920   23.8380 ];
          
         
%% Further Analysis

% what do we normalize to:
normdata = dDBV_FP2;                        % all FLAIR
% normdata = repmat(data_FP2(1,:),7,1);       % FLAIR 99%

% normalize
norm_NF2 = dDBV_NF2./normdata;
norm_NF3 = dDBV_NF3./normdata;
norm_T1w = dDBV_T1w./normdata;
norm_T2f = dDBV_T2f./normdata;
norm_T2s = dDBV_T2s./normdata;
norm_FP2 = dDBV_FP2./normdata;

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
% plot(1:npv,data_FP2(pts,subj),'x-','Color',defColour(1));
% hold on;
% plot(1:npv,data_NF2(pts,subj),'x-','Color',defColour(2));
% plot(1:npv,data_NF3(pts,subj),'x-','Color',defColour(3));
% plot(1:npv,data_T1w(pts,subj),'x-','Color',defColour(4));
% plot(1:npv,data_T2s(pts,subj),'x-','Color',defColour(5));
% plot(1:npv,data_T2f(pts,subj),'x-','Color',defColour(6));
% 
% % Labels and stuff
% xlabel('Grey Matter Partial Volume Mask');
% xticklabels(PVEs(pts));
% xlim([0.5,npv+0.5]);
% % ylim([2.0,7.5]);
% ylabel('R_2'' (s^-^1)');
% title(['Subject ',num2str(subj)]);
% legend('FLAIR','NF 2C','NF 3C','NF T1w','NF T2s','NF T2fit',...
%        'Location','NorthEast');

   
% % Plot Lines for DBV
% figure;
% plot(1:npv,dDBV_FP2(pts,subj),'x-','Color',defColour(1));
% hold on;
% plot(1:npv,dDBV_NF2(pts,subj),'x-','Color',defColour(2));
% plot(1:npv,dDBV_NF3(pts,subj),'x-','Color',defColour(3));
% plot(1:npv,dDBV_T1w(pts,subj),'x-','Color',defColour(4));
% plot(1:npv,dDBV_T2s(pts,subj),'x-','Color',defColour(5));
% plot(1:npv,dDBV_T2f(pts,subj),'x-','Color',defColour(6));
% 
% % Labels and stuff
% xlabel('Grey Matter Partial Volume Mask');
% xticklabels(PVEs(pts));
% xlim([0.5,npv+0.5]);
% % ylim([0.0,12.5]);
% ylabel('^ DBV (%)_ ');
% title(['Subject ',num2str(subj)]);
% legend('FLAIR','NF 2C','NF 3C','NF T1w','NF T2s','NF T2fit',...
%        'Location','SouthWest');


% Plot Lines for OEF
figure;
plot(1:npv,dOEF_FP2(pts,subj),'x-','Color',defColour(1));
hold on;
plot(1:npv,dOEF_NF2(pts,subj),'x-','Color',defColour(2));
plot(1:npv,dOEF_NF3(pts,subj),'x-','Color',defColour(3));
plot(1:npv,dOEF_T1w(pts,subj),'x-','Color',defColour(4));
plot(1:npv,dOEF_T2s(pts,subj),'x-','Color',defColour(5));
plot(1:npv,dOEF_T2f(pts,subj),'x-','Color',defColour(6));

% Labels and stuff
xlabel('Grey Matter Partial Volume Mask');
xticklabels(PVEs(pts));
xlim([0.5,npv+0.5]);
% ylim([8,32]);
ylabel('^ OEF (%)_ ');
title(['Subject ',num2str(subj)]);
legend('FLAIR','NF 2C','NF 3C','NF T1w','NF T2s','NF T2fit',...
       'Location','SouthWest');

  
