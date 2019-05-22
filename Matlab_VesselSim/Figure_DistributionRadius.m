% Figure_DistributionRadius.m
%
% Make plots showing ASE curves (extravascular only) for the in vivo vessel
% distributions, compared with single-vessel radius distributions based on the
% mean value of each distribution. 
%
% Derived from Figure_SingleRadius.m
%
% Created by MT Cherukara, 13 May 2019

clear;
close all
setFigureDefaults;

datadir = '../../Data/vesselsim_data/vs_arrays/';

% Choose OEF, DBV
OEF = 0.40;
DBV = 0.03;

% Fixed taus
taus = -16:8:64;

% Physiological Parameters
OEFvals = linspace(0.21,0.7,50);
DBVvals = linspace(0.003,0.15,50);

% Find OEF and DBV indices
i_OEF = find(OEFvals == OEF,1);
i_DBV = find(DBVvals == DBV,1);


%% Load the Lauwers data
 
% Load distribution data
load([datadir,'TE84_vsData_lauwers_50.mat']);
Si = squeeze(S0(i_DBV,i_OEF,:));
Sl_raw = Si./max(Si);
Sl_dist = log(Sl_raw) + 1;

% Load the single-vessel average data
load([datadir,'TE84_vsData_single_R_5.mat']);
Si = squeeze(S0(i_DBV,i_OEF,:));
Sl_one = Si./max(Si);
Sl_sing = log(Sl_one) + 1;


%% Plot Lauwers

figure;
plot(taus,Sl_dist,'-');
grid on; axis square; hold on;
plot(taus,Sl_sing,'--');
% set(gca,'FontSize',15);
xlabel('Spin Echo Displacement \tau (ms)');
ylabel('Log (Signal)');
axis([-20,66,0.905,1.005]);
legend('Lauwers distribution','Mean radius 5 \mum','Location','SouthWest');
title('Lauwers distribution');


%% Load the Sharan data
 
% Load distribution data
load([datadir,'TE84_vsData_sharan_50.mat']);
Si = squeeze(S0(i_DBV,i_OEF,:));
Si = Si./max(Si);
taus93 = [13, 21, 29, 37, 45, 53, 61, 69, 77, 85, 93];
SS_raw = Si(taus93);
SS_dist = log(SS_raw) + 1;

% Load the single-vessel average data
load([datadir,'TE84_vsData_single_R_23.mat']);
Si = squeeze(S0(i_DBV,i_OEF,:));
SS_one = Si./max(Si);
SS_sing = log(SS_one) + 1;

% Load the static distribution data
load([datadir,'TE84_vsData_sharan_ND_50.mat']);
Si = squeeze(S0(i_DBV,i_OEF,:));
SS_two = Si./max(Si);
SS_stat = log(SS_two) + 1;


%% Plot Sharan

% figure;
% plot(taus,SS_dist,'-');
% grid on; axis square; hold on;
% plot(taus,SS_sing,'--');
% % set(gca,'FontSize',15);
% xlabel('Spin Echo Displacement \tau (ms)');
% ylabel('Log (Signal)');
% axis([-20,66,0.905,1.005]);
% legend('Sharan distribution','Mean radius (23 \mum)','Location','SouthWest');
% title('Sharan distribution');

% compare static and diffusive
figure;
plot(taus,SS_stat,'-','color',defColour(3));
grid on; axis square; hold on;
plot(taus,SS_dist,'-','color',defColour(1));
% set(gca,'FontSize',16);
xlabel('Spin Echo Displacement \tau (ms)');
ylabel('Log (Signal)');
axis([-20,66,0.905,1.005]);
legend('Static','Diffusive','Location','SouthWest');
title('Sharan distribution');


%% Load the Jochimsen data
 
% Load distribution data
load([datadir,'TE84_vsData_frechet_50.mat']);
Si = squeeze(S0(i_DBV,i_OEF,:));
SJ_raw = Si./max(Si);
SJ_dist = log(SJ_raw) + 1;

% Load the single-vessel average data
load([datadir,'TE84_vsData_single_R_16.mat']);
Si = squeeze(S0(i_DBV,i_OEF,:));
SJ_one = Si./max(Si);
SJ_sing = log(SJ_one) + 1;

% Load the static distribution data
load([datadir,'TE84_vsData_frechet_ND_50.mat']);
Si = squeeze(S0(i_DBV,i_OEF,:));
SJ_two = Si./max(Si);
SJ_stat = log(SJ_two) + 1;


%% Plot Jochimsen

% figure;
% plot(taus,SJ_dist,'-');
% grid on; axis square; hold on;
% plot(taus,SJ_sing,'--');
% % set(gca,'FontSize',16);
% xlabel('Spin Echo Displacement \tau (ms)');
% ylabel('Log (Signal)');
% axis([-20,66,0.905,1.005]);
% legend('Jochimsen distribution','Mean radius 16 \mum','Location','SouthWest');
% title('Jochimsen distribution');

% compare static and diffusive

figure;
plot(taus,SJ_stat,'-','color',defColour(3));
grid on; axis square; hold on;
plot(taus,SJ_dist,'-','color',defColour(1));
% set(gca,'FontSize',16);
xlabel('Spin Echo Displacement \tau (ms)');
ylabel('Log (Signal)');
axis([-20,66,0.905,1.005]);
legend('Static','Diffusive','Location','SouthWest');
title('Jochimsen distribution');


%% Plot them together

% figure;
% plot(taus,SS_dist);
% grid on; axis square; hold on;
% plot(taus,SJ_dist);
% plot(taus,Sl_dist);
% xlabel('Spin Echo Displacement \tau (ms)');
% ylabel('Log (Signal)');
% axis([-20,66,0.905,1.005]);
% legend('Sharan distribution','Jochimsen distribution','Lauwers distribution','Location','SouthWest');
