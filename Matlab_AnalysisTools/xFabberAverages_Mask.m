% xFabberAverages_Mask.m

% A version of FabberAverages.m intended to loop around different mask values
% and spit out some useful data more quickly.

% Created: 19 March 2019
    
clear; 
clc;

%% Selected Data

% Choose Variable (just one)
vname = 'DBV';

% Choose Data set
for setnum = 816:830
    
% Mask names
maskbase = 'mask_new_gm_';
masknums = {'99','80','8099','60','5080','50'};


%% Initial Stuff

% Results directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';

% Figure out the results directory we want to load from
fdname = dir([resdir,'fabber_',num2str(setnum),'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% Figure out subject number, and such        
slicenum = 3:8;
maskname = 'mask_new_gm_99.nii.gz';
CC = strsplit(fabdir,'_s');     % need a 2-digit subject number
subnum = CC{2}(1:2);
maskdir = ['/Users/mattcher/Documents/DPhil/Data/subject_',subnum,'/'];
         

% Threshold values
threshes = containers.Map({'R2p', 'DBV', 'OEF', 'VC', 'DF', 'lambda', 'Ax' },...
                          [ 50  ,  1   ,  1   ,  1  ,  15 ,   1     ,  30  ]);  

% Title
% disp(['Data from Fabber Set ',num2str(setnum),'. Subject ',num2str(subnum)]);


%% Load the Data

% Pull out threshold value
thrsh = threshes(vname);

% Load the data
rawData = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],slicenum);


%% Loop Through Masks, Displaying Average:

% Length of loop
nm = length(masknums);

% pre-allocate
vecMeans = zeros(1,nm);
vecStdvs = zeros(1,nm);

for mm = 1:nm
    
    % Compose mask name
    maskname = strcat(maskbase,masknums{mm},'.nii.gz');
    
    % Load Mask data
    mskData = LoadSlice([maskdir,maskname],slicenum);

    % count the number of GM voxels
    ngm = sum(mskData(:) >= 0.5);
    
    % Apply Mask and Threshold (ABSOLUTE VALUE)
    volData = (rawData(:).*mskData(:));
  
    % Create a mask of values to remove
    badData = (volData <= 0) + ~isfinite(volData) + (volData > thrsh);
    
    % Remove bad values
    volData(badData ~= 0) = [];    
   
    % convert certain params to percentages
    if strcmp(vname,'DBV') || strcmp(vname,'OEF') || strcmp(vname,'VC') || strcmp(vname,'lambda')
        volData = volData.*100;
    end
    
    % calculate and display the number of voxels we had to threshold out
    nkept = length(volData);
    nlost = ngm - nkept;
    
    % store results
    vecMeans(mm) = mean(volData);
    vecStdvs(mm) = std(volData);
    
end


%% Print Results

% condense Means and STDs into a single line
matAll = [vecMeans; vecStdvs];

% Display
disp(num2str(matAll(:)'));

end