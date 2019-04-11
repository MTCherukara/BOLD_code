% Figure_PulseSequence.m

% Plot a figure showing an example pulse sequence (e.g. GRE, SE, ASE) - for
% Thesis
%
% MT Cherukara
% 11 April 2019

clear;
close all;

setFigureDefaults;

% We will do all five lines (RF, Gx, Gy, Gz, RO) on a single figure plot, but
% just space them out a little bit, then hide the axes and make it look nice:



%% Standard (GRE) Sequence

% % Plan RF - two inversion pulses separated by TR
% mp_RF = 6.5;    % RF pulse midpoint
% wd_RF = 3;      % RF pulse width (on each side)
% TR = 37;
% t_RF = linspace(mp_RF-wd_RF,mp_RF+wd_RF);
% a_RF = 0.8*sinc(t_RF-mp_RF);
% time_RF = [  0,  t_RF, (t_RF + TR), 50 ];
% ampl_RF = [  0,  a_RF,        a_RF,  0 ];
% 
% 
% % Plan Gx - readout gradient
% st_RO = 24;         % readout start
% dr_RO = 12;         % readout duration
% fn_RO = st_RO + dr_RO; 
% time_Gx = [  0,  st_RO-1, st_RO, fn_RO, fn_RO+1, 50 ];
% ampl_Gx = [  0,        0,   0.6,   0.6,       0,  0 ];
% 
% 
% % Plan Gy - blip thingy
% st_Gy = 13;
% fn_Gy = st_Gy + 5;
% time_Gy = [  0,  st_Gy-0.5, st_Gy, fn_Gy, fn_Gy+0.5, 50 ];
% ampl_Gy = [  0,          0,   0.3,   0.3,         0,  0 ];
% 
% 
% % Plan Gz - slice selection
% time_Gz = [  0,  2,  3, 10, 11, 39, 40, 47, 48, 50 ];
% ampl_Gz = [  0,  0,  1,  1,  0,  0,  1,  1,  0,  0 ];
% 
% 
% % Plan RO - read out
% time_RO = [  0, st_RO-0.1, st_RO, fn_RO, fn_RO+0.1, 50 ];
% ampl_RO = [  0,         0,   0.5,   0.5,         0,  0 ];
% 
% 
% % Decide on x-axis labels
% label_times = [ mp_RF, st_RO+(dr_RO/2), mp_RF+TR ];
% label_texts = {   '0',    'TE',           'TR'   };


%% EPI SPIN ECHO

% Plan RF - excitiation pulse followed by inversion pulse
mp_RF = 5;      % RF pulse midpoint
wd_RF = 3;      % RF pulse width (on each side)
TR = 18;
t_RF = linspace(mp_RF-wd_RF,mp_RF+wd_RF);
a_RF = 0.8*sinc(t_RF-mp_RF);
time_RF = [  0,  t_RF, (t_RF + TR), 52 ];
ampl_RF = [  0,  a_RF,    1.5*a_RF,  0 ];


% Plan RO - read out
mp_RO = mp_RF + (2*TR);     % readout midpoint
wd_RO = 8;                  % readout width (on each side)
time_RO = [  0, mp_RO-wd_RO-0.1, mp_RO-wd_RO, mp_RO+wd_RO, mp_RO+wd_RO+0.1, 52 ];
ampl_RO = [  0,               0,         0.5,         0.5,               0,  0 ];


% Generic EPI up-down floop
time_UD = [ 0, 0.01, 1.99, 2.01, 3.99, 4 ];
ampl_UD = [ 0,    1,    1,   -1,   -1, 0 ];

% Plan Gx - readout
time_Gx = [  0, (mp_RO-wd_RO+time_UD), (mp_RO-wd_RO+time_UD+4), (mp_RO-wd_RO+time_UD+8), (mp_RO-wd_RO+time_UD+12), 52 ];
ampl_Gx = [  0,          0.4*ampl_UD ,          0.4*ampl_UD   ,          0.4*ampl_UD   ,          0.4*ampl_UD    , 0 ];

% Generic phase blip
time_Bp = [ 0, 0.01, 0.49, 0.5 ];
ampl_Bp = [ 0, 0.40, 0.40,   0 ];

% Plan Gy - loads of blips
time_Gy = [  0,  (mp_RO-wd_RO+time_Bp), (mp_RO-wd_RO+time_Bp+2), (mp_RO-wd_RO+time_Bp+4), (mp_RO-wd_RO+time_Bp+6), (mp_RO-wd_RO+time_Bp+8), (mp_RO-wd_RO+time_Bp+10), (mp_RO-wd_RO+time_Bp+12), (mp_RO-wd_RO+time_Bp+14), (mp_RO-wd_RO+time_Bp+16), 52 ];
ampl_Gy = [  0,               ampl_Bp ,              ampl_Bp   ,              ampl_Bp   ,              ampl_Bp   ,              ampl_Bp   ,              ampl_Bp    ,              ampl_Bp    ,              ampl_Bp    ,              ampl_Bp    ,  0 ];


% Generic slice selection gradient
time_SS = [ -wd_RF-1, -wd_RF, wd_RF, wd_RF+1 ];
ampl_SS = [        0,      1,     1,       0 ];

% Plan Gz - excitiation, then inversion
time_Gz = [  0, (mp_RF+time_SS), (TR+mp_RF+time_SS), 52 ];
ampl_Gz = [  0,        ampl_SS ,           ampl_SS ,  0 ];


% Decide on x-axis labels
label_times = [ mp_RF, mp_RF + TR, mp_RF+ (2*TR) ];
label_texts = {   '0',     'TE/2',        'TE'   };


%% Plot the figure

% Stack heights
ht_RO = 0;
ht_Gz = 1.25;
ht_Gy = 3.0;
ht_Gx = 4.5;
ht_RF = 6;

% create figure;
hh = figure;
hold on;
axis([-2,52,-0.5,7.5]);
xticks([]);


% Plot RF
ampl_RF = ampl_RF + ht_RF;
plot(time_RF,ampl_RF,'b-');


% Plot Gx
ampl_Gx = ampl_Gx + ht_Gx;
plot(time_Gx,ampl_Gx,'-','Color',defColour(4));


% Plot Gy
% plot(time_Gy,2.*ampl_Gy + ht_Gy,'--','Color',defColour(4));
% plot(time_Gy,0.*ampl_Gy + ht_Gy,'--','Color',defColour(4));
% plot(time_Gy,-1.*ampl_Gy + ht_Gy,'--','Color',defColour(4));
% plot(time_Gy,-2.*ampl_Gy + ht_Gy,'--','Color',defColour(4));
plot(time_Gy,ampl_Gy + ht_Gy,'-','Color',defColour(4));


% Plot Gz
ampl_Gz = ampl_Gz + ht_Gz;
plot(time_Gz,ampl_Gz,'-','Color',defColour(4));


% Plot RO
ampl_RO = ampl_RO + ht_RO;
plot(time_RO,ampl_RO,'k-');


% Labels on the y axis
yticks([ht_RO, ht_Gz, ht_Gy, ht_Gx, ht_RF] + 0.25);
yticklabels({'Readout','G_z','G_y','G_x','RF'});
xticks(label_times);
xticklabels(label_texts);