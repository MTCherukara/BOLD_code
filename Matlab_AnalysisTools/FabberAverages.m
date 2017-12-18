% function FabberAverages(varargin)

clear; clc;

% select a fabber run
fabber = '228';
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';
fdname = dir([resdir,'fabber_',fabber,'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% fabber = '17';
% resdir = '/Users/mattcher/Documents/DPhil/Data/validation_sqbold/results/';
% fdname = dir([resdir,'res_',fabber,'_*']);
% fabdir = strcat(resdir,fdname.name,'/');

slicenum = 3:10;

% Load a mask
maskslice = LoadSlice('/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs7/mask_gm_60.nii.gz',slicenum);

% Load data
DBVslice = LoadSlice([fabdir,'mean_DBV.nii.gz'],slicenum);
R2pslice = LoadSlice([fabdir,'mean_R2p.nii.gz'],slicenum);
% DFslice  = LoadSlice([fabdir,'mean_DF.nii.gz'],slicenum);
% DBV_std  = LoadSlice([fabdir,'std_DF.nii.gz'],slicenum);
% R2p_std  = LoadSlice([fabdir,'std_R2p.nii.gz'],slicenum);

% Mask
% DFslice  = DFslice.*maskslice;
DBVslice = DBVslice.*maskslice;
R2pslice = R2pslice.*maskslice;

% remove zeros, etc
DBVslice = abs(DBVslice(:));
DBVslice(DBVslice == 0) = [];
R2pslice = abs(R2pslice(:));
R2pslice(R2pslice == 0) = [];
% DBV_std = abs(DBV_std(:));
% DBV_std(DBV_std == 0) = [];
% R2p_std = abs(R2p_std(:));
% R2p_std(R2p_std == 0) = [];

% DFslice = abs(DFslice(:));
% DFslice(DFslice == 0) = [];

% % std histograms
% [nd,ed] = histcounts(DBV_std,100);
% cd = (ed(2:end)+ed(1:end-1))./2;
% [~,md] = max(nd);
% 
% [nr,er] = histcounts(R2p_std,100);
% cr = (er(2:end)+er(1:end-1))./2;
% [~,mr] = max(nr);

% Display Results
disp(['  Results for ',fdname.name]);
% disp(['Mean DF  : ',num2str(mean(DFslice))]);
% disp(['Median DF: ',num2str(median(DFslice))]);
% disp(['DBV Median Error: ',num2str(100*median(DBV_std))]);
% disp(['DBV Mode Error: ',num2str(100*cd(md))]);

disp('   ');
disp(['Mean R2''  : ',num2str(mean(R2pslice))]);
disp(['Median R2'': ',num2str(median(R2pslice))]);
% disp(['R2'' Median Error: ',num2str(median(R2p_std))]);
% disp(['R2'' Mode Error: ',num2str(cr(mr))]);

disp('   ');
disp(['Mean DBV  : ',num2str(100*mean(DBVslice))]);
disp(['Median DBV: ',num2str(100*median(DBVslice))]);

% disp('   ');
% disp(['Mean OEF  : ',num2str(100*mean(R2pslice)/(301.74*mean(DBVslice)))]);
% disp(['Median OEF: ',num2str(100*median(R2pslice)/(301.74*median(DBVslice)))]);


