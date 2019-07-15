% PatientAverages.m
%
% Loads the results of FABBER inference on patient data and displays the ROI
% mean OEF, etc. 
%
% Based on FabberAverages.m
%
% Created 12 July 2019
% MT Cherukara
% 
% CHANGELOG:

clear;


%% User Selections

% choose patient (as a string)
p_id = '099';

% choose session (as an integer)
ses = 1;

% choose variables
vars = {'R2p','DBV','OEF'};

% choose slices (keep 1:9)
slicenum = 1:9;


%% Define directories and other things like that

% patient directory
pdir = strcat('/Users/mattcher/Documents/BIDS_Data/qbold_stroke/sourcedata/sub-',p_id,'/');

% session ASE results directory
sdir = strcat(pdir,'ses-00',num2str(ses),'/func-ase/');

% Load session specific ROI
% volROI = LoadSlice([pdir,'ROI_final_s',num2str(ses),'.nii.gz'],slicenum);
volROI = LoadSlice([sdir,'mask_finalROI.nii.gz'],slicenum);


% Load session-specific contralateral GM ROI
volCtr = LoadSlice([sdir,'mask_contraROI.nii.gz'],slicenum);

% Threshold values
threshes = containers.Map({'R2p', 'DBV', 'OEF', 'R2'},...
                          [ 30  ,  1   ,  1   ,  50 ]);  


%% Loop through variables and load them in
% pre-allocate
vecRes = zeros(4*length(vars),1);

for vv = 1:length(vars)
    
    % Identify Variable
    vname = vars{vv};
    
    % Pull out threshold value
    thrsh = threshes(vname); 
    
    % Load the data
    volData = LoadSlice([sdir,'mean_',vname,'.nii.gz'],slicenum);
    
    % Apply ROI mask
    vecData = abs(volData(:).*volROI(:));
    
    % Apply Contralateral mask
   	vecCtr = abs(volData(:).*volCtr(:));
    
    % Identify bad values in ROI and contralateral data
    badData = (vecData == 0) + ~isfinite(vecData) + (vecData > thrsh);
    badCtr  = (vecCtr  == 0) + ~isfinite(vecCtr)  + (vecCtr  > thrsh);
    
    % Remove bad values
    vecData(badData ~= 0) = [];
    vecCtr(badCtr ~= 0) = [];
    
    % convert certain params to percentages
    if ( strcmp( vname,'DBV') || strcmp(vname,'OEF') )
        vecData = vecData.*100;
        vecCtr = vecCtr.*100;
    end
    
    % fill results matrix with means and standard deviations
    vecRes((4*vv)-3) = mean(vecCtr);
    vecRes((4*vv)-2) = std(vecCtr);
    vecRes((4*vv)-1) = mean(vecData);
    vecRes((4*vv) )  = std(vecData);

end % for vv = length(vars)

% display the results
disp(num2str(vecRes'));

