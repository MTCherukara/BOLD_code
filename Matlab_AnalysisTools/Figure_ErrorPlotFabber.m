% Figure_ErrorPlotFabber.m
%
% Plot a figure (for ISMRM 2019 E-poster) showing the distribution of errors,
% comparing simulated ASE data with those obtained from various optimized forms
% of the SDR qBOLD model
%
% MT Cherukara
% 5 April 2019
%
% CHANGELOG:

clear;
% close all;
setFigureDefaults;

% Choose FABBER dataset
setnum = 479;

% Choose what we want to plot
plot_gnd = 0;
plot_est = 1;
plot_err = 1;
plot_rel = 0;

% Variables
vars = {'OEF' , 'DBV' , 'R2p'  };
thrA = [  1.0 ,   1.0 ,  50    ];     % threshold of actual values
cmps = {parula, magma , viridis};


%% Find Directories etc.

% Data directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_ModelFits/';

% Ground truth data directory
gnddir = '/Users/mattcher/Documents/DPhil/Data/qboldsim_data/';

% Figure out the results directory we want to load from
fdname = dir([resdir,'fabber_',num2str(setnum),'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% Parameter values
OEFvals = linspace(0.21,0.7,50);
DBVvals = linspace(0.003,0.15,50);


%% Loop through variables

for vv = 1
    
    vname = vars{vv};

    % Load Ground truth data
    matGnd = LoadSlice([gnddir,'True_Grid_50x50_',vname,'.nii.gz'],1);
    
    % Load data
    matEst = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],1);
    
    % OPTIONALLY scale OEF (this is in xSimScatter.m)
    if strcmp(vname,'OEF')
        matEst = matEst*0.54;
    end
    
    % Threshold
    matEst(matEst > thrA(vv)) = thrA(vv);
    
    % calculate errors
    matErr = matEst - matGnd;
    matRel = matErr ./ matGnd;
    
    % Display Results
    disp(['Mean Absolute ',vname,' Error: ',round2str(mean(abs(matErr(:))),2)]);
    disp(['Mean Relative ',vname,' Error: ',round2str(mean(abs(matRel(:))),2)]);
    
%     mvt = max(max(matGnd(:)),max(matEst(:)));
    mvt = 1;

    % Plot Ground truth data
    if plot_gnd
        
        h_gnd = plotGrid(matGnd,DBVvals,OEFvals,...
                         'cvals',[0,mvt],...
                         'title',['True ',vname],...
                         'cmap',cmps{vv});
    end
    
    % Plot FABBER estimates
    if plot_est
        
        h_est = plotGrid(matEst,DBVvals,OEFvals,...
                         'cvals',[0,mvt],...
                         'title',['Estimated ',vname],...
                         'cmap',cmps{vv});
    end
    
    % Plot Error
    if plot_err
        
        h_err = plotGrid(matErr,DBVvals,OEFvals,...
                         'cvals',[-mvt,mvt],...
                         'title',['Error in ',vname],...
                         'cmap',jet);
    end
    
    % Plot Ground truth data
    if plot_rel
        
        h_gnd = plotGrid(100*matRel,DBVvals,OEFvals,...
                         'cvals',[-100,100],...
                         'title',['Relative Error in ',vname,' (%)'],...
                         'cmap',jet);
    end
    
end % for vv = 1:length(vars)
