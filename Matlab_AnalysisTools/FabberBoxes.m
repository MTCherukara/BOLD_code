% function FabberBoxes
    % Loads a bunch of FABBER datasets and displays the resulting parameter
    % estimates as box-plots (see BoxResiduals.m)
    %
    % MT Cherukara
    % 29 January 2017 
    
clear;

save_plot = 0;

% since we are doing plotting here
setFigureDefaults;

% select a variable
vname = 'DBV';      % 'R2p' or 'DBV' or 'OEF'

% select a subject
ss = 7;

% designate FABBER results folders
%         SQ-LS    SQ-VB   1C-VB   1C-VBS  1C-VBI  2C-VB   2C-VBI  2C-VBTC  2C-VBSI
fsets = { '101'  , '250' , '208' , '264' , '257' , '201' , '236' , '281'  , '291' ;...   % subject vs1
          '102'  , '251' , '209' , '265' , '258' , '202' , '237' , '282'  , '292' ;...   % subject vs2
          '103'  , '252' , '210' , '266' , '259' , '203' , '238' , '283'  , '293' ;...   % subject vs3
          '104'  , '253' , '211' , '267' , '260' , '204' , '239' , '284'  , '294' ;...   % subject vs4
          '105'  , '254' , '212' , '268' , '261' , '205' , '240' , '285'  , '295' ;...   % subject vs5
          '106'  , '255' , '213' , '269' , '262' , '206' , '241' , '286'  , '296' ;...   % subject vs6
          '107'  , '256' , '214' , '270' , '263' , '207' , '242' , '287'  , '297' };     % subject vs7


% Data set labels
lbls = {'sqBOLD','L-VB','1C-VB','1C-VB-S','1C-VB-I','2C-VB','2C-VB-I','2C-VB-TC','2C-VB-S-I'};
% lbls = {'sqBOLD','Linear VB','NO','Dynamic TC','Fixed TC','Dynamic TC-I','Fixed TC-I'};


% choose which datasets we want to view
dset = [1,3,5,4];

fsets = fsets(ss,:);  % pull out subjects
fsets = fsets(dset);     % pull out the samples we actually want
lbls  = lbls(dset);     % take the right labells

% slices
slicenum = 3:10;


%% Load Data
% path
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';

% load mask slice
maskslice = LoadSlice(['/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs',...
                      num2str(ss),'/mask_gm_60.nii.gz'],slicenum);

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
figure; hold on; box on;
h=boxplot(alldata ,grpdata ,...
          'Width' ,  0.60  ,...
          'Notch' ,  'on'  ,...
          'Labels',  lbls );
      
set(h(7,:),'Visible','off');
title(['Subject ',num2str(ss)]);

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

if save_plot
    export_fig(strcat('Bar_Subject_',num2str(ss),'_',vname,'.pdf'));
end


