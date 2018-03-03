% function FabberAverages(fabber)
    % Loads a particular Fabber dataset and displays the average (mean and
    % median) values of R2' and DBV in the top 8 slices.

clear; clc;
% close all;
plot_hists = 0;

% select a fabber run
if ~exist('fabber','var')
    fabber = '336';
end

% load data
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';
fdname = dir([resdir,'fabber_',fabber,'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% fabber = '17';
% resdir = '/Users/mattcher/Documents/DPhil/Data/validation_sqbold/results/';
% fdname = dir([resdir,'res_',fabber,'_*']);
% fabdir = strcat(resdir,fdname.name,'/');

slicenum = 3:10;

% Load a mask
maskslice = LoadSlice('/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs1/mask_gm_60.nii.gz',slicenum);


%% Load data
DBVslice = LoadSlice([fabdir,'mean_DBV.nii.gz'],slicenum);
R2pslice = LoadSlice([fabdir,'mean_R2p.nii.gz'],slicenum);
% DFslice  = LoadSlice([fabdir,'mean_DF.nii.gz'],slicenum);
DBV_std  = LoadSlice([fabdir,'std_DBV.nii.gz'],slicenum);
R2p_std  = LoadSlice([fabdir,'std_R2p.nii.gz'],slicenum);

% Mask
% DFslice  = DFslice.*maskslice;
DBVslice = DBVslice.*maskslice;
R2pslice = R2pslice.*maskslice;

% remove zeros, etc
DBVslice = abs(DBVslice(:));
DBVslice(DBVslice == 0) = [];
R2pslice = abs(R2pslice(:));
R2pslice(R2pslice == 0) = [];
DBV_std = (DBV_std(:));
DBV_std(DBV_std == 0) = [];
R2p_std = (R2p_std(:));
R2p_std(R2p_std == 0) = [];


%% Load in and caluclate free energy if such exists 
freedir = dir([fabdir,'freeEnergy*']);

if ~isempty(freedir)
    Fslice = LoadSlice([fabdir,'freeEnergy.nii.gz'],slicenum);
    Fslice = Fslice.*maskslice;
    Fslice = abs(Fslice(:));
    Fslice(Fslice == 0) = [];
    Fslice(~isfinite(Fslice)) = [];
    Fslice = log(Fslice);
end

    
%% Display Results
disp(['  Results for ',fdname.name]);
% disp(['Mean DF  : ',num2str(mean(DFslice))]);
% disp(['Median DF: ',num2str(median(DFslice))]);


disp('   ');
% disp(['Mean R2''  : ',num2str(mean(R2pslice))]);
disp(['Median R2'': ',num2str(median(R2pslice))]);
R2Q = quantile(R2pslice,[0.75,0.25]);
disp(['   R2'' Mean Error  : ',num2str(nanmean(R2p_std))]);
disp(['   R2'' IQR: ',num2str((R2Q(1)-R2Q(2))./2)]);
% disp(['R2'' Median Error: ',num2str(median(R2p_std))]);

disp('   ');
% disp(['Mean DBV  : ',num2str(100*mean(DBVslice))]);
disp(['Median DBV: ',num2str(100.*median(DBVslice))]);
DBQ = quantile(DBVslice,[0.75,0.25]);
disp(['   DBV Mean Error  : ',num2str(100*nanmean(DBV_std))]);
disp(['   DBV IQR: ',num2str(50.*(DBQ(1)-DBQ(2)))]);
% disp(['DBV Median Error: ',num2str(100*median(DBV_std))]);

disp('   ');
% disp(['Mean OEF  : ',num2str(100*mean(R2pslice)/(301.74*mean(DBVslice)))]);
disp(['Median OEF: ',num2str(100*median(R2pslice)/(301.74*median(DBVslice)))]);


%% Free Energy
if ~isempty(freedir)
    disp('   ');
    disp(['  Log(Free Energy) : ',num2str(-nanmean(Fslice))]);
end


%% Histograms

if plot_hists
    setFigureDefaults;
    
    nb = 25;            % number of bins
    thr = [0.2,10];     % thresholds [DBV, R2p]

    % apply threshold by removing voxels that are too high
    DBVslice(DBVslice > thr(1)) = [];
    R2pslice(R2pslice > thr(2)) = [];

    figure; hold on; box on;
    histogram(100*DBVslice,nb);
    xlabel('DBV_ ');

    figure; hold on; box on;
    histogram(R2pslice,nb);
    xlabel('R_2''');

end

