% xSimScatter.m
%
% Make a scatter plot of FABBER inference of simulated data
%
% MT Cherukara
% 5 December 2018
%
% Actively used as of 2019-02-13
%
% Changelog:
%
% 2019-03-21 (MTC). Made the results print out in a way that they can be copied
%       straight into FabberAverages.xls
%
% 2019-02-13 (MTC). Changed the way the loop works so instead we load all the
%       data in upfront, in order to generate a mask of "bad values" to remove.

clear;
close all;
% setFigureDefaults;

% clc;

% Choose variables
vars = {'OEF', 'DBV', 'R2p'};
thrA = [  5.0,   2.0,  50  ];     % threshold of actual values
thrS = [  5.0,   2.0,  50  ];     % threshold of standard deviations
% vars = {'OEF'};

% choose dataset
for setnum = 463
    
% Do we have STD data?
do_std = 0;

% Do we want a figure?
plot_fig = 1;


%% Find directories, and load ground truth data and stuff
% Data directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_ModelFits/';

% Figure out the results directory we want to load from
fdname = dir([resdir,'fabber_',num2str(setnum),'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% disp(' ');
% disp(['Opening dataset ',fdname.name,':']);

% Ground truth data is stored here
gnddir = '/Users/mattcher/Documents/DPhil/Data/qboldsim_data/';

% Load ground truth data for both OEF and DBV
volOEF = LoadSlice([gnddir,'True_Grid_50x50_OEF.nii.gz'],1);
volDBV = LoadSlice([gnddir,'True_Grid_50x50_DBV.nii.gz'],1);
volR2p = LoadSlice([gnddir,'True_Grid_50x50_R2p.nii.gz'],1);

matGnd = [volOEF(:),volDBV(:),volR2p(:)];
matScl = [volDBV(:),volOEF(:),volDBV(:)];


%% Loop through and load the actual data

% Pre-allocate storage arrays
matAll = zeros(size(matGnd,1),length(vars));
matStd = zeros(size(matGnd,1),length(vars));
vecBad = zeros(size(matGnd,1),1);
vecRes = zeros(3*length(vars),1);

% Loop through variables
for vv = 1:length(vars)
    
    % Identify variable
    vname = vars{vv};
    
    % Load the data
    volData = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],1);
    
    % OPTIONALLY scale OEF
    if strcmp(vname,'OEF')
%         volData = volData*0.44;
    end
      
    % take the absolute value and store it 
    matAll(:,vv) = (volData(:));
    
    % apply threshold mask
    vecBad = vecBad + ~isfinite(matAll(:,vv)) + ( matAll(:,vv) > thrA(vv) );
    
    % load and store standard deviation data
    if do_std
        volStd = LoadSlice([fabdir,'std_',vname,'.nii.gz'],1);
        matStd(:,vv) = volStd(:);
        
        % add to threshold mask
        vecBad = vecBad + ( matStd(:,vv) > thrS(vv) );
    end
    
end % for vv = 1:length(vars)



%% Now remove the bad voxels from the whole array

% Define bad voxels
vecThres = vecBad > 0.5;

% Remove bad voxels
matAll(vecThres,:) = [];
matStd(vecThres,:) = [];
matGnd(vecThres,:) = [];
matScl(vecThres,:) = [];


%% Now loop through the variables again and display the results

% Pre-allocate some result arrays
corrs = zeros(length(vars),2);
RMSE  = zeros(length(vars),1);
WMSE  = zeros(length(vars),1);      % weighted root mean square error
RELE  = zeros(length(vars),1);

for vv = 1:length(vars)
    
    % Identify variable
    vname = vars{vv};
    
    % Extract relevant data from storage arrays
    vecData = matAll(:,vv);
    vecStd = matStd(:,vv);
    vecGnd = matGnd(:,vv);
    vecScl = matScl(:,vv);
        
    if strcmp(vname,'DBV') || strcmp(vname,'OEF')
        vecData = vecData.*100;
        vecGnd = vecGnd.*100;
    end
    
    % Limits, for plotting
    minV = vecGnd(1);
    maxV = vecGnd(end);
    
    % Colour the results based on the log of their standard deviation
    if do_std
        ln_std = -log(vecStd);
        nm_std = ln_std + abs(min(ln_std));     % normalized log standard deviation
        nm_std = nm_std./max(nm_std);
    end
    
    shades = vecScl;
%     shades = [0,0,0];
%     shades = nm_std;

    % Calculate correlations
    [R,P] = corrcoef(vecGnd,vecData);
    corrs(vv,:) = [R(1,2), P(1,2)];
    
    % Calculate root mean square error
    diffs = vecGnd - vecData;
%     RMSE(vv) = sqrt(mean(diffs.^2));
    RMSE(vv) = mean(abs(vecGnd - vecData));
    RELE(vv) = 100*mean(abs(vecGnd - vecData)./vecGnd);
    
    if do_std
        wdiff = diffs.*nm_std;
        WMSE(vv) = sqrt(mean(wdiff.^2));
    end
    
    % Plot a figure;
    if plot_fig
        figure; hold on; box on;
        plot([minV,maxV],[minV,maxV],'Color',defColour(2));
        colormap(parula);
        scatter(vecGnd,vecData,[],shades,'filled');
        xlabel(['Simulated ',vname,' (%)']);
        ylabel(['Estimated ',vname,' (%)']);
        axis([minV,maxV,minV,maxV]);    % always go from 0% to 100% in the figure
        if strcmp(vname,'OEF')
            axis([minV,maxV,0,100]);
        end
    end
    
    % Store the results
    vecRes((3*vv)-2) = R(1,2);
    vecRes((3*vv)-1) = RMSE(vv);
    vecRes((3*vv)  ) = RELE(vv);
    
    % Display some results
%     disp(' ');
%     disp([vname,' Correlation: ',num2str(R(1,2),3)]);
%     if P(1,2) > 0.05
%         disp(['    Not Significant (p = ',num2str(P(1,2),2),')']);
%     end
%     disp(['  RMS Error:  ',num2str(RMSE(vv),3),' %']);
%     disp(['  Rel. Error: ',num2str(RELE(vv),3),' %']);
% %     if do_std
% %         disp(['  Weighted Error: ',num2str(WMSE(vv),3),' %']);
% %     end
    
end % for vv = 1:length(vars)


% Print the number of bad voxels we had to remove
% disp(' ');
% disp(['(Excluded ',num2str(sum(vecThres)),' of 2500 data points)']);

% Display the whole results row entry
disp(num2str(vecRes(:)'));

end % for setnum = ....
    
% % Also do Free Energy
% thFE = 1e6;
% volFE = LoadSlice([fabdir,'freeEnergy.nii.gz'],1);
% vecFE = volFE(:);
% vecFE(abs(vecFE) > thFE) = [];
% 
% disp(' ');
% disp(['Free Energy (Mean)  : ',num2str(-mean(vecFE),3)]);
% disp(['Free Energy (Median): ',num2str(-median(vecFE),3)]);