% function FabberAverages(fabber)
    % Loads a particular Fabber dataset and displays the average (mean and
    % median) values of R2' and DBV in the top 8 slices.
    %
    % Actively used as of 2019-03-19
    %
    % Changelog:
    %
    % 2019-01-24 (MTC). Brought back the averaging of residuals, free energy,
    %       and model SNR.
    %
    % 2018-11-26 (MTC). Removed the use of MTC_LoadVol.m (now this script just
    %       calls LoadSlice.m directly, in order that it can be generalized to
    %       using masks (etc) from a range of datasets.
    %
    % 2018-07-03 (MTC). Modularized to use MTC_LoadVol (which calls LoadSlice)
    %       to get rid of a bunch of repeated stuff here. Also changed the way
    %       the upper parameter threshold works, so that we now remove voxels
    %       whose values are too high, rather than setting them to an arbitrary
    %       value.
    %
    % 2018-03-12 (MTC). Generalization, enabling selection of variables to plot
    %       in a more generic and extensible way.

    
clear; 
% clc;
close all;

%% User To Select Fabber Data To Display

% Choose Variables
vars = {'R2p','DBV','OEF'};
% vars = {'R2'};

% Choose datasets
sets = 374:379;

% Which set of subjects is this from?
setname = 'genF';          % 'VS', 'genF', 'genNF', 'CSF', 'TRUST', or 'AMICI'

% Options
do_FE = 0;      % do Free energy?
do_std = 0;     % do standard deviations
kappa = 1;
do_tan = 0;
plot_hists = 0;


%% Initial stuff
% Threshold values
threshes = containers.Map({'R2p', 'DBV', 'OEF', 'VC', 'DF', 'lambda', 'Ax' , 'R2'},...
                          [ 30  ,  0.5  ,  2   ,  1  ,  15 ,   1     ,  30  ,  50 ]);  

defaults = containers.Map({'R2p', 'DBV', 'OEF', 'VC', 'DF', 'lambda', 'Ax' , 'R2'},...
                          [ 2.6 , 0.036,  1   , 0.01,  15 ,   1     ,  30  ,  50 ]);  

% Results directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';

% Pre-allocate large arrays
vecOEF = [];
vecR2p = [];
vecDBV = [];


%% Loop through datasets
for setnum = sets
    
    % Pre-allocate results array
    vecRes = zeros(4*length(vars),1);

    %% Initial Stuff

    % Figure out the results directory we want to load from
    fdname = dir([resdir,'fabber_',num2str(setnum),'_*']);
    fabdir = strcat(resdir,fdname.name,'/');

    % Figure out subject and mask number, and such
    switch setname

        case 'VS'

            slicenum = 4:9;
            maskname = 'mask_gm.nii.gz';
            CC = strsplit(fabdir,'_vs');    % need a 1-digit subject number
            subnum = CC{2}(1);
            maskdir = ['/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs',subnum,'/'];

        case 'AMICI'

            slicenum = 3:8;
            maskname = 'mask_GM.nii.gz';
            CC = strsplit(fabdir,'_p');     % need a 3-digit subject number
            subnum = CC{2}(1:3);            
            C2 = strsplit(CC{2},'ses');     % also need a Session Number (1,5)
            sesnum = C2{2}(1);
            maskdir = ['/Users/mattcher/Documents/BIDS_Data/qbold_stroke/sourcedata/sub-',...
                       subnum,'/ses-00',sesnum,'/func-ase/'];

        case 'CSF'

            slicenum = 3:8;
            maskname = 'mask_csf_gm_20.nii.gz';
            CC = strsplit(fabdir,'_s');     % need a 2-digit subject number
            subnum = CC{2}(1:2);
            maskdir = ['/Users/mattcher/Documents/DPhil/Data/subject_',subnum,'/'];

        case 'genF'

            slicenum = 1:6;     % new AMICI protocol FLAIR
            maskname = 'mask_gm_96_FLAIR.nii.gz';
            CC = strsplit(fabdir,'_s');     % need a 2-digit subject number
            subnum = CC{2}(1:2);
            maskdir = ['/Users/mattcher/Documents/DPhil/Data/subject_',subnum,'/'];
            
        case 'TRUST'

            slicenum = 1;     % TRUST data
            maskname = 'mask_trust.nii.gz';
            CC = strsplit(fabdir,'_s');     % need a 2-digit subject number
            subnum = CC{2}(1:2);
            maskdir = ['/Users/mattcher/Documents/DPhil/Data/subject_',subnum,'/'];

        otherwise 

            slicenum = 5:10;    % new AMICI protocol nonFLAIR
            maskname = 'mask_gm_80_nonFLAIR.nii.gz';
            CC = strsplit(fabdir,'_s');     % need a 2-digit subject number
            subnum = CC{2}(1:2);
            maskdir = ['/Users/mattcher/Documents/DPhil/Data/subject_',subnum,'/'];

    end

    % Title
    % disp(['Data from Fabber Set ',num2str(setnum),'. ',setname, ' Subject ',num2str(subnum)]);

    % Load mask data
    mskData = LoadSlice([maskdir,maskname],slicenum);

    % count the number of GM voxels
    ngm = sum(mskData(:) >= 0.5);


    %% Loop Through Variables, Displaying Averages:

    for vv = 1:length(vars)

        % Identify Variable
        vname = vars{vv};

        % Pull out threshold value
        thrsh = threshes(vname); 

        % Pull out default value
        dflt = defaults(vname);

        % Load the data
        volData = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],slicenum);

        % Apply Mask and Threshold (ABSOLUTE VALUE)
        volData = abs(volData(:).*mskData(:));

        % Load Standard Deviation data
        if do_std
            stdData = LoadSlice([fabdir,'std_' ,vname,'.nii.gz'],slicenum);
            stdData = (stdData(:).*mskData(:));
        end

        % Find voxels that are different from the mode
        volDiff = abs(volData - dflt);

        % Create a mask of values to remove
        badData = (volData <= 0) + ~isfinite(volData) + (volData > thrsh) + (volDiff < 0.0001);
        if do_std
            badData = badData + ~isfinite(stdData) + (stdData > (thrsh/2)) + (stdData < (thrsh.*1e-6));
    %         badData = badData + ~isfinite(stdData) ;
        end

        % Remove bad values
        volData(badData ~= 0) = [];
        if do_std
            stdData(badData ~= 0) = [];
        end


        % convert certain params to percentages
        if strcmp(vname,'DBV') || strcmp(vname,'OEF') || strcmp(vname,'VC') || strcmp(vname,'lambda')
            volData = volData.*100;
            if do_std
                stdData = stdData.*100;
            end
        end
        
        % scale OEF by kappa
        if strcmp(vname,'OEF') && (do_tan == 1)
            volData = 12.5.*tan(0.144.*kappa.*volData) + 40.4;
            
            newBad = (volData > 100) + (volData < 0);
            volData(newBad > 0.5) = [];
            
        end
        
        % temporarily save out some results
        if strcmp(vname,'OEF')
            volData(volData < 2.4) = [];
            vecOEF = [vecOEF; volData];
        elseif strcmp(vname,'R2p')
            vecR2p = [vecR2p; volData];
        elseif strcmp(vname,'DBV')
            vecDBV = [vecDBV; volData];
        end

        % calculate IQR
        qnt = quantile(volData,[0.75,0.25]);
        iqr = qnt(1) - qnt(2) ./ 2;

        % calculate and display the number of voxels we had to threshold out
        nkept = length(volData);
        nlost = ngm - nkept;

    %     disp('  ');
    %     disp(vname);
    %     disp(['  Kept ',num2str(nkept),' of ',num2str(ngm),' voxels (',round2str(100*nkept/ngm,1),'%)']);
    %     disp(['  Lost ',num2str(nlost),' of ',num2str(ngm),' voxels (',round2str(100*nlost/ngm,1),'%)']);

        % Display results
    %     disp('   ');
    %     disp(['Median ',vname,': ',num2str(median(volData),4)]);
    %     disp(['   IQR ',vname,': ',num2str(iqr,4)]);

    %     disp('   ');
    %     disp(['Mean ',vname,'   : ',num2str(mean(volData),4)]);
    %     if do_std
    %         disp(['    Std ',vname,': ',num2str(mean(stdData),4)]);
    %     else
    %         disp(['    Std ',vname,': ',num2str(std(volData),4)]);
    %     end

        vecRes((4*vv)-1) = mean(volData);
        if do_std
            vecRes((4*vv)) = mean(stdData);
        else
            vecRes((4*vv)) = std(volData);
        end
%         vecRes((4*vv)-2) = 100*(ngm - length(volData))./ngm;



    end % for vv = length(vars)

    % display the results
    disp(num2str(vecRes'));
    % disp(['Percentage of voxels removed = ',num2str(100*nlost/ngm),'%']);
    % disp(num2str(100*nlost/ngm));

end % for setnum = ...

%% Histograms

if plot_hists
    
    nb = 25;       % number of histogram bins
    
    % Plot R2p
    figure;
    histogram(vecR2p,nb);
    xlabel('R2'' (s^-^1)');
    xlim([0,threshes('R2p')]);
    axis square;
    ylabel('Voxels');
    title('All Subjects, 2C Model');
%     yticks([]);
    
    % Plot DBV
    figure;
    histogram(vecDBV,nb);
    xlabel('^ DBV (%)^ ');
    xlim([0,100*threshes('DBV')]);
    ylabel('Voxels');
    axis square;
    title('All Subjects, 2C Model');
%     yticks([]);
    
    % Plot OEF
    vecOEF(vecOEF > 100) = [];
    vecOEF(vecOEF < 1) = [];
    figure;
    histogram(vecOEF,nb);
    xlabel('^ OEF (%)^ ');
    xlim([0,100]);
    axis square;
    ylabel('Voxels');
    title('All Subjects, 2C Model');
%     yticks([]);
    
end % if plot_hists




%% Free Energy and Residuals

if do_FE
    
    % Load these data
    RData = LoadSlice([fabdir,'residuals.nii.gz'],slicenum);
    
    if do_std
        % For FABBER data that has _std.nii.gz files
        FData = LoadSlice([fabdir,'freeEnergy.nii.gz'],slicenum);
        MData = LoadSlice([fabdir,'modelfit.nii.gz'],slicenum);
    
        % Calculate model SNR
        SData = MData ./ abs(RData);
        
    else
        % Otherwise
        SData = LoadSlice([fabdir,'modelSNR.nii.gz'],slicenum);
    end
    
    % Average residual and SNR over all taus
    RData = mean(RData,4);
    SData = mean(SData,4);
    
    % Apply mask
    RData = (RData(:).*mskData(:));
    SData = (SData(:).*mskData(:));

    % Define bad values (threshold residuals at 100, and FE at 10k
    badData = (RData == 0) + ~isfinite(RData) + (abs(RData) > 100);
    badData = badData + (SData == 0) + ~isfinite(SData) + (SData > 10000);
    
    if do_std
        % if we have Free Energy data
        FData = (FData(:).*mskData(:));
        badData = badData + (FData == 0) + ~isfinite(FData) + (abs(FData) > 10000);
        FData(badData ~= 0) = [];
    end
    
    % Remove bad values
    RData(badData ~= 0) = [];
    SData(badData ~= 0) = [];

    
    disp('   ');
    disp(['     Mean Residual : ',num2str(mean(RData),4)]);
    disp([' Absolute Residual : ',num2str(mean(abs(RData)),4)]);
%     disp(['   Median Residual : ',num2str(median(RData),4)]);
    
%     disp('   ');
%     disp(['      Modelfit SNR : ',num2str(mean(SData),4)]);

    if do_std
        disp('   ');
        disp(['  Mean Free Energy : ',num2str(-mean(FData),4)]);
        disp(['Median Free Energy : ',num2str(-median(FData),4)]);
    end
end

