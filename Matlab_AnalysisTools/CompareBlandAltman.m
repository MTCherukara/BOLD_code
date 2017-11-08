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

% close all;

% read user inputs
p = inputParser;

addParameter(p,'plot_scatt',0);
addParameter(p,'plot_bland',1);
addParameter(p,'plot_histo',0);
addParameter(p,'slice',6);

parse(p,varargin{:});

% parameters
nbin = 25;      % histogram bins


% temporary
% fd1 = '/Users/mattcher/Documents/DPhil/Data/subject_05/';
% fd2 = fd1;
% fn1 = 'CSF_T1warp.nii.gz';
% fn2 = 'CSF_T2fit.nii.gz';

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

% find the points where eiter set has values > 0.1
eitherdata = data(any(data > 0.01,2),:);

% find only the points where both sets have values > 0.1
mutualdata = data(all(data > 0.01,2),:); 

disp(['Number of overlapping voxels: ',num2str(size(mutualdata,1))]);
disp(['Total voxels: ',num2str(size(eitherdata,1))]);
disp(['  Ratio: ',num2str(size(mutualdata,1)./size(eitherdata,1))]);

% Scatter Plot
if p.Results.plot_scatt
    
    % remove points with very low PVE
    hpve = mutualdata > 0.01;
    scatdata = mutualdata(all(hpve,2),:);
    
    % plot
    figure('WindowStyle','Docked');
    hold on; box on;
    scatter(scatdata(:,1),scatdata(:,2),'k.');
    xlabel('Method 1 PV Estimate');
    ylabel('Method 2 PV Estimate');
    set(gca,'FontSize',16);
end
 
% Bland-Altman Plot
if p.Results.plot_bland
    
    % create variables
    X = (mutualdata(:,1) + mutualdata(:,2))./2;
    Y = (mutualdata(:,1) - mutualdata(:,2));
    
    XY = sortrows([X,abs(Y)],1);
    MY = movmean(XY(:,2),50);
    
    bn = linspace(0,1,nbin);
    bi = ones(1,nbin+2);
    ba = zeros(1,nbin);
    
    for ii = 2:nbin
        ti = find(XY(:,1) > bn(ii),1);
        if length(ti) == 1
            bi(ii) = ti;
            ba(ii) = mean(XY(bi(ii-1):bi(ii),2));
        end
        
    end
    
%     X = log(mutualdata(:,1) .* mutualdata(:,2))./2;
%     Y = log(mutualdata(:,1)./mutualdata(:,2));
    
    % plot
    figure('WindowStyle','Docked');
    hold on; box on;
    scatter(X,Y);
    plot(bn, ba,'r-','LineWidth',2);
    plot(bn,-ba,'r-','LineWidth',2);
    axis([0 1 -1 1]);
    xlabel('ECF Partial Volume Estimate');
    ylabel('Estimate Difference');
    set(gca,'FontSize',16);
end

% Histogram Comparison
if p.Results.plot_histo
    
    % calculate histograms
    [n1,e1] = histcounts(mutualdata(:,1),nbin);
    [n2,e2] = histcounts(mutualdata(:,2),nbin);

    % find the histogram centres
    c1 = e1(2:end) + e1(1:end-1) ./ 2;
    c2 = e2(2:end) + e2(1:end-1) ./ 2;

    % plot
    figure('WindowStyle','Docked');
%     figure(1);
    hold on; box on;
    plot(c1,n1,'-','LineWidth',3);
    plot(c2,n2,':','LineWidth',3);
    xlabel('Voxel Intensity');
    ylabel('Voxel Count');
    set(gca,'FontSize',16);
    xlim([0,1]);
    yticks('');
end