% Figure_SpinQuiver.m

% Plots an example of spins around a static field (for Thesis)
%
% MT Cherukara
% 11 April 2019

clear;
close all;

setFigureDefaults;


%% Plot Spins Around a Static Field
% Choose some parameters
np = 15;
theta_angle = 35;

% Generate coordinates
coord = zeros(1,np*2);
rr = ones(1,np*2);
th = [deg2rad(theta_angle).*ones(1,np), deg2rad(180-theta_angle).*ones(1,np)];
ph = 2*pi*rand(1,np*2);

% Convert to Cartesians
uu = rr .* sin(th) .* cos(ph);
vv = rr .* sin(th) .* sin(ph);
ww = rr .* cos(th);

% Plot central lines
figure; hold on; axis off;
plot3([-0.8,0.8],[0,0],[0,0],'-k');
plot3([0,0],[-0.8,0.8],[0,0],'-k');
plot3([0,0],[0,0],[-0.8,0.8],'-k');
quiver3(coord,coord,coord,uu,vv,ww);
quiver3(0,0,0,0,0,1,'LineWidth',4,'Color','m');
axis([-1, 1, -1, 1, -1, 1]);
view(0,0);


%% Plot Magnetization Moving After Excitation B1 field

figure; hold on; axis off;
plot3([-0.6,0.8],[0,0],[0,0],'-k');
plot3([0,0],[-0.6,0.8],[0,0],'-k');
plot3([0,0],[0,0],[-0.6,0.8],'-k');
quiver3(0,0,0,0.8,0,0,'LineWidth',3,'Color','m','MaxHeadSize',0.5);
quiver3(0,0,0,0,1,0,'LineWidth',3,'Color','m','MaxHeadSize',0.4);
quiver3(0,0,0,0.5,0.5,0,'LineWidth',4,'Color','b','MaxHeadSize',0.7);
axis([-0.7, 1, -0.7, 1, -0.7, 1]);
view(2);