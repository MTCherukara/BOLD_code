% function FabberAverages(fabber)
    % Loads a particular Fabber dataset and displays the average (mean and
    % median) values of R2' and DBV in the top 8 slices.
    %
    % Actively used as of 2018-05-11
    %
    % Changelog:
    %
    % 12 March 2018 (MTC). Generalization, enabling selection of variables to
    %       plot in a more generic and extensible way.

clear; 
clc;
% close all;
plot_hists = 0;

% sets of variables
varnames = {'R2p', 'DBV', 'OEF', 'VC', 'DF', 'lambda'};
threshld = { 10  ,   1  ,   1  ,  1  ,  15 ,   1     };


% which variables do we want?
vars = [1,2,3,4];
% do we also load in and calculate the standard deviations?
inc_std = 1; 

% slicenum = 3:10;    % VS
slicenum = 2:8;     % CSF + patient data
% slicenum = 2:9;
% slicenum = 1:6;   % TR = 2

% Data set
setnum = 490;
subnum = 1;
msknum = 9;     % this is used for the CSF datasets
fabber = num2str(setnum+subnum-1);

% select a fabber run
if ~exist('fabber','var')
    fabber = '103';
end

% Find the right directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';
fdname = dir([resdir,'fabber_',fabber,'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% % Load a mask - VS version
% maskslice = LoadSlice(['/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs',...
%                         num2str(subnum),'/mask_gm_60.nii.gz'],slicenum);

% Load a mask - CSF version
maskslice = LoadSlice(['/Users/mattcher/Documents/DPhil/Data/subject_0',...
                        num2str(msknum),'/mask_FLAIR_GM.nii.gz'],slicenum);
                    
% % Load a mask - other versions
% maskslice = LoadSlice('/Users/mattcher/Documents/DPhil/Data/Phantom_743/ASE_mask.nii.gz',slicenum);
% maskslice = LoadSlice('/Users/mattcher/Documents/DPhil/Data/subject_08/mask_MASE_gm.nii.gz',slicenum);
% maskslice = LoadSlice('/Users/mattcher/Documents/DPhil/Data/patient_01/PATIENT_24h_ROI_mask.nii.gz',slicenum);

% Title
disp(['Data from ',fdname.name]);

for vv = 1:length(vars)
    
    % Identify variables
    vname = varnames{vars(vv)};
    thrsh = threshld{vars(vv)};
    
    % Load the dataset
    Dataslice = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],slicenum);
    
    % Apply mask and take absolute values, vecotrize
    Dataslice = Dataslice.*maskslice;
    Dataslice = abs(Dataslice(:));
    
    % Create mask of values to remove
    Badslice = (Dataslice == 0) + ~isfinite(Dataslice);
    
    % Standard deviation
    if inc_std
        
        % Load, Mask, and Vectorize
        Stdslice = LoadSlice([fabdir,'std_',vname,'.nii.gz'],slicenum);
        Stdslice = Stdslice.*maskslice;
        Stdslice = Stdslice(:);
        
        % Add to mask voxels where the standard deviation is NaN, or greater
        % than the threshold, or very low, and ignore those voxels
        Badslice = Badslice + ~isfinite(Stdslice) + (Stdslice > thrsh) + (Stdslice < (thrsh.*1e-3));
        
        % Remove bad values
        Stdslice(Badslice ~= 0) = [];
        
        % Threshold standard deviations
        Stdslice(Stdslice < 1e-3) = 1e-3;
        
        % convert certain params to percentages
        if strcmp(vname,'DBV') || strcmp(vname,'OEF') || strcmp(vname,'VC') || strcmp(vname,'lambda')
            Stdslice = Stdslice.*100;
        end
    end
    
    % Remove bad values
    Dataslice(Badslice ~= 0) = [];
    
    % Upper Threshold
    Dataslice(Dataslice > thrsh) = thrsh;
   
    % convert certain params to percentages
    if strcmp(vname,'DBV') || strcmp(vname,'OEF') || strcmp(vname,'VC') || strcmp(vname,'lambda')
        Dataslice = Dataslice.*100;
    end
    
    
    % calculate IQR
    Qs = quantile(Dataslice,[0.75,0.25]);
    
    % calculate precision-weighted mean
%     Precslice = 1./(Stdslice.^2);
%     wmean = sum(Precslice.*Dataslice)/sum(Precslice);
    
    % Display results
    disp('   ');
%     disp(['Median ',vname,': ',num2str(median(Dataslice),4)]);
%     disp(['   ',vname,' IQR: ',num2str((Qs(1)-Qs(2))./2,4)]);
    
%     disp('   ');
    disp(['Mean ',vname,'   : ',num2str(mean(Dataslice),4)]);
%     disp(['Wt Mean ',vname,': ',num2str(wmean,4)]);
    if strcmp(vname,'VC')
        disp(['    Std ',vname,': ',num2str(std(Dataslice),4)]);
    else
        disp(['    Std ',vname,': ',num2str(mean(Stdslice),4)]);
    end
    
    
end


%% Load in and caluclate free energy if such exists 
disp('   ');
freedir = dir([fabdir,'freeEnergy*']);

if ~isempty(freedir)
    
    Fslice = LoadSlice([fabdir,'freeEnergy.nii.gz'],slicenum);
    Fslice = Fslice.*maskslice;
    Fslice = (Fslice(:));
    Fslice(Badslice ~= 0) = [];
    FreeEnergy = (nanmedian((Fslice)));

    disp(['  Free Energy : ',num2str(FreeEnergy,4)]);
    
end

%% Load in and calculate Residuals if such exists
resdir = dir([fabdir,'residual*']);

if ~isempty(resdir)
    
    Rslice = LoadSlice([fabdir,'residuals.nii.gz'],slicenum);
    NV = size(Rslice,4);
    Rslice = Rslice.*repmat(maskslice,1,1,1,NV);
    Rslice = abs(Rslice(:));
    Bigbad = repmat(Badslice == 0,1,NV);
    Rslice(~Bigbad) = [];
    Rslice(Rslice > 100) = [];
    Residual = (nanmean((Rslice)));

    disp(['    Residual  : ',num2str(Residual,4)]);

end


%% Histograms - got to sort this one out a bit

if plot_hists
%     setFigureDefaults;
    
    nb = 40;            % number of bins
    thr = [0.2,10];     % thresholds [DBV, R2p]

    % apply threshold by removing voxels that are too high
    DBVslice(DBVslice > thr(1)) = [];
    R2pslice(R2pslice > thr(2)) = [];

    figure; hold on; box on;
    histogram(100*DBVslice,nb);
    xlabel('_ DBV_ ');
    ylabel('Voxels');
    axis([0, 19, 0, 125]);

    figure; hold on; box on;
    histogram(R2pslice,nb);
    xlabel('R_2''');
    ylabel('Voxels');
    axis([0, 9.5, 0, 125]);

end

