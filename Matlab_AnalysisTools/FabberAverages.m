% function FabberAverages(varargin)

clear; clc;

% select a fabber run
fabber = '158';
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';
fdname = dir([resdir,'fabber_',fabber,'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% Load data
DBVslice = LoadSlice([fabdir,'rLC_DBV.nii.gz']);
R2pslice = LoadSlice([fabdir,'rLC_R2p.nii.gz']);
DBV_std  = LoadSlice([fabdir,'std_DBV.nii.gz']);
R2p_std  = LoadSlice([fabdir,'std_R2p.nii.gz']);

% remove zeros, etc
DBVslice = abs(DBVslice(:));
DBVslice(DBVslice == 0) = [];
R2pslice = abs(R2pslice(:));
R2pslice(R2pslice == 0) = [];
DBV_std = abs(DBV_std(:));
DBV_std(DBV_std == 0) = [];
R2p_std = abs(R2p_std(:));
R2p_std(R2p_std == 0) = [];

% std histograms
[nd,ed] = histcounts(DBV_std,100);
cd = (ed(2:end)+ed(1:end-1))./2;
[~,md] = max(nd);

[nr,er] = histcounts(R2p_std,100);
cr = (er(2:end)+er(1:end-1))./2;
[~,mr] = max(nr);

% Display Results
disp(['  Results for ',fdname.name]);
% disp(['Mean DBV: ',num2str(100*mean(DBVslice))]);
disp(['Median DBV: ',num2str(100*median(DBVslice))]);
disp(['DBV Median Error: ',num2str(100*median(DBV_std))]);
disp(['DBV Mode Error: ',num2str(100*cd(md))]);
disp('   ');
disp(['Mean R2'': ',num2str(mean(R2pslice))]);
disp(['Median R2'': ',num2str(median(R2pslice))]);
disp(['R2'' Median Error: ',num2str(median(R2p_std))]);
disp(['R2'' Mode Error: ',num2str(cr(mr))]);


