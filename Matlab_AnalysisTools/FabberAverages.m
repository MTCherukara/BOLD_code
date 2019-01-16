% function FabberAverages(fabber)
    % Loads a particular Fabber dataset and displays the average (mean and
    % median) values of R2' and DBV in the top 8 slices.
    %
    % Actively used as of 2018-08-27
    %
    % Changelog:
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
clc;

%% User To Select Fabber Data To Display

% Choose Variables
vars = {'R2p','DBV','OEF'};

% Choose Data set
setnum = 812;

% Which set of subjects is this from?
setname = 'CSF';          % 'VS', 'genF', 'genNF', 'CSF', or 'AMICI'

% do Free energy? - LEAVE THIS AS 0 FOR NOW!!
do_FE = 0;

% do standard deviations
do_std = 1;


%% Initial Stuff

% Results directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';

% Figure out the results directory we want to load from
fdname = dir([resdir,'fabber_',num2str(setnum),'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% Figure out subject and mask number, and such
switch setname
    
    case 'VS'
        
        slicenum = 4:9;
        maskname = 'mask_gm.nii.gz';
        CC = strsplit(fabdir,'_vs');
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
        maskname = 'mask_new_gm_50.nii.gz';
        CC = strsplit(fabdir,'_s');     % need a 2-digit subject number
        subnum = CC{2}(1:2);
        maskdir = ['/Users/mattcher/Documents/DPhil/Data/subject_',subnum,'/'];
               
    case 'genF'
        
        slicenum = 1:6;     % new AMICI protocol FLAIR
        maskname = 'mask_gm_80_FLAIR.nii.gz';
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

% Threshold values
threshes = containers.Map({'R2p', 'DBV', 'OEF', 'VC', 'DF', 'lambda', 'Ax' },...
                          [ 30  ,   1  ,   1  ,  1  ,  15 ,   1     ,  30  ]);  

% Title
disp(['Data from Fabber Set ',num2str(setnum),'. ',setname, ' Subject ',num2str(subnum)]);

% Load mask data
mskData = LoadSlice([maskdir,maskname],slicenum);


%% Loop Through Variables, Displaying Averages:

for vv = 1:length(vars)
    
    % Identify Variable
    vname = vars{vv};
    
    % Pull out threshold value
    thrsh = threshes(vname); 
        
    % Load the data
    volData = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],slicenum);
    
    % Apply Mask and Threshold
    volData = (volData(:).*mskData(:));

    % Load Standard Deviation data
    if do_std
        stdData = LoadSlice([fabdir,'std_' ,vname,'.nii.gz'],slicenum);
        stdData = (stdData(:).*mskData(:));
    end
    
    % Create a mask of values to remove
    badData = (volData == 0) + ~isfinite(volData) + (volData > thrsh);
    if do_std
        badData = badData + ~isfinite(stdData) + (stdData > (thrsh/2)) + (stdData < (thrsh.*1e-3));
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
    
    % calculate IQR
    qnt = quantile(volData,[0.75,0.25]);
    iqr = qnt(1) - qnt(2) ./ 2;
    
%     Display results
%     disp('   ');
%     disp(['Median ',vname,': ',num2str(median(volData),4)]);
%     disp(['   IQR ',vname,': ',num2str(iqr,4)]);
    
    disp('   ');
    disp(['Mean ',vname,'   : ',num2str(mean(volData),4)]);
    if do_std
        disp(['    Std ',vname,': ',num2str(mean(stdData),4)]);
    else
        disp(['    Std ',vname,': ',num2str(std(volData),4)]);
    end

end

%% Free Energy

if do_FE
    [FEData,RData,MData] = MTC_LoadFreeEnergy(setnum,subnum,slicenum);

    disp('   ');
    % disp(['     Mean Residual : ',num2str(mean(RData),4)]);
    disp([' Absolute Residual : ',num2str(mean(abs(RData)),4)]);
    % disp(['   Median Residual : ',num2str(median(RData),4)]);
    % 
    % disp('   ');
    disp(['      Modelfit SNR : ',num2str(mean(MData)./mean(abs(RData)),4)]);

    disp('   ');
    disp(['  Mean Free Energy : ',num2str(-mean(FEData),4)]);
    disp(['Median Free Energy : ',num2str(-median(FEData),4)]);
end