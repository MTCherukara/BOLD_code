% xDiceCoeff.m
%
% Loads a partial volume estimate image from two subjects, binarizes them, and
% then calculates the Dice Similarity Coefficient (DSC) of the two
%
% MT Cherukara
% 10 June 2019
%
% CHANGELOG:

clear;

%% USER SPECIFICATIONS

% Define subject name
subnum = '09';

% Define partial volume map names
mapnames = {'CSF_T1w','CSF_T2seg','CSF_T2fit_new','CSF_contrast'};

% Define binary thresholds
threshes = [0.05, 0.20, 0.40, 0.60, 0.80, 0.95];

% Options
logit = 0;      % Caluclate logit(DSC)
display = 0;    % Print out the results


%% FIXED PARAMETERS

% Directory
mapdir = ['/Users/mattcher/Documents/DPhil/Data/subject_',subnum,'/'];

% slices
slicenum = 3:8;

% numbers of things
nmap = length(mapnames);
nthr = length(threshes);


%% LOAD DATA

% Print heading
if display
    disp(['Subject ',subnum]);
end

% Load brain mask
vec_mask = mat2vec(LoadSlice([mapdir,'mask_FLAIR.nii.gz'],slicenum));

% number of voxels
nvox = sum(vec_mask);

% Pre-allocate matrix of all map data
mat_all = zeros(nvox,nmap);

% Loop through MAPNAMES and load each one
for mm = 1:nmap
    
    % Load it up
    vec_map = mat2vec(LoadSlice([mapdir,mapnames{mm},'.nii.gz'],slicenum));
    
    % Remove non-brain voxels
    vec_map(vec_mask == 0) = [];
    
    % Store it
    mat_all(:,mm) = vec_map;
    
end


%% BINARIZE
% Pre-allocate logical matrix for all binary maps
mat_binary = false(nvox,nmap,nthr);

% Loop through THRESHES and create binarized masks
for tt = 1:nthr
    
    % define threshold
    thr = threshes(tt);
    
    % binarize
    mat_bmap = mat_all > thr;
    
    % store
    mat_binary(:,:,tt) = mat_bmap;
    
end


%% COMPARE

% determine number of pairs
inds = 1:nmap;
% pairs = flipud(combnk(inT1ds,2));
pairs = [1,4; 2,4; 3,4];
npairs = size(pairs,1);

% Pre-allocate DSC results
DSC = zeros(npairs,nthr);

% Loop through pairs of MAPNAMES and compare them
for pp = 1:npairs
    
    % Pick the numbers we want to compare
    x1 = pairs(pp,1);
    x2 = pairs(pp,2);
    
    % Pull out names
    mapn1 = mapnames{x1};
    mapn2 = mapnames{x2};
    
    % Name
    if display
        disp(['   Comparing ',mapn1,' and ',mapn2,':']);
    end
    
    for tt = 1:nthr
        
        % Pull out the maps we want to compare
        map1 = double(mat_binary(:,x1,tt));
        map2 = double(mat_binary(:,x2,tt));
    
        % Calculate Dice Similarity Coefficient
        vec_intr = ~(map1 - map2);
        DSC(pp,tt) = sum(vec_intr)./nvox;

        % Optionally, transform to Logit
        if logit
            DSC(pp,tt) = log(DSC(pp,tt)./(1-DSC(pp,tt)));
        end

        % Display results
        if display
            disp(['      DSC at ',num2str(100*threshes(tt)),'% = ',num2str(DSC(pp,tt))]);
        end
        
    end % for tt = 1:nthr
    
end % for pp = 1:npairs

if display == 0
    disp(DSC')
end