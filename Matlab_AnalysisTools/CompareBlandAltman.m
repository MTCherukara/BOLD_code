% function CompareBlandAltman
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

clear;

% % have the user enter the first file
% [fn1,fd1] = uigetfile('*.nii.gz','Choose First Dataset:');
% 
% % and the second one
% [fn2,fd2] = uigetfile('*.nii.gz','Choose Second Dataset:');

fd1 = '/Users/mattcher/Documents/DPhil/Data/MR_700/';
fd2 = fd1;
fn1 = 'MR_700_CSF_T2w_swapped.nii.gz';
fn2 = 'MR_700_CSF_T2fit.nii.gz';

% load both sets
[data1,dims1] = read_avw([fd1,fn1]);
[data2,dims2] = read_avw([fd2,fn2]);

% check
assert(dims1(1) == dims2(1),'Input data must have the same dimensions!');
assert(dims1(2) == dims2(2),'Input data must have the same dimensions!');
assert(dims1(3) == dims2(3),'Input data must have the same dimensions!');

% restrict to only those data points where there is a non-zero in both:

%   vectorize
data1 = squeeze(data1(:,:,4));
data2 = squeeze(data2(:,:,4));

data1 = data1(:);
data2 = data2(:);

%   cut out zeros from data2
data1(data2 == 0) = [];
data2(data2 == 0) = [];

%   cut out zeros from data1
data2(data1 == 0) = [];
data1(data1 == 0) = [];


% calculate Bland-Altman variables
X = (data1(:) + data2(:))./2;
Y = data1(:) - data2(:);

% % Scatter Plot
% figure('WindowStyle','Docked');
% hold on; box on;
% scatter(data1(:),data2(:));
 
% Bland-Altman Plot
figure('WindowStyle','Docked');
hold on; box on;
scatter(X,Y);
axis([0 1 -1 1]);
xlabel('ECF Partial Volume Estimate');
ylabel('Estimate Difference');
set(gca,'FontSize',16);