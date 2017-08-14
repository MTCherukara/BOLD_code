% MTC_CompareMethods.m
%
% Compares the results of quantifying R2' and DBV from GASE data using
% AJS's method (ase_qbold_3d.m) and the FABBER method
%
% Created by MT Cherukara, 17 May 2016

clear; close all;

% load data that we already saved out into a .mat file
load('Comparison_DBV_R2p.mat');

plot_hist = 1;
plot_slice = 0;

slice = 4:9;  % this is the slice we want to look at
param = 1;  % 1 = R2', 2 = DBV
nb    = 50; % number of histogram bins

pnames = {'R2''';'DBV'};

% pull out chosen slice from chosen dataset
if param == 1
    Fslice = R2p_F(:,:,slice);
    Sslice = R2p_S(:,:,slice);
elseif param == 2
    Fslice = DBV_F(:,:,slice);
    Sslice = DBV_S(:,:,slice);
end

% sort out lower boundary
Sslice(Sslice < 0) = 0;     % remove negative values from AJS method
Fslice = abs(Fslice);       % take absolute values in FABBER method

% choose a reasonable maximum value for each
Smax = quantile(Sslice(:),0.995);   
Fmax = quantile(Fslice(:),0.995);

% define a bunch of histogram edges between 0 and the higher max
Tmax = max(Smax,Fmax);
HE   = linspace(0,Tmax,nb+1);           % edges
HC   = (HE(1:end-1) + HE(2:end))./2;    % centres

% Histogram analysis
Svals = Sslice(:);              % linearise
Svals(Svals == 0) = [];         % remove zeros
Smean = mean(Svals);            % mean
[Sx,~] = histcounts(Svals,HE); 	% histogram with defined edges
% Sx = Sx./sum(HC.*Sx);           % normalise

Fvals = Fslice(:);              % same steps as above
Fvals(Fvals == 0) = [];
Fmean = mean(Fvals); 
[Fx,~] = histcounts(Fvals,HE);
% Fx = Fx./sum(HC.*Fx);

% maximum histogram height
mh = max(max(Fx),max(Sx));

% for plotting
% take the 99th percentile value as the maximum
Sslice(Sslice > Smax) = Smax;
Fslice(Fslice > Fmax) = Fmax;

if plot_slice
    
    % plot the two versions side by side
    figure('WindowStyle','Docked');

    % Stone method
    subplot(1,2,1);
    imagesc(Sslice');
    colormap('Gray');
    title('AJS Method');
    set(gca,'YDir','normal','FontSize',16,'YTick',[],'XTick',[]);

    % FABBER Method
    subplot(1,2,2);
    imagesc(Fslice');
    colormap('Gray');
    title('FABBER Method');
    set(gca,'YDir','normal','FontSize',16,'YTick',[],'XTick',[]);
    
end % if plot_slice

if plot_hist
    
    % Plot histograms
    figure('WindowStyle','Docked');
    hold on; box on;
    plot(HC,Sx,'b','LineWidth',3);
    plot(HC,Fx,'r','LineWidth',3);
    
    xlabel(pnames{param});
    axis([0, 0.8*Tmax, 0, 1.1*mh]);
    set(gca,'FontSize',16);
    legend('AJS Method','FABBER Method','Location','NorthEast');
    
end % if plot_hist
