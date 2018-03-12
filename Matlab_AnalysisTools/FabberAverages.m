% function FabberAverages(fabber)
    % Loads a particular Fabber dataset and displays the average (mean and
    % median) values of R2' and DBV in the top 8 slices.
    %
    % Changelog:
    %
    % 12 March 2018 (MTC). Generalization, enabling selection of variables to
    %       plot in a more generic and extensible way.

clear; clc;
% close all;
plot_hists = 0;

% sets of variables
varnames = {'R2p', 'DBV', 'OEF'};
threshld = { 10  ,   1  ,   1  };

% which variables do we want?
vars = 1;

% do we also load in and calculate the standard deviations?
inc_std = 1; 

% slicenum = 3:10;
slicenum = 1:8;

% Data set
setnum = 349;
subnum = 1;
fabber = num2str(setnum+subnum-1);

% select a fabber run
if ~exist('fabber','var')
    fabber = '103';
end

% Find the right directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';
fdname = dir([resdir,'fabber_',fabber,'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% Load a mask
% maskslice = LoadSlice(['/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs',...
%                         num2str(subnum),'/mask_gm_60.nii.gz'],slicenum);
maskslice = LoadSlice('/Users/mattcher/Documents/DPhil/Data/Phantom_743/ASE_mask.nii.gz',slicenum);

% Title
disp(['Data from ',fdname.name]);

for vv = 1:vars
    
    % Identify variables
    vname = varnames{vars(vv)};
    thrsh = threshld{vars(vv)};
    
    % Load the dataset
    Dataslice = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],slicenum);
    
    % Apply mask
    Dataslice = Dataslice.*maskslice;
    
    % Remove zeros and absolutize
    Dataslice = abs(Dataslice(:));
    Dataslice(Dataslice == 0) = [];
    Dataslice(~isfinite(Dataslice)) = [];
    
    % Upper Threshold
    Dataslice(Dataslice > thrsh) = thrsh;
    
    % Standard deviation stuff (doesn't work for OEF)
    if inc_std && ~strcmp(vname,'OEF')
        
        Stdslice = LoadSlice([fabdir,'std_',vname,'.nii.gz'],slicenum);
        Stdslice = Stdslice.*maskslice;
        Stdslice = Stdslice(:);
        Stdslice(Stdslice == 0) = [];
        Stdslice(~isfinite(Stdslice)) = [];
        
    end
    
    % calculate IQR
    Qs = quantile(Dataslice,[0.75,0.25]);
    
    % Display results
    disp('   ');
    disp(['Mean ',vname,'  : ',num2str(mean(Dataslice),4)]);
    disp(['   Std ',vname,': ',num2str(mean(Stdslice),3)]);
    
    disp('   ');
    disp(['Median ',vname,': ',num2str(median(Dataslice),4)]);
    disp(['   ',vname,' IQR: ',num2str((Qs(1)-Qs(2))./2,3)]);
    
end


%% Load in and caluclate free energy if such exists 
freedir = dir([fabdir,'freeEnergy*']);

if ~isempty(freedir)
    
    Fslice = LoadSlice([fabdir,'freeEnergy.nii.gz'],slicenum);
    Fslice = Fslice.*maskslice;
    Fslice = abs(Fslice(:));
    Fslice(Fslice == 0) = [];
    Fslice(~isfinite(Fslice)) = [];
    Fslice = log(Fslice);

    disp('   ');
    disp(['  Log(Free Energy) : ',num2str(-nanmean(Fslice),4)]);
    
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

