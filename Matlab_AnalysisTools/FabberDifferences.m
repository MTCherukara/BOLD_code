% FabberDifferences

% Loads maps of one parameter from a pair of FABBER datasets and displays the
% difference between them, as well as some potentially interesting stats.

% MT Cherukara
% 8 February 2019

clear;

%% User to select variable and Fabber datasets

% which VS subject
set0 = 3;

% variable name
vname = 'DBV';
setname = 'VS';
fsets = [914, 921] + set0;  % 1C first, then 2C
msize = 64;     % matrix size


%% Basics (copied from voxelwise_anova.m)

% Results directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';

% Look at the first dataset in order to figure out which mask to load
set1 = fsets(1);
fdname = dir([resdir,'fabber_',num2str(set1),'_*']);
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

% Load mask data
mskData = LoadSlice([maskdir,maskname],slicenum);

% Pre-allocate
inData = zeros(msize,msize,length(slicenum),2);


%% Load the data

for ss = 1:2 % loop through two sets
    
    snum = fsets(ss);
    
    % Find the right directory
    fdname = dir([resdir,'fabber_',num2str(snum),'_*']);
    fabdir = strcat(resdir,fdname.name,'/'); 
    
    % Load the data
    volData = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],slicenum);

    % Apply mask
%     volData = abs(volData.*mskData);
    
    % Put it in the matrix
    inData(:,:,:,ss) = abs(volData);
    
end


%% Analysis

% Pull out threshold
thrsh = threshes(vname);

% Subtract (2C - 1C) 
diffData = inData(:,:,:,2) - inData(:,:,:,1);

% Now vectorize, for calculating numbers
vec1 = reshape(inData(:,:,:,1),[],1).*mskData(:);
vec2 = reshape(inData(:,:,:,2),[],1).*mskData(:);
vecD = reshape(diffData,[],1).*mskData(:);

% Create array of bad values to remove
badVec = (vec1 == 0) + (vec2 == 0) + ~isfinite(vec1) + ~isfinite(vec2) + ...
          (vec1 > thrsh) + (vec2 > thrsh);

% Remove bad values
vec1(badVec ~= 0) = [];
vec2(badVec ~= 0) = [];
vecD(badVec ~= 0) = [];

% convert certain params to percentages
if strcmp(vname,'DBV') || strcmp(vname,'OEF') || strcmp(vname,'VC') || strcmp(vname,'lambda')
    vec1 = vec1.*100;
    vec2 = vec2.*100;
    vecD = abs(vecD.*100);
end

% calculate and display means and standard deviations
disp(['1C Mean',vname,' = ',num2str(mean(vec1),3),' +/- ',num2str(std(vec1),3),' %']);
disp(['2C Mean',vname,' = ',num2str(mean(vec2),3),' +/- ',num2str(std(vec2),3),' %']);
disp(['Mean Difference ',vname,' = ',num2str(mean(vecD),3),' +/- ',num2str(std(vecD),3),' %']);


%% Prepare difference map montage (adapted from BrainMontage.m)

% shave
sh_sds = 12;        % sides
sh_top = 4;         % top and bottom

diffData = diffData(1+sh_sds:end-sh_sds,1+sh_top:end-sh_top,:);

% work out the new sizes
sv = size(diffData);

% Number of slices
ns = size(diffData,3);

% for even slices, create a 2xN grid
if mod(ns,2) == 0
    nrows = 2;
    ncols = ns/2;

% for 4 or fewer slices, use a single row
elseif ns < 5
    nrows = 1;
    ncols = ns;

    
% for odd multiples of 3, create a 3xN grid
elseif mod(ns,3) == 0
    nrows = 3;
    ncols = ns/3;
    
% for other numbers, use a single row
else
    nrows = 1;
    ncols = ns;
end

% pre-allocate matrix
montage_image = zeros(nrows*sv(2),ncols*sv(1));

% fill montage matrix
pos_r = 1;
pos_c = 1;

% loop through slices
for ii = 1:ns
    
    % Fill the slice in the montage_image
    montage_image(pos_c:pos_c+sv(2)-1,pos_r:pos_r+sv(1)-1) = squeeze(diffData(:,:,ii))';
    
    % Move on to the next starting point
    pos_r = pos_r + sv(1);
    if pos_r > sv(1)*ncols
        pos_c = pos_c + sv(2);
        pos_r = 1;
    end
end

% flip montage_image
montage_image = fliplr(montage_image);


%%  Display Figure
cmp = parula;
cmp(1,:) = [0,0,0];

figure; hold on;
imagesc(abs(montage_image),[0.0,0.2]);
colormap(cmp);
axis equal

% colorbar;
set(gca,'Visible','off')
set(gca,'LooseInset',get(gca,'TightInset'));
