% xSimScatter.m

% Make a scatter plot of FABBER inference of simulated data

% MT Cherukara
% 5 December 2018

% Actively used as of 2019-01-10

clear;
% close all;
% setFigureDefaults;

clc;

% Choose variables
vars = {'OEF','DBV','R2p'};
% vars = {'OEF'};

% Do we have STD data?
do_std = 0;

% Do we want a figure?
plot_fig = 1;

% Data directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_ModelFits/';
setnum = 163; % 292 then 278, then 285

% Standard Deviation Thresholds
thrR = 10.0;
thrD = 1.0;

% Figure out the results directory we want to load from
fdname = dir([resdir,'fabber_',num2str(setnum),'_*']);
fabdir = strcat(resdir,fdname.name,'/');

disp(' ');
disp(['Opening dataset ',fdname.name,':']);

% Ground truth data is stored here
gnddir = '/Users/mattcher/Documents/DPhil/Data/qboldsim_data/';

% Load ground truth data for both OEF and DBV
oefData = LoadSlice([gnddir,'ASE_Grid_50x50_OEF.nii.gz'],1);
dbvData = LoadSlice([gnddir,'ASE_Grid_50x50_DBV.nii.gz'],1);
r2pData = LoadSlice([gnddir,'ASE_Grid_50x50_R2p.nii.gz'],1);

gndMat = [oefData(:),dbvData(:),r2pData(:)];
sclMat = [dbvData(:),oefData(:),r2pData(:)];

% Pre-allocate some result arrays
corrs = zeros(length(vars),2);
RMSE  = zeros(length(vars),1);
WMSE  = zeros(length(vars),1);      % weighted root mean square error
RELE  = zeros(length(vars),1);

% if we have std data, load it and mask out bad voxels
if do_std
    
    stdR = LoadSlice([fabdir,'std_OEF.nii.gz'],1);
    stdD = LoadSlice([fabdir,'std_DBV.nii.gz'],1);
    
    threshmask = (stdR > thrR) + (stdD > thrD);
    threshVec = threshmask(:) > 0.5;
    
end % if do_std


% Load the arrays of true OEF and DBV values

% Loop through variables
for vv = 1:length(vars)
    
    % Identify variable
    vname = vars{vv};
    
    % Load the data, Take Absolute Values and Vectorize
    volData = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],1);
    volVec = abs(volData(:));
    if do_std
        stdData = LoadSlice([fabdir,'std_' ,vname,'.nii.gz'],1);
        stdVec = abs(stdData(:));
    end
    
    % Extract ground truth data, and the other data, for scaling
    gndVec = gndMat(:,vv);
    sclVec = sclMat(:,vv);
    
    if strcmp(vname,'DBV') || strcmp(vname,'OEF')
        volVec = volVec.*100;
        gndVec = gndVec.*100;
    end
    
    % Limits, for plotting
    minV = gndVec(1);
    maxV = gndVec(end);
    
    % Remove data points whose standard deviation is too high
    if do_std
        volVec(threshVec) = [];
        gndVec(threshVec) = [];
        sclVec(threshVec) = [];
        stdVec(threshVec) = [];
    end
    
    % Colour the results based on the log of their standard deviation
    if do_std
        ln_std = -log(stdVec);
        nm_std = ln_std + abs(min(ln_std));     % normalized log standard deviation
        nm_std = nm_std./max(nm_std);
    end
    
    shades = sclVec;
%     shades = [0,0,0];
%     shades = nm_std;
    
    % Calculate correlations
    [R,P] = corrcoef(gndVec,volVec);
    corrs(vv,:) = [R(1,2), P(1,2)];
    
    % Calculate root mean square error
    diffs = gndVec - volVec;
%     RMSE(vv) = sqrt(mean(diffs.^2));
    RMSE(vv) = mean(abs(gndVec - volVec));
    RELE(vv) = 100*mean(abs(gndVec - volVec)./gndVec);
    
    if do_std
        wdiff = diffs.*nm_std;
        WMSE(vv) = sqrt(mean(wdiff.^2));
    end
    
    % Plot a figure;
    if plot_fig
        figure; hold on; box on;
        plot([minV,maxV],[minV,maxV],'Color',defColour(2));
        colormap(parula);
        scatter(gndVec,volVec,[],shades,'filled');
        xlabel(['Simulated ',vname,' (%)']);
        ylabel(['Estimated ',vname,' (%)']);
        axis([minV,maxV,minV,maxV]);    % always go from 0% to 100% in the figure
    end
    
    % Display some results
    disp(' ');
    disp([vname,' Correlation: ',num2str(R(1,2),3)]);
    if P(1,2) > 0.05
        disp(['    Not Significant (p = ',num2str(P(1,2),2),')']);
    end
    disp(['  RMS Error:  ',num2str(RMSE(vv),3),' %']);
    disp(['  Rel. Error: ',num2str(RELE(vv),3),' %']);
%     if do_std
%         disp(['  Weighted Error: ',num2str(WMSE(vv),3),' %']);
%     end
    
end % for vv = 1:length(vars)


% Print the number of bad voxels we had to remove
if do_std
    disp(' ');
    disp(['(Excluded ',num2str(sum(threshVec)),' of 2500 data points)']);
end
    
% % Also do Free Energy
% thFE = 1e6;
% volFE = LoadSlice([fabdir,'freeEnergy.nii.gz'],1);
% vecFE = volFE(:);
% vecFE(abs(vecFE) > thFE) = [];
% 
% disp(' ');
% disp(['Free Energy (Mean)  : ',num2str(-mean(vecFE),3)]);
% disp(['Free Energy (Median): ',num2str(-median(vecFE),3)]);