function CompareBlandAltman(varargin)
% CompareBlandAltman usage:
%
%       CompareBlandAltman
% 
% Takes in two CSF maps, and compares them by producing a Bland-Altman plot
%
% 
%       Copyright (C) University of Oxford, 2017
%
% 
% Created by MT Cherukara, 30 October 2017
%
% CHANGELOG:

close all;

% read user inputs
p = inputParser;

addParameter(p,'plot_scatt',0);
addParameter(p,'plot_bland',1);
addParameter(p,'plot_histo',0);
addParameter(p,'slice',6);

parse(p,varargin{:});

% temporary
fd1 = '/Users/mattcher/Documents/DPhil/Data/MR_700/';
fd2 = fd1;
fn1 = 'MR_700_CSF_T2w.nii.gz';
fn2 = 'MR_700_CSF_T2fit.nii.gz';

% have the user select some files
if ~exist('fn1','var')
    [fn1,fd1] = uigetfile('*.nii.gz','Choose First Dataset:');
end

if ~exist('fn2','var')
    [fn2,fd2] = uigetfile('*.nii.gz','Choose Second Dataset:');
end

% load both sets
[data1,dims1] = read_avw([fd1,fn1]);
[data2,dims2] = read_avw([fd2,fn2]);

% check
assert(dims1(1) == dims2(1),'Input data must have the same dimensions!');
assert(dims1(2) == dims2(2),'Input data must have the same dimensions!');
assert(dims1(3) == dims2(3),'Input data must have the same dimensions!');

% pull out a particular slice
if p.Results.slice ~= 0
    data1 = data1(:,:,p.Results.slice);
    data2 = data2(:,:,p.Results.slice);
end

% vectorize
data = [data1(:),data2(:)];

% find only the points where both sets have non-zero values
mutualdata = data(all(data,2),:); 
% disp(['Number of valid data points: ',num2str(size(mutualdata,1))]);

% Scatter Plot
if p.Results.plot_scatt
    figure('WindowStyle','Docked');
    hold on; box on;
    scatter(mutualdata(:,1),mutualdata(:,2));
    xlabel('Method 1 PV Estimate');
    ylabel('Method 2 PV Estimate');
    set(gca,'FontSize',16);
end
 
% Bland-Altman Plot
if p.Results.plot_bland
    
    % create variables
    X = (mutualdata(:,1) + mutualdata(:,2))./2;
    Y = (mutualdata(:,1) - mutualdata(:,2));
    
%     X = log(mutualdata(:,1) .* mutualdata(:,2))./2;
%     Y = log(mutualdata(:,1)./mutualdata(:,2));
    
    % plot
    figure('WindowStyle','Docked');
    hold on; box on;
    scatter(X,Y);
    axis([0 1 -1 1]);
    xlabel('ECF Partial Volume Estimate');
    ylabel('Estimate Difference');
    set(gca,'FontSize',16);
end

% Histogram Comparison
if p.Results.plot_histo
    
    % calculate histograms
    nbin = 50;
    [n1,e1] = histcounts(mutualdata(:,1),nbin);
    [n2,e2] = histcounts(mutualdata(:,2),nbin);

    % find the histogram centres
    c1 = e1(2:end) + e1(1:end-1) ./ 2;
    c2 = e2(2:end) + e2(1:end-1) ./ 2;

    % plot
    figure('WindowStyle','Docked');
    hold on; box on;
    plot(c1,n1,'LineWidth',2);
    plot(c2,n2,'LineWidth',2);
    xlabel('Voxel Intensity');
    ylabel('Voxel Count');
    set(gca,'FontSize',16);
    xlim([0,1]);
    yticks('');
end