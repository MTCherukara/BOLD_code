% xSimScatter.m

% Make a scatter plot of FABBER inference of simulated data

% MT Cherukara
% 5 December 2018

clear;
close all;
setFigureDefaults;

% Choose variables
vars = {'OEF','DBV'};

% Data directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_ModelFits/';
setnum = 121;

% Figure out the results directory we want to load from
fdname = dir([resdir,'fabber_',num2str(setnum),'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% Ground truth data is stored here
gnddir = '/Users/mattcher/Documents/DPhil/Data/qboldsim_data/';

% Loop through variables
for vv = 1%:length(vars)
    
    % Identify variable
    vname = vars{vv};
    
    % Load the data
    volData = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],1);
    stdData = LoadSlice([fabdir,'std_' ,vname,'.nii.gz'],1);
    
    % Load the ground truth data
    gndData = LoadSlice([gnddir,'ASE_Grid_30x30_',vname,'.nii.gz'],1);
    
    % Take Absolute Values and Vectorize, also, scale up to a percentage
    volVec = 100*abs(volData(:));
    stdVec = 100*abs(stdData(:));
    gndVec = 100*abs(gndData(:));
    
    minV = gndVec(1);
    maxV = gndVec(end);
    
    % Colour the results based on the log of their standard deviation
    ln_std = -log(stdVec);
    
    % Calculate correlations
    [R,P] = corrcoef(gndVec,volVec);
    
    % Plot a figure;
    figure; hold on; box on;
    plot([minV,maxV],[minV,maxV],'Color',defColour(2));
    colormap(gray);
    scatter(gndVec,volVec,[],ln_std,'filled');
    xlabel(['Simulated ',vname,' (%)']);
    ylabel(['Estimated ',vname,' (%)']);
    axis([minV,maxV,minV,maxV]);    % always go from 0% to 100% in the figure
    
end
    
    
    