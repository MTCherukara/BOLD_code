% xPlotGrid3D.m
% 
% A way of visualising 3D grid search data
%
% Created 6 October 2017

clear; close all;

% Load in Grid Search Data
load('~/Documents/DPhil/Data/GridSearches/CSF_Grids/Grid3D_100_OEF_DBV_CSF.mat');

if ~exist('vals','var')
    vals = [w1;w2;w3];
end

% For each variable, work out which point is closest to its true value
[~,mindex(1)] = min(abs(vals(1,:) - trv(1)));
[~,mindex(2)] = min(abs(vals(2,:) - trv(2)));
[~,mindex(3)] = min(abs(vals(3,:) - trv(3)));

% Have the user choose a Parameter to fix (the other two will be plotted)
fp = input('Choose a parameter to fix, 1, 2, or 3: ');

% Have the user choose a 'slice' in that parameter
disp(['Your chosen parameter''s true value is at slice ',num2str(mindex(fp)),'.']);
s1 = input('Choose a slice to plot: ');

% Cut down the other variables into 2D arrays based on the user's choice
if fp == 1
    pos2 = squeeze(pos(s1,:,:));
    val2 = vals(2:3,:);
    trv2 = trv(2:3);
    pn2  = {'DBV';'CSF'};
elseif fp == 2
    pos2 = squeeze(pos(:,s1,:));
    val2 = vals(1:2:3,:);
    trv2 = trv(1:2:3);
    pn2  = {'OEF';'CSF'};
else % fp == 3
    pos2 = squeeze(pos(:,:,s1));
    val2 = vals(1:2,:);
    trv2 = trv(1:2);
    pn2  = {'OEF';'DBV'};
end

% Now plot a 2D grid search thing as normal:

% create docked figure
figure('WindowStyle','docked');
hold on; box on;
set(gca,'FontSize',16);

imagesc(val2(2,:),val2(1,:),pos2); hold on;
c=colorbar;
plot([trv2(2),trv2(2)],[  0, 30],'w-','LineWidth',2);
plot([  0, 30],[trv2(1),trv2(1)],'w-','LineWidth',2);

% Label the other axes based on parameter choice
xlabel(pn2{2});
ylabel(pn2{1});

ylabel(c,'Posterior Probability Density');

axis([val2(2,1),val2(2,end),val2(1,1),val2(1,end)]);
set(gca,'YDir','normal');
set(c,'FontSize',16);
