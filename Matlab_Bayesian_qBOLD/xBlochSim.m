% xBlochSim.m
%
% Longitudinal magnetization Bloch simulation for determining the steady-state
% magnetization in an ASE sequence with given TR and TE, as well as a FLAIR
% inversion with given TI.
%
% Matthew Cherukara, 15 May 2018.

clear;
close all;

setFigureDefaults;

%% Set Parameters
% simulation parameters
ts      =  0.0;         % start time (seconds)
tf      = 10.0;         % end time (seconds)
nt      = 1000;         % number of time points

% constants
M0      = 1.0;          % default magnetization
T1      = 1.200;        % T1 of grey matter (seconds)
T2      = 0.087;        % T2 of grey matter (seconds)

% scan parameters
TR      = 3.0;          % Repetition time (TR) (seconds)
te      = 0.082;        % Echo time (TE) (seconds)
TI      = 1.210;        % Inversion time (TI) (seconds)

%% Simulate
% time points
tt = linspace(ts,tf,nt);

