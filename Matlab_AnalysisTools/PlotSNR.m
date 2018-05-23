% PlotSNR.m
%
% Plots the SNR values obtained by CalculateSNR.m
% 
% Matthew Cherukara
% 22 May 2018

clear;
close all;

setFigureDefaults;


%% Spin Echo
SE = [  81.96,  65.93,  51.06,  43.19,  35.95,  30.85,  27.25,  25.28; ...
        91.40,  70.25,  52.36,  41.40,  32.12,  26.64,  23.45,  21.52; ...
        58.91,  48.40,  36.95,  29.60,  23.86,  20.21,  18.53,  16.49; ...
       165.27, 145.09, 106.35,  83.91,  59.16,  52.57,  46.68,  40.56; ...
        99.57,  83.46,  64.02,  46.97,  36.39,  30.25,  25.00,  22.60 ];
    
TE = 66:26:248;

% Plot Absolute SNR
figure();
plot(TE,SE,'LineWidth',1); hold on;
errorbar(TE,mean(SE),std(SE),'k--','LineWidth',2);
xlabel('Echo Time TE (ms)');
xticks(TE);
xlim([64,250]);
ylabel('SNR');

SER = SE./repmat(SE(:,1),1,8);

% Plot Relative SNR
figure();
plot(TE,SER); hold on;
errorbar(TE,mean(SER),std(SER),'k-','LineWidth',2);
xlabel('Echo Time TE (ms)');
xticks(TE);
axis([66,248,0,1.05]);
ylabel('Relative SNR');


%% ASE FLAIR vs Non-FLAIR

% FLAIR, whole brain
FL_WB = [  78.7519,   74.3249,   77.8454,   74.4830,   76.8267,   66.6734,   73.7967,   80.2065,   78.2909,   74.4832,   83.6086; ...
           80.6841,   85.1900,   83.7901,   80.6410,   78.9341,   73.8368,   76.1987,   77.9718,   77.2985,   81.6240,   85.8959; ...
           70.8603,   68.8277,   69.2210,   66.5698,   66.8503,   65.9468,   66.1477,   66.7585,   70.3325,   67.4209,   68.9657; ...
           55.5240,   54.9441,   54.0854,   55.8430,   54.7724,   54.2845,   52.4259,   53.6810,   52.0935,   50.9286,   50.3361; ...
           31.2202,   31.6238,   30.8355,   30.7067,   30.2792,   30.0360,   29.3712,   29.1383,   28.5727,   27.3663,   26.7678 ];

FL_GM = [  58.8478,   55.8886,   58.7868,   55.8034,   57.3608,   49.7132,   55.0762,   59.7649,   58.5125,   56.0158,   62.6984; ...
           58.8728,   62.2267,   61.3728,   58.7296,   56.8790,   53.0212,   54.3451,   55.3854,   54.5220,   57.1264,   59.7308; ...
           53.0199,   51.8805,   52.5622,   50.2303,   50.5795,   50.0605,   50.2390,   50.9974,   54.4493,   52.3284,   54.3263; ...
           48.6648,   47.8797,   47.0719,   48.3199,   47.5554,   47.0422,   45.3838,   46.6145,   45.1239,   44.1930,   43.7200; ...
           27.2069,   27.3698,   26.6233,   26.4407,   26.2343,   25.7953,   25.3448,   25.1741,   24.7490,   23.5931,   23.1100 ];

NF_WB = [ 114.4142,  112.1640,  112.2949,  111.6938,  110.5960,  104.2502,  102.8724,   99.8787,   95.7175,   91.5287,   90.3860; ...
           95.6880,  104.3509,  103.2294,  105.4743,   96.5090,   94.4195,   98.8313,   96.0685,   94.4738,   90.9787,   93.6736; ...
           84.7928,   81.6903,   80.2859,   82.1109,   83.7741,   75.5737,   69.7377,   69.2347,   68.1853,   63.2021,   59.6296; ...
          112.5290,  110.7007,  113.2416,  113.4086,  113.3375,  114.7023,  114.3667,  116.0153,  111.8138,  109.8943,  107.0420; ...
           69.9288,   69.7761,   71.0314,   70.2498,   70.2912,   69.3473,   67.7833,   66.9390,   64.4275,   62.6393,   61.3303 ];
 
NF_GM = [ 107.4196,  106.1800,  106.7981,  106.1070,  104.2065,   97.6899,   95.7564,   92.0299,   87.9550,   83.3058,   82.0730; ...
           89.3666,   98.1214,   97.7827,   99.1817,   89.7806,   86.6359,   88.2135,   85.0206,   82.4201,   78.2965,   79.6168; ...
           91.4320,   88.7444,   88.2756,   90.1525,   91.6536,   82.2694,   75.6190,   74.6343,   72.8356,   67.4631,   63.5954; ...
          130.2402,  128.4531,  131.4915,  131.2158,  130.3597,  131.3054,  130.4676,  131.7478,  126.5032,  124.3729,  120.8867; ...
           79.7817,   79.8948,   81.2741,   79.9864,   79.4384,   78.1558,   75.1181,   73.7339,   70.1187,   67.4834,   66.5700 ];
       
% plot
tau = -16:8:64;

FL_WB_R = FL_WB./repmat(FL_WB(:,1),1,length(tau));
FL_GM_R = FL_GM./repmat(FL_GM(:,1),1,length(tau));
NF_WB_R = NF_WB./repmat(NF_WB(:,1),1,length(tau));
NF_GM_R = NF_GM./repmat(NF_GM(:,1),1,length(tau));

FL_WB_M = mean(FL_WB);
FL_GM_M = mean(FL_GM);
NF_WB_M = mean(NF_WB);
NF_GM_M = mean(NF_GM);

FL_WB_S = std(FL_WB);
FL_GM_S = std(FL_GM);
NF_WB_S = std(NF_WB);
NF_GM_S = std(NF_GM);


% % Relative SNR - FLAIR
% figure();
% plot(tau,FL_GM_R);
% xlabel('Spin Echo Displacement \tau (ms)');
% xticks(tau);
% axis([-16,64,0.68,1.12]);
% ylabel('Relative SNR');
% 
% % Relative SNR - NonFLAIR
% figure();
% plot(tau,NF_GM_R);
% xlabel('Spin Echo Displacement \tau (ms)');
% xticks(tau);
% axis([-16,64,0.68,1.12]);
% ylabel('Relative SNR');

% Mean SNR - Whole Brain
figure(); hold on; box on;
plot(tau,NF_WB_M,'-' ,'Color',defColour(2));
plot(tau,FL_WB_M,'--' ,'Color',defColour(1));
errorbar(tau,FL_WB_M,FL_WB_S,'.','Color',defColour(1));
errorbar(tau+0.2,NF_WB_M,NF_WB_S,'.','Color',defColour(2));
legend('non-FLAIR','FLAIR','Location','SouthEast');
xlabel('Spin Echo Displacement \tau (ms)');
xticks(tau);
ylabel('SNR');
axis([-17,65,0,130]);

% Mean SNR - Grey Matter
figure(); hold on; box on;
plot(tau,NF_GM_M,'-','Color',defColour(2));
plot(tau,FL_GM_M,'--','Color',defColour(1));
errorbar(tau,FL_GM_M,FL_GM_S,'.','Color',defColour(1));
errorbar(tau+0.2,NF_GM_M,NF_GM_S,'.','Color',defColour(2));
legend('non-FLAIR','FLAIR','Location','SouthEast');
xlabel('Spin Echo Displacement \tau (ms)');
xticks(tau);
ylabel('Average SNR');
axis([-17,65,0,130]);
