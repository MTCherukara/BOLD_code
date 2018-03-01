% Bar Charts

clear;
close all;
setFigureDefaults;

%% Abstract Data (CSF)
% %       FLAIR  Uncorr T1w    T2w    T2fit  3TE u  3TE f
% DBV = [ 5.40,  8.10,  9.09,  9.74,  8.44,  6.02,  6.28; ...
%         6.61,  8.91,  12.7,  18.0,  12.6, 15.08, 15.53; ...
%         5.45,  5.80,  6.74,  8.14,  5.46,  5.31,  5.39; ...
%         5.50,  7.07,  8.91,  11.9,  8.44,  9.10,  9.25 ];
%     
% %       FLAIR  Uncorr T1w    T2w    T2fit
% R2p = [ 2.57,  4.72,  3.22,  4.14,  2.14,  2.93,  3.27; ...
%         2.61,  5.71,  4.40,  4.66,  1.67,  4.36,  5.18; ...
%         2.29,  3.42,  2.67,  3.82,  2.59,  3.12,  3.43; ...
%         2.51,  3.79,  3.81,  5.34,  1.81,  3.69,  4.30 ];
%     
% OEF = 100*R2p./(3.01*DBV);
    
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


%% Paper Data (sqBOLD)

%       sq-VB   1C-VB   1C-VBI  2C-VB   2C-VBI
R2p = [ 2.930,  2.869,  2.946,  2.730,  2.767; ...
        3.160,  2.968,  3.023,  2.774,  2.824; ...
        2.680,  2.597,  2.593,  2.450,  2.447; ...
        3.266,  3.165,  3.178,  2.912,  2.979; ...
        3.002,  2.890,  2.890,  2.621,  2.711; ...
        3.389,  3.195,  3.156,  3.000,  3.010; ...
        2.510,  2.267,  2.355,  2.107,  2.195 ];
    
%       sq-VB   1C-VB   1C-VBI  2C-VB   2C-VBI
DBV = [ 4.047,  3.937,  3.896,  4.145,  3.853; ...
        5.753,  4.527,  4.174,  4.707,  4.105; ...
        4.544,  3.682,  3.540,  4.024,  3.429; ...
        5.098,  4.645,  4.033,  4.828,  3.987; ...
        5.623,  5.045,  4.094,  5.289,  4.008; ...
        5.603,  4.707,  4.068,  4.988,  3.931; ...
        4.645,  3.476,  3.768,  3.454,  3.626 ];

%       sq-VB   1C-VB   1C-VBI  2C-VB   2C-VBI
OEF = [ 21.23,  24.15,  25.06,  21.83,  23.80; ...
        18.21,  21.73,  24.01,  19.53,  22.80; ...
        19.55,  23.38,  24.29,  20.18,  23.65; ...
        21.23,  22.58,  26.11,  19.99,  24.76; ...
        17.69,  18.96,  23.40,  16.43,  22.42; ...
        20.05,  22.50,  25.70,  19.93,  25.38; ...
        17.91,  21.61,  20.72,  20.22,  20.07 ];
    
%        sq-VB  1C-VB  1C-VBI  2C-VB  2C-VBI
eR2p = [ 1.00,  1.11,  0.94,   1.14,  0.95; ...
         1.10,  1.09,  0.88,   1.07,  0.86; ...
         1.34,  1.36,  1.16,   1.31,  1.13; ...
         1.40,  1.39,  1.14,   1.44,  1.15; ...
         1.44,  1.38,  1.04,   1.35,  1.09; ...
         1.37,  1.53,  1.10,   1.47,  1.09; ...
         0.85,  0.87,  0.74,   0.81,  0.71 ];

%        sq-VB  1C-VB  1C-VBI  2C-VB  2C-VBI
eDBV = [ 2.15,  1.88,  1.21,   2.22,  1.29; ...
         2.44,  2.13,  1.19,   2.41,  1.30; ...
         2.54,  2.35,  1.33,   2.65,  1.32; ...
         2.40,  2.54,  1.34,   3.01,  1.42; ...
         3.16,  3.62,  1.77,   4.04,  1.81; ...
         3.06,  2.67,  1.31,   3.10,  1.41; ...
         1.92,  1.67,  1.14,   1.77,  1.19 ];
     
% rebase
eR2p = eR2p./repmat(R2p(:,1),1,5);
eDBV = eDBV./repmat(DBV(:,1),1,5);
R2p = R2p./repmat(R2p(:,1),1,5);
DBV = DBV./repmat(DBV(:,1),1,5);
OEF = OEF./repmat(OEF(:,1),1,5);

     
% averages   
aR2p = mean(R2p);
sR2p = std(R2p);
aDBV = mean(DBV);
sDBV = std(DBV);
aOEF = mean(OEF);
sOEF = std(OEF);

% Calculate OEF error by adding R2' and DBV errors in quadrature
eOEF = OEF.*sqrt(((eR2p./R2p).^2) + ((eDBV./DBV).^2));


%% Plotting

% Plot details
dpts = [1,2,4,5];
legtext = {'L-VB','1C-VB','1C-VB-I','2C-VB','2C-VB-I'};

npts = repmat((1:length(dpts))',1,7);
lbls = legtext(dpts);
jttr = repmat(-0.06:0.02:0.06,length(dpts),1);

% Plot R2p
figure; hold on; box on;
errorbar(npts+jttr,R2p(:,dpts)',eR2p(:,dpts)');
plot(npts,R2p(:,dpts)');
errorbar(npts(:,1),aR2p(dpts),sR2p(dpts),'k:','LineWidth',3);
xlim([npts(1)-0.25,npts(end)+0.25]);
% ylim([1,5]);
ylabel('R_2'' (s^-^1)');
xticks(1:length(dpts));
xticklabels(lbls);

% Plot DBV
figure; hold on; box on;
errorbar(npts+jttr,DBV(:,dpts)',eDBV(:,dpts)');
plot(npts,DBV(:,dpts)');
errorbar(npts(:,1),aDBV(dpts),sDBV(dpts),'k:','LineWidth',3);
xlim([npts(1)-0.25,npts(end)+0.25]);
% ylim([1,9]);
ylabel('DBV (%)');
xticks(1:length(dpts));
xticklabels(lbls);

% Plot OEF
figure; hold on; box on;
errorbar(npts+jttr,OEF(:,dpts)',eOEF(:,dpts)');
plot(npts,OEF(:,dpts)');
errorbar(npts(:,1),aOEF(dpts),sOEF(dpts),'k:','LineWidth',3);
xlim([npts(1)-0.25,npts(end)+0.25]);
% ylim([0,40]);
ylabel('OEF (%)');
xticks(1:length(dpts));
xticklabels(lbls);

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
