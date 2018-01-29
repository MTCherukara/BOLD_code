% function FabberBoxes
    % Loads a bunch of FABBER datasets and displays the resulting parameter
    % estimates as box-plots (see BoxResiduals.m)
    
clear; clc;

% select a variable
vname = 'R2p';      % 'R2p' or 'DBV'

% designate FABBER results folders
fsets = {'242';'243'};

% slices
slicenum = 3:10;


%% Load Data
% path
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';

% load mask slice
maskslice = LoadSlice('/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs1/mask_gm_60.nii.gz',slicenum);

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

    % remove abberant DBV values
    if strcmp(vname,'DBV')
        dataslice(dataslice > 1) = [];
    end
    
    % measure number of points we have
    lndata = [lndata; length(dataslice)];
    
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
boxplot(alldata,grpdata,'Width',0.75);
ylabel(vname);
ylim([-0.1,1.1]*ww);
set(gca,'FontSize',16);



