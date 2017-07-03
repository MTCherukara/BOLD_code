% xCylinders.m

% trying to work out a solution to the Yablonskiy condition for static 
% dephasing (from Yablonskiy and Haacke, 1994):
%
%       1/(z*dw) << (r/2)^2/6D
%
% First, in 2D, an area filled with randomly oriented cylinders

clear; close all;

% generate space, a square of side 1, and fill it with randomly positioned
% and oriented cylinders, each cylinder must have the following: xpos,
% ypos, angle.

% parameters
M = 10; % maximum number of cylinders
Z = 0.05; % total volume that should be occupied by cylinders
R = 0.02; % radius of cylinders

% generate cylinders, each one has [XPOS, YPOS, ANGLE];
pos = rand(M,3);
pos(:,3) = pos(:,3)*pi; % so that it's an angle between 0 and 180 degrees,

p2(:,1) = pos(:,1) + cos(pos(:,3));
p2(:,2) = pos(:,2) + sin(pos(:,3));

p3(:,1) = pos(:,1) - cos(pos(:,3));
p3(:,2) = pos(:,2) - sin(pos(:,3));

pd2(:,1) = p2(:,1) + R*cos(pi - pos(:,3));
pd2(:,2) = p2(:,2) + R*sin(pi - pos(:,3));

pf2(:,1) = p2(:,1) - R*cos(pi - pos(:,3));
pf2(:,2) = p2(:,2) - R*sin(pi - pos(:,3));

pd3(:,1) = p3(:,1) - R*cos(pi - pos(:,3));
pd3(:,2) = p3(:,2) - R*sin(pi - pos(:,3));

pf3(:,1) = p3(:,1) + R*cos(pi - pos(:,3));
pf3(:,2) = p3(:,2) + R*sin(pi - pos(:,3));

% visualise
figure('WindowStyle','Docked');
hold on; box on;
% plot([p3(:,1),p2(:,1)]',[p3(:,2),p2(:,2)]','k-');
plot([pd3(:,1),pf2(:,1)]',[pd3(:,2),pf2(:,2)]','k-');
plot([pf3(:,1),pd2(:,1)]',[pf3(:,2),pd2(:,2)]','k-');

axis([0 1 0 1]);