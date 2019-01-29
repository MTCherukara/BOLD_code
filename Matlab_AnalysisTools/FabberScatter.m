% FabberScatter.m
%
% Loads a particular Fabber dataset and displays a scatter plot of two
% parameters (e.g. OEF-DBV) against each other within a grey matter mask.
% Derived from FabberAverages.m
%
% Created 2019-01-28.
% MT Cherukara
    
clear; 
% close all;
setFigureDefaults;

%% User To Select Fabber Data To Display

% Choose Variables - There should be only two of these!!
vars = {'DBV','OEF'};

% Choose Data set
setnum = 776;

% Which set of subjects is this from?
setname = 'VS';          % 'VS', 'genF', 'genNF', 'CSF', or 'AMICI'

% do we have standard deviation data?
do_std = 0;


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


%% Load and Process Variables

% Load data
vData1 = LoadSlice([fabdir,'mean_',vars{1},'.nii.gz'],slicenum);
vData2 = LoadSlice([fabdir,'mean_',vars{2},'.nii.gz'],slicenum);

% Apply mask
vData1 = vData1(:).*mskData(:);
vData2 = vData2(:).*mskData(:);

% Load Standard deviation data
if do_std
    sData1 = LoadSlice([fabdir,'std_',vars{1},'.nii.gz'],slicenum);
    sData2 = LoadSlice([fabdir,'std_',vars{2},'.nii.gz'],slicenum);
    sData1 = sData1(:).*mskData(:);
    sData2 = sData2(:).*mskData(:);
end

% Create a mask of values to remove
badData =           (vData1 <= 0) + ~isfinite(vData1) + (vData1 > threshes(vars{1}));
badData = badData + (vData2 <= 0) + ~isfinite(vData2) + (vData2 > threshes(vars{2}));

if do_std
    badData = badData + ~isfinite(sData1) + ~isfinite(sData2);
    sData1(badData ~= 0) = [];
    sData2(badData ~= 0) = [];
end

% Remove values
vData1(badData ~= 0) = [];
vData2(badData ~= 0) = [];

% Convert certain parameters to percentages
if strcmp(vars{1},'DBV') || strcmp(vars{1},'OEF')
    vData1 = vData1.*100;
end
if strcmp(vars{2},'DBV') || strcmp(vars{2},'OEF')
    vData2 = vData2.*100;
end
    
%% Calculate mean and median
mn1 = mean(vData1);
mn2 = mean(vData2);
md1 = median(vData1);
md2 = median(vData2);


%% Make scatter plot

figure; hold on; box on;
scatter(vData1,vData2,'k.');
xlabel(vars{1});
ylabel(vars{2});
axis([0,20,0,70]);
% axis([0,20,0,10]);

% Plot mean and median as lines
plot([0,20],[mn2,mn2],'r-');
plot([0,20],[md2,md2],'b--');
plot([mn1,mn1],[0,70],'r-');
plot([md1,md1],[0,70],'b--');