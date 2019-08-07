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
% close all;
setFigureDefaults;

% clc;

% Choose variables
% vars = {'OEF'};
vars = {'OEF', 'DBV', 'R2p'};
thrA = [  1.0,   1  , 100  ];     % threshold of actual values
thrS = [ 10.0,   5.0, 100  ];     % threshold of standard deviations
minG = [    0,  0.0,  0   ];     % minimum value ground truth 
% vars = {'OEF'};

kappa = 1;

% dHb = 0.0361 * R2p;

text_title = '';

% Do we have STD data?
do_std = 0;

% Do we want a figure?
plot_fig = 1;
plot_grid = 0;
print_res = 0;

% choose dataset
for setnum = 723
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
    % volOEF = LoadSlice([gnddir,'True_Grid_50x50_OEF.nii.gz'],1);
    % volDBV = LoadSlice([gnddir,'True_Grid_50x50_DBV.nii.gz'],1);
    % volR2p = LoadSlice([gnddir,'True_Grid_50x50_R2p.nii.gz'],1);
    load(['../Matlab_VesselSim/Sim_OEF_DBV_pairs_1.mat']);
    volOEF = OEFvals(:)';
    volDBV = DBVvals(:)';
    volR2p = 355.*volOEF.*volDBV;

    matGnd = [volOEF(:),volDBV(:),volR2p(:)];
    matScl = [volDBV(:),volOEF(:),volR2p(:)];
    Sclabels = {'DBV (%)','OEF (%)','dHb content (ml/100g)'};


    %% Loop through and load the actual data

    % Pre-allocate storage arrays
    matAll = zeros(size(matGnd,1),length(vars));
    matStd = zeros(size(matGnd,1),length(vars));
    vecBad = zeros(size(matGnd,1),1);
    vecRes = zeros(3*length(vars),1);

    resp = zeros(length(vars),2);

    % Loop through variables
    for vv = 1:length(vars)

        % Identify variable
        vname = vars{vv};

        % Load the data
        volData = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],1);
    %     volData = volData(2:1:50,1:34);
    %     volData = volData(:,35:50);

    %     if strcmp(vname,'DBV') || strcmp(vname,'OEF')
    %         resp(vv,1) = 100.*volData(20,10);
    %         resp(vv,2) = 100.*volData(40,40);
    %     else
    %         resp(vv,1) = volData(20,10);
    %         resp(vv,2) = volData(40,40);
    %     end


        % OPTIONALLY scale OEF
        if strcmp(vname,'OEF')
            volData = volData*kappa;
        end

        vecGnd = matGnd(:,vv);
        vecScl = matScl(:,vv);

        % take the absolute value and store it 
        matAll(:,vv) = (volData(:));
        
        volMode = mode(matAll(:,vv));
        volDiff = abs(matAll(:,vv) - volMode);

        % apply threshold mask
        vecBad = vecBad + ~isfinite(matAll(:,vv)) + ( matAll(:,vv) > thrA(vv) ) ...
                        + (volDiff < 0.00001);

        % mask out minimum values
        vecBad = vecBad + (matGnd(:,vv) < minG(vv));

%         if strcmp(vname,'DBV')
%             vecBad = vecBad + (vecGnd > 0.1) + (vecGnd < 0.01);
%         end
    
%         if strcmp(vname,'OEF')
%             vecBad = vecBad + (vecScl > 0.095) + (vecScl < 0.005);
%         end

        % load and store standard deviation data
        if do_std
            volStd = LoadSlice([fabdir,'std_',vname,'.nii.gz'],1);
    %         volStd = volStd(2:1:50,1:34);
            matStd(:,vv) = volStd(:);

            % add to threshold mask
            vecBad = vecBad + ( matStd(:,vv) > thrS(vv) );
        end

    end % for vv = 1:length(vars)

    % % calculate RESP errors
    % tru4 = [ 40, 60; 3, 12; volR2p(20,10), volR2p(40,40)];
    % err4 = tru4' - resp';
    % disp(num2str(err4(:)'));


    %% Now remove the bad voxels from the whole array

    % Define bad voxels
    vecThres = vecBad > 0.5;

    % % Remove bad voxels
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
            vecScl = vecScl.*100;
        elseif strcmp(vname,'R2p')
            % Converting R2' to dHb
            vecData = vecData.*0.0361;
            vecGnd = vecGnd.*0.0361;
            vecScl = vecScl.*0.0361;
        end
        
        if strcmp(vname,'OEF')
            
%             newBad = vecData > 22;
%             vecData(newBad > 0.5) = [];
%             vecGnd(newBad > 0.5) = [];
%             vecScl(newBad > 0.5) = [];
%             
%             vecO = kappa*matAll(:,1)./(3.55*matAll(:,2));
%             vecData = 3.76.*tan(0.063.*vecData) + 20.2;
%             
%             newBad = (vecData > 100) + (vecData < 0);
%             vecData(newBad > 0.5) = [];
%             vecGnd(newBad > 0.5) = [];
%             vecScl(newBad > 0.5) = [];
            
        end
            

        % Limits, for plotting
        minV = min(vecGnd);
        maxV = max(vecGnd);

        % Colour the results based on the log of their standard deviation
        if do_std
            ln_std = -log(vecStd);
            nm_std = ln_std + abs(min(ln_std));     % normalized log stdv
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
    %     RELE(vv) = std(abs(vecGnd - vecData));
        RELE(vv) = 100*mean(abs(vecGnd - vecData)./abs(vecGnd));
        
        if strcmp(vname,'R2p')
            err_R2p = abs(diffs);
        elseif strcmp(vname,'DBV')
            err_DBV = abs(diffs);
        elseif strcmp(vname,'OEF')
            err_OEF = abs(diffs);
        end

        if do_std
            wdiff = diffs.*nm_std;
            WMSE(vv) = sqrt(mean(wdiff.^2));
        end

        if strcmp(vname,'R2p')
            vlabel = 'dHb content (ml/100g)';
    %         vlabel = vname;
        else
            vlabel = strcat(vname,' (%)');
        end

        % Plot a figure;
        if plot_fig
            figure; hold on; box on; grid on; axis square;
            plot([0,maxV],[0,maxV],'-k');
            scatter(vecGnd,vecData,[],shades,'filled');
            xlabel(['True ',vlabel]);
            ylabel(['Estimated ',vlabel]);
            title(text_title);
            if strcmp(vname,'OEF')
                axis([0,100,0,100]);
                colormap(plasma);
                caxis([0,10])
            elseif strcmp(vname,'DBV')
                axis([0,10,0,10]);
                colormap(parula);
                caxis([0,100])
            else
                axis([minV,maxV,minV,maxV]); 
                colormap(viridis);
            end
            cb = colorbar;
            ylabel(cb,['True ',Sclabels{vv}]);
            set(cb,'FontSize',20);
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

    % % Display the whole results row entry
    if print_res
        disp(num2str(vecRes(:)'));
    end

    if plot_grid

        % pull out estimates from the matrix
        matR2p = reshape(matAll(:,3),50,50);
        matOEF = reshape(matAll(:,1),50,50);

        OEFvals = 0.21:0.01:0.70;
        DBVvals = 0.003:0.003:0.15;

        % calculate errors
        errR2p = matR2p - volR2p;
        errOEF = matOEF - volOEF;

        % convert R2' to dHb
        errR2p = 0.0361*errR2p;

    %     % Plot R2' error
        R_err = plotGrid(errR2p,100*DBVvals,100*OEFvals,...
                         'cvals',[-0.5,0.5],...
                         'title','Error in R2''');


        % Plot OEF error
    %     O_err = plotGrid((100*errOEF),100*DBVvals,100*OEFvals,...
    %                      'cvals',[-50,50],...
    %                      'title','Error in OEF');

        % axes
        xlim([1,10]);
        ylim([21,60]);
        xlabel('True DBV (%)');
        ylabel('True OEF (%)');
    end

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


%% Plot R2' and OEF error on surfaces

