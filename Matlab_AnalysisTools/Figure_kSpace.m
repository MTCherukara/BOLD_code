% Figure_kSpace.m
%
% Plot an example figure showing the Fourier Transformed version of some random
% image. For Thesis
%
% MT Cherukara
% 16 April 2019

clear;
close all;
setFigureDefaults;

% Load data
indata = read_avw('/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs6/ASE_FLAIR_av_SE.nii.gz');

% Pick one slice
inslice = indata(:,:,4);

% Fourier Transform it
ffslice = fftshift(fft2(inslice));

kslice = sqrt(abs(ffslice));

% Plot
figure;
imagesc(kslice);
hold on;
colormap(gray);
axis square
axis off

% Define EPI trajectory
kx = [repmat([4,60,60,4],1,7), 4, 60];
kb = 5:4:61;
ky = zeros(1,length(kx));
ky(1:2:end) = kb;
ky(2:2:end) = kb;

plot(kx,ky,'m-');