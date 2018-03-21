% function SaveFabberAverages(setnum)
    % Loads a set of FABBER datasets (beginning at number SEETNUM) and 
    % caluclates volume averages (mean and median) of chosen parameters.
    %
    % Based on FabberAverages.m
    %
    % MT Cherukara
    % 21 March 2018

clear;
% close all;

% sets of variables
varnames = {'R2p', 'DBV', 'OEF'};
threshld = { 10  ,   1  ,   1  };

% which variables do we want?
vars = [1,2,3];

% How many Datasets
nsets = 7;

% Slices
slicenum = 3:10;

% Data set
setnum = 403;

% Directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';

% Pre-allocate Data Arrays
data_avgs = zeros(nsets,length(vars),2);
data_errs = zeros(nsets,length(vars),2);
data_free = zeros(nsets);

% Loop through result folders in the set
for ff = 1:nsets
    
    % Identify the run number
    fabber = num2str(setnum+ff-1);
    
    % Find the right directory
    fdname = dir([resdir,'fabber_',fabber,'_*']);
    fabdir = strcat(resdir,fdname.name,'/');

    % Load a mask
    maskslice = LoadSlice(['/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs',...
                            num2str(ff),'/mask_gm_60.nii.gz'],slicenum);

	% Loop through variables
    for vv = 1:length(vars)

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

        % convert certain params to percentages
        if strcmp(vname,'DBV') || strcmp(vname,'OEF')
            Dataslice = Dataslice.*100;
        end

        % Standard deviation stuff (doesn't work for OEF)
        if ~strcmp(vname,'OEF')

            Stdslice = LoadSlice([fabdir,'std_',vname,'.nii.gz'],slicenum);
            Stdslice = Stdslice.*maskslice;
            Stdslice = Stdslice(:);
            Stdslice(Stdslice == 0) = [];
            Stdslice(~isfinite(Stdslice)) = [];

            % convert certain params to percentages
            if strcmp(vname,'DBV')
                Stdslice = Stdslice.*100;
            end

        end

        % calculate IQR
        Qs = quantile(Dataslice,[0.75,0.25]);
        
        % Calculate and store Averages
        data_avgs(ff,vv,1) = mean(Dataslice);       % mean
        data_avgs(ff,vv,2) = median(Dataslice);     % median
        if ~strcmp(vname,'OEF')
            data_errs(ff,vv,1) = mean(Stdslice);        % standard deviation
        end
        data_errs(ff,vv,2) = (Qs(1)-Qs(2))/2;       % interquartile range / 2
        
  
%         % Display results
%         if ~strcmp(vname,'OEF')
%             disp(['Mean ',vname,'  : ',num2str(mean(Dataslice),4),' +/- ',num2str(mean(Stdslice),3)]);
%         else
%             disp(['Mean ',vname,'  : ',num2str(mean(Dataslice),4)]);
%         end
%         disp(['Median ',vname,': ',num2str(median(Dataslice),4),' +/- ',num2str((Qs(1)-Qs(2))./2,3)]);

    end % for vv = 1:length(vars)



%% Load in and caluclate free energy if such exists 
    freedir = dir([fabdir,'freeEnergy*']);

    if ~isempty(freedir)

        Fslice = LoadSlice([fabdir,'freeEnergy.nii.gz'],slicenum);
        Fslice = Fslice.*maskslice;
        Fslice = abs(Fslice(:));
        Fslice(Fslice == 0) = [];
        Fslice(~isfinite(Fslice)) = [];
        Fslice = log(Fslice);

        % Store free energy
        data_free(ff) = nanmean(Fslice);
    end
    
end % for ff = 1:nsets

% Save Results
savename = ['Fabber_Data_',num2str(setnum),'-',num2str(setnum+nsets-1),'.mat'];
save(savename,'data_avgs','data_errs','data_free');