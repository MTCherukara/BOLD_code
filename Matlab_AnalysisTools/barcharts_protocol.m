% barcharts_protocol.m
%
% Actively used as of 2018-10-23

clear;
close all;
setFigureDefaults;

%% Plotting Information

% FAT SATURATION - 80x80 MATRIX    FAT SATURATION - 96x96 MATRIX    WATER EXCITATION - 80x80 MATRIX  WATER EXCITATION - 96x96 MATRIX
%  FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2
%   1         2           3          4         5           6          7         8           9          10        11          12

% Choose which columns to plot
dpts = [1,3,4,6];

% Labels
% lbls = {'F.S. 80mat';'F.S. 96mat';'W.E. 80mat';'W.E. 96mat'};
% lbls = {'FLAIR 80mat';'NF 80mat';'NFC 80mat';'FLAIR 96mat';'NF 96mat';'NFC 96mat'};
lbls = {'FLAIR 80mat';'NFC 80mat';'FLAIR 96mat';'NFC 96mat'};


%% Data

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    MEAN DATA        % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%       FAT SATURATION - 80x80 MATRIX    FAT SATURATION - 96x96 MATRIX    WATER EXCITATION - 80x80 MATRIX  WATER EXCITATION - 96x96 MATRIX
%        FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2
R2p = [  4.2900,   11.8800,    8.5630,    3.5940,   12.1600,    8.3350,    3.8820,   11.7500,    8.6480,    3.8330,   11.7400,    8.4440 ];
    
%       FAT SATURATION - 80x80 MATRIX    FAT SATURATION - 96x96 MATRIX    WATER EXCITATION - 80x80 MATRIX  WATER EXCITATION - 96x96 MATRIX
%        FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2
DBV = [  7.7150,   29.1200,    7.5020,    6.5190,   26.9700,    7.5700,    7.0590,   29.6100,    7.4280,    7.2960,   28.1600,    7.4790 ];

%       FAT SATURATION - 80x80 MATRIX    FAT SATURATION - 96x96 MATRIX    WATER EXCITATION - 80x80 MATRIX  WATER EXCITATION - 96x96 MATRIX
%        FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2 
OEF = [  21.4100,  19.3500,   35.8500,    22.4200,  19.8100,    34.8000,   21.8100,  17.5800,    36.4600,   20.7200,  18.7500,    35.6800 ];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % %    STANDARD DEVIATIONS        % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%        FAT SATURATION - 80x80 MATRIX    FAT SATURATION - 96x96 MATRIX    WATER EXCITATION - 80x80 MATRIX  WATER EXCITATION - 96x96 MATRIX
%         FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2
eR2p = [  2.482,    9.270,      4.173,     2.408,    9.174,      4.159,     2.772,    9.440,      4.171,     2.509,    9.224,      4.115 ];
    
%        FAT SATURATION - 80x80 MATRIX    FAT SATURATION - 96x96 MATRIX    WATER EXCITATION - 80x80 MATRIX  WATER EXCITATION - 96x96 MATRIX
%         FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2
eDBV = [  4.9030,   29.3900,    2.1030,    5.0860,   28.7600,    2.1520,    5.9470,   29.0800,    2.0930,    5.6470,   28.8600,    2.0820 ];

%        FAT SATURATION - 80x80 MATRIX    FAT SATURATION - 96x96 MATRIX    WATER EXCITATION - 80x80 MATRIX  WATER EXCITATION - 96x96 MATRIX
%         FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2     FLAIR     nonFLAIR    NFC T2 
eOEF = [  15.1600,  23.8700,    13.0100,   17.9800,  24.3200,    13.1800,   16.6000,  22.4500,    12.9700,   16.4000,  23.7100,    13.0000 ];

     

%% Bar Chart Plotting

npts = length(dpts);


% Plot R2p
figure(); hold on; box on;
bar(1:npts,R2p(dpts),0.75);
errorbar(1:npts,R2p(dpts),eR2p(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis([0.5,npts+0.5,0,13.6]);
ylabel('R_2'' (s^-^1)');
xticks(1:npts);
xticklabels(lbls);

% Plot DBV
figure(2); hold on; box on;
bar(1:npts,DBV(dpts),0.75);
errorbar(1:npts,DBV(dpts),eDBV(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis([0.5,npts+0.5,0,15.8]);
ylabel('DBV (%)');
xticks(1:npts);
xticklabels(lbls);

% Plot OEF
figure(3); hold on; box on;
bar(1:npts,OEF(dpts),0.75);
errorbar(1:npts,OEF(dpts),eOEF(dpts),'k.','LineWidth',2,'MarkerSize',1);
axis([0.5,npts+0.5,0,51]);
ylabel('OEF (%)');
xticks(1:npts);
xticklabels(lbls);
