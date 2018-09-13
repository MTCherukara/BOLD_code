% xCompareMaxima.m

% For comparing grid-search maxima data for different Tau configurations
% 1 August 2018

clear;
close all;

% pick a dataset
[dname,dpath] = uigetfile('*.mat','Select a GridMaxima file');

% true values
t_DBV = 0.0400;
t_R2p = 5.6799;

% array of true values
trues = repmat([t_R2p;t_DBV],1,5);

% load the data
load([dpath,dname]);

% calculate differences
diffs = maxes-trues;
mdiff = mean(abs(diffs),2);

% display results
disp('  ')
disp(['For dataset ',dname,':']);
disp(['   R2'' error: ', round2str(mdiff(1),3)]);
disp(['   DBV error: ' , round2str(100*mdiff(2),3)]);