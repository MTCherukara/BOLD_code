% function FabberBoxes
    % Loads a bunch of FABBER datasets and displays the resulting parameter
    % estimates as box-plots (see BoxResiduals.m)
    %
    % MT Cherukara
    % 29 January 2017 
    
clear;

% select a variable
vname = 'OEF';      % 'R2p' or 'DBV' or 'OEF'

% select a subject
subj = 6;

% designate FABBER results folders
%         SQ-LS    SQ-VB   1C-VB   1C-VBS  1C-VBI  2C-VB   2C-VBI
fsets = { '101'  , '250' , '208' , '264' , '257' , '201' , '236' ;...   % subject vs1
          '102'  , '251' , '209' , '265' , '258' , '202' , '237' ;...   % subject vs2
          '103'  , '252' , '210' , '266' , '259' , '203' , '238' ;...   % subject vs3
          '104'  , '253' , '211' , '267' , '260' , '204' , '239' ;...   % subject vs4
          '105'  , '254' , '212' , '268' , '261' , '205' , '240' ;...   % subject vs5
          '106'  , '255' , '213' , '269' , '262' , '206' , '241' ;...   % subject vs6
          '107'  , '256' , '214' , '270' , '263' , '207' , '242' };     % subject vs7


% Data set labels
lbls = {'sqBOLD','L-VB-S','1C-VB','1C-VB-S','1C-VB-I','2C-VB','2C-VB-I'};

% choose which datasets we want to view
dset = [1,2,4,7];

fsets = fsets(subj,:);  % pull out subjects
fsets = fsets(dset);     % pull out the samples we actually want
lbls  = lbls(dset);     % take the right labells

% slices
slicenum = 3:10;


%% Load Data
% path
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';

% load mask slice
maskslice = LoadSlice(['/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs',...
                      num2str(subj),'/mask_gm_60.nii.gz'],slicenum);

% define data vector
alldata = [];
lngdata = [];       % for storing the lengths of each dataset
wsk     = [];       % for storing whisker data, for scaling the plot right


% Loop through FABBER sets and load them in
for ii = 1:length(fsets)
    
    fdname = dir([resdir,'fabber_',fsets{ii},'_*']);
    fabdir = strcat(resdir,fdname.name,'/');

    dataslice = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],slicenum);
    
    % apply mask
    dataslice = dataslice.*maskslice;
    
    % remove zeros and vectorise
    dataslice = abs(dataslice(:));
    dataslice(dataslice == 0) = [];

    % remove abberant values, except when inferring R2p
    if ~strcmp(vname,'R2p')
        dataslice(dataslice > 1) = [];
    end
    
    % measure number of points we have
    lngdata = [lngdata; length(dataslice)];
    
    % store whisker data
    wsk = [wsk; quantile(dataslice,[0.25,0.75])];
    
    % add to ALLDATA vector
    alldata = [alldata; dataslice];
    
end


%% Define Groups for Box Plot

grpdata = ones(sum(lngdata),1);

counter = 1;

for ii = 1:length(lngdata)
    
    grpdata(counter:counter+lngdata(ii)-1) = ii;
    counter = counter + lngdata(ii);
    
end


%% Plot

% calculate the y-axis limits
ww = max( wsk(:,2) + 1.5*(wsk(:,2)-wsk(:,1)) );

% make the box-plot
figure('WindowStyle','Docked');
hold on; box on;
h=boxplot(alldata ,grpdata ,...
          'Width' ,  0.60  ,...
          'Notch' ,  'on'  ,...
          'Labels',  lbls );
      
set(h(7,:),'Visible','off');
set(gca,'FontSize',18);
title(['Subject ',num2str(subj)]);

if strcmp(vname,'R2p')
    ylabel('R_2''');
    ylim([-0.5,12.5]);
else
    ylabel(vname);
    if strcmp(vname,'DBV')
        ylim([-0.01,0.31]);
    else
        ylim([-0.05,1.05]);
    end
end




