% Bar Charts

clear;


%% Useless Crap
% %         T2native T2w     T2fit     
% overlap = [22.690, 35.030, 39.688; ...
%            30.951, 39.225, 40.989; ...
%            52.201, 54.085, 45.044; ...
%            54.418, 63.095, 42.388  ];
%        
% %      T2native  T2w      T2fit     
% rms = [ 3.21260, 4.34243, 4.27566; ...
%         5.85888, 5.29036, 4.03662; ...
%         2.07075, 3.71644, 2.05237; ...
%         2.65591, 2.65978, 2.75005  ]; 

% %       FLAIR  TE8.VB TE8.EC 3TE.VB 3TE.EC TE6.VB TE6.EC 3TE.F
% DBV = [ 5.40,  6.53,  13.0,  6.11,  6.26,  6.85,  32.9,  6.90; ...
%         6.61,  9.32,  29.9,  17.2,  17.6,  15.5,  37.3,  17.6; ...
%         5.45,  6.21,  5.46,  5.06,  5.06,  5.76,  22.9,  5.26; ...
%         5.50,  7.07,  15.3,  9.42,  9.41,  11.2,  34.6,  10.2 ];
%     
% 
% %       FLAIR  TE8.VB TE8.EC 3TE.VB 3TE.EC TE6.VB TE6.EC 3TE.F
% R2P = [ 2.28,  3.33,  2.14,  2.84,  3.22,  3.56,  1.07,  4.19; ...
%         2.30,  4.75,  1.67,  4.31,  5.23,  4.40,  0.70,  5.98; ...
%         2.08,  2.89,  2.59,  2.49,  2.61,  2.67,  1.26,  3.87; ...
%         2.51,  3.77,  1.81,  3.05,  3.81,  4.00,  0.83,  4.78 ];
    

%% Abstract 
%       FLAIR  Uncorr T1w    T2w    T2fit  3TE u  3TE f
DBV = [ 5.40,  8.10,  9.09,  9.74,  8.44,  6.02,  6.28; ...
        6.61,  8.91,  12.7,  18.0,  12.6, 15.08, 15.53; ...
        5.45,  5.80,  6.74,  8.14,  5.46,  5.31,  5.39; ...
        5.50,  7.07,  8.91,  11.9,  8.44,  9.10,  9.25 ];
    
%       FLAIR  Uncorr T1w    T2w    T2fit
R2p = [ 2.57,  4.72,  3.22,  4.14,  2.14,  2.93,  3.27; ...
        2.61,  5.71,  4.40,  4.66,  1.67,  4.36,  5.18; ...
        2.29,  3.42,  2.67,  3.82,  2.59,  3.12,  3.43; ...
        2.51,  3.79,  3.81,  5.34,  1.81,  3.69,  4.30 ];
    
OEF = 100*R2p./(3.01*DBV);
    
% %       FLAIR  Uncorr T1w    T2w    T2fit
% erR = [  0.6,   0.9,   0.7,   0.6,   0.8; ...
%          0.9,   0.9,   2.0,   1.0,   2.7; ...
%          0.6,   0.5,   0.8,   0.9,   0.8; ...
%          0.8,   0.6,   0.6,   1.0,   0.8 ];
%      
% %       FLAIR  Uncorr T1w    T2w    T2fit
% erD = [  4.1,   3.0,   3.7,   3.8,   3.0; ...
%          3.0,   3.7,   3.9,   4.0,   4.1; ...
%          3.5,   3.1,   3.7,   4.0,   3.8; ...
%          4.0,   4.7,   4.1,   4.7,   4.8 ];


%% Correct R2 Values
% %       FLAIR  Uncorr T2w     T2fit
% DBV = [ 7.53,  6.40,  10.38,  8.93; ...
%         4.80,  8.27,  40.24, 14.43; ...
%         6.45,  5.70,   8.06,  6.48; ...
%         7.98,  6.88,  12.93,  8.69 ];
%     
% %       FLAIR  Uncorr T2w    T2fit
% R2p = [ 3.05,  3.19,  3.45,  3.38; ...
%         3.01,  3.80,  3.20,  3.00; ...
%         3.09,  3.02,  3.50,  3.13; ...
%         3.25,  3.74,  4.65,  4.05 ];


%% Patient Data
% %       GM     ROI    Contra
% DBV = [ 9.86,  9.75,  7.83; ...
%         6.12,  7.38,  5.86 ];
%     
% %       GM     ROI    Contra
% R2p = [ 4.53,  5.80,  3.70; ...
%         3.60,  4.21,  3.27 ];
%     
% %       GM     ROI    Contra
% OEF = [ 15.3,  19.8,  15.7; ...
%         19.5,  19.0,  18.5 ];


%% Motion Correction and Spatial Smoothing
%       FLAIR, NF,    T1w,   T2w,   T2fit
DBV = [ 5.77,  6.48,  6.92,  8.74,  6.73; ... % uncorrected
        5.71,  6.15,  6.53,  8.00,  6.19 ];
    
%       FLAIR, NF,    T1w,   T2w,   T2fit
R2p = [ 2.91,  3.45,  3.56,  3.53,  3.26; ...
        2.77,  3.24,  3.19,  3.21,  3.05 ];
    
%       FLAIR, NF,    T1w,   T2w,   T2fit
OEF = [ 16.69, 17.67, 17.06, 13.39, 16.09; ...
        14.92, 17.46, 16.19, 13.31, 16.31 ];

%% Plotting
% Plot details
datapoints = [1,2,3,4,5];
% legtext = {'Grey-Matter Average','Ischaemic ROI','Contra-Ischaemic ROI'};
legtext = {'with FLAIR','no FLAIR Uncorrected','no FLAIR R1 Correction','no FLAIR R2 Correction','no FLAIR Biexp. Correction'};
% legtext = {'with FLAIR','1 TE, Uncorrected','1 TE, Biexp. Correction','Multi-TE Uncorrected','Multi-TE Biexp. Correction'};
% subnames = {'Presentation';'24h Post Onset'};
subnames = {'No Pre-Processing';'Motion Corrected, Smoothed'};

% Plot R2p
FabberBar(R2p(:,datapoints)','R2''',subnames,legtext);

% Plot DBV
FabberBar(DBV(:,datapoints)','DBV',subnames,legtext);

% Plot OEF
if exist('OEF','var')
    FabberBar(OEF(:,datapoints)','OEF',subnames,legtext);
end
% 
% % Plot R2p
% figure('WindowStyle','Docked');
% hold on; box on;
% bar(R2p(:,datapoints));
% set(gca,'FontSize',18);
% % xlabel('Subjects');
% xticks(1:2);
% xticklabels({'Presentation';'24h Post Onset'});
% ylim([0 6.4]); 
% ylabel('Inferred R_2''');
% legend(legtext{datapoints},'Location','NorthEast');
% 
% 
% % Plot DBV
% figure('WindowStyle','Docked');
% hold on; box on;
% bar(DBV(:,datapoints));
% set(gca,'FontSize',18);
% % xlabel('Subjects');
% xticks(1:2);
% xticklabels({'Presentation';'24h Post Onset'});
% ylim([0 10.8]);
% ylabel('Inferred DBV (%)');
% legend(legtext{datapoints});
% 
% 
% % Plot OEF
% figure('WindowStyle','Docked');
% hold on; box on;
% bar(OEF(:,datapoints));
% set(gca,'FontSize',18);
% % xlabel('Subjects');
% xticks(1:2);
% xticklabels({'Presentation';'24h Post Onset'});
% ylim([0 27]);
% ylabel('Computed OEF (%)');
% legend(legtext{datapoints});
