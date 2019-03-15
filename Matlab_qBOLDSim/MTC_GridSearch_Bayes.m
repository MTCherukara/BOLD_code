% MTC_GridSearch_Bayes.m
%
% Perform Bayesian inference on ASE qBOLD data from qASE.m using a 2D grid
% search. Requires qASE_model.m, which should all be in the same folder.
% Also requires a .mat file of simulated ASE qBOLD data produced by qASE.m
%
% 
%       Copyright (C) University of Oxford, 2016-2018
%
% 
% Created by MT Cherukara, 17 May 2016
%
% CHANGELOG:
%
% 2018-12-04 (MTC). Added functionality to loop over the same dataset, adding
%       noise and recalculating multiple times. And added stuff for saving out
%       the results more comprehensively.
%
% 2018-07-16 (MTC). Parallelized using parfor, on a 6-core i5, this achieves a
%       greater than four-fold speed-up. On a dual-core i5 (MacBook Pro), this
%       is roughly a 50% speed-up. Functionality for 1D and ND grid search has
%       been lost, but this can be added in later.
%
% 2018-03-29 (MTC). Added the means for displaying the locations of the maximum
%       values produced by a 2D grid search.
%
% 2018-02-12 (MTC). Went back to 'param_update' since it is actually much
%       faster. Removed the 3D grid search code because it was taking up space
%       (it will be in the repository somewhere).
%
% 2018-02-05 (MTC). Removed the need for the 'param_update' function. Fixed a
%       bug in the 1D grid search method.
%
% 2018-01-12 (MTC). Changed the way the posterior is calculated to actually
%       calculate log-likelihood, using the function MTC_loglike.m. This
%       technically shouldn't alter the shape of any of the posterior
%       distributions (in terms of their linearity) but should mean that our
%       selected value of SNR is 'applied' to the results correctly.
%
% 2017-10-06 (MTC). Added the option to make a 3D grid search, and made the
%       1D and 2D versions slightly more general (and less cumbersome) by
%       vectorising here and there.
%
% 2017-08-07 (MTC). Added R2'/DBV inference, and made the whole thing better
%       organised. The 1D grid search isn't working right, but it isn't
%       particularly important at this stage.
%
% 2017-04-04 (MTC). Various changes.

clear;
% close all;

% setFigureDefaults;  % since we're doing plotting later

% Options
plot_fig = 1;
save_data = 0;

% Add noise?
SNR = 100;              % For no noise: SNR = inf;

% For looping over multiple datasets:
OEFs = 20:20:80;
DBVs = 1:2:9;
[gOEF,gDBV] = meshgrid(OEFs,DBVs);

% Parameters
% pnames = { 'R2p'    ; 'zeta'      };
% interv = [ 0.2, 15  ; 0.003, 0.15 ];
% np     = [ 1000     ; 1000        ];

% pnames = { 'OEF'    ; 'zeta'     };
% interv = [ 0.2, 0.7 ; 0.003, 0.15 ];
% np     = [ 1000     ; 1000       ];

% pnames = { 'lam0'    ; 'zeta'      };
% interv = [ 0.01, 0.2 ; 0.003, 0.15 ];
% np     = [ 1000      ; 1000        ];

pnames = { 'lam0'    ; 'dF'     };
interv = [ 0.01, 0.2 ; 1, 15 ];
np     = [ 1000     ; 1000       ];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%    Initialization          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nj = length(OEFs)*length(DBVs);
maxes = zeros(2,nj);
for jj = 1%:nj

    tic;
    
    % Load the Data: 
    load('ASE_Data/Data_190315_40_3_CSFreal.mat');
    
    
%     vOEF = num2str(gOEF(jj));     % only useful when looping over things
%     vDBV = num2str(gDBV(jj));
%
%     load(['ASE_Data/Data_181204_',vOEF,'_',vDBV,'_SNR_50.mat']);
%     disp(['Analysing Dataset ',num2str(jj), ' of ',num2str(nj)]);
% 
%     % Choose which tau values we want
%     taus = -28:4:64;
%     taus = [-28:4:-20,0,28:4:64];
% 
%     % pull out the right values
%     samps = find(ismember(T_sample,taus./1e3));
%     T_sample  = T_sample(samps);
%     TE_sample = TE_sample(samps);
%     S_sample  = S_sample(samps);


    ns = length(S_sample); % number of data points
    if ~exist('S_total','var')
        S_total = S_sample;
    end
    
    % Add Random Gaussian Noise
    sigma = mean(S_total)./SNR;
%     S_total = S_total + sigma.*randn(1,ns);
    S_sample = S_total ./ max(S_total);


    % Specifically for testing critical tau. 
    params.tc_man = 0;
    params.tc_val = 0.024;
    
    % Model selection
    params.model = 'Asymp';  % should the asymptotic tissue model be used?
    params.incIV = 1;

    % extract relevant parameters
    params.R2p = params.dw.*params.zeta;

    % fill in TE if necessary
    if ~exist('TE_sample','var')
        TE_sample = params.TE;
    end


    % are we inferring on R2'?
    if any(strcmp(pnames,'R2p'))
        params.contr = 'R2p';
    else
        params.contr = 'OEF';
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%    1D Line Search          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Inference
    if length(pnames) == 1
        disp('1D Grid Search currently unsupported');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%    2D Grid Search          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif length(pnames) == 2
        % Bayesian Inference on two parameters, using grid search

        % pull out parameter names
        pn1 = pnames{1};
        pn2 = pnames{2};

        np1 = np(1);
        np2 = np(2);

        % find true values of parameters
        trv(1) = eval(['params.',pn1]); % true value of parameter 1
        trv(2) = eval(['params.',pn2]); % true value of parameter 2

        % generate parameter distributions
        pv1 = linspace(interv(1,1),interv(1,2),np1);
        pv2 = linspace(interv(2,1),interv(2,2),np2);

        pos = zeros(np(1),np(2));

        parfor i1 = 1:np1
            % loop through parameter 1

            % create a parameters object
            looppars = updateParams(pv1(i1),params,pn1);
            posvec = zeros(1,np2);

            pv22 = pv2; % to avoid using pv2 as a broadcast variable

            for i2 = 1:np2
                % loop through parameter 2

                % create a parameters object
                inpars = updateParams(pv22(i2),looppars,pn2);

                % run the model to evaluate the signal with current params            
                S_mod = qASE_model(T_sample,TE_sample,inpars);

                % normalize
                S_mod = S_mod./max(S_mod);

                % calculate posterior based on known noise value
                posvec(i2) = calcLogLikelihood(S_sample,S_mod,sigma);

            end % for i2 = 1:np2

            pos(i1,:) = posvec;

        end % parfor i1 = 1:np1

    end % length(pars) == 1 ... elseif 

    toc;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%    Display Results         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Display

    if plot_fig
        % create docked figure
        figure; hold on; box on;

        % Plot 2D grid search results
        surf(pv2,pv1,exp(pos));
        view(2); shading flat;
        axis square;
        c=colorbar;
        colormap(flipud(magma));
        plot3([trv(2),trv(2)],[  0, 1000],[1e40,1e40],'k-');
        plot3([  0, 1000],[trv(1),trv(1)],[1e40,1e40],'k-');

        % outline
        plot3([pv2(  1),pv2(  1)],[pv1(  1),pv1(end)],[1,1],'k-','LineWidth',0.75);
        plot3([pv2(end),pv2(end)],[pv1(  1),pv1(end)],[1,1],'k-','LineWidth',0.75);
        plot3([pv2(  1),pv2(end)],[pv1(  1),pv1(  1)],[1,1],'k-','LineWidth',0.75);
        plot3([pv2(  1),pv2(end)],[pv1(end),pv1(end)],[1,1],'k-','LineWidth',0.75);
        
        % x axis - DBV
        if strcmp(pn2,'zeta')
            xticks(0.01:0.02:0.15);
            xticklabels({'1','3','5','7','9','11','13','15'});
            xlabel('DBV (%)');
        else
            xlabel(pn2);
        end
        
        % y axis - OEF
        if strcmp(pn1,'OEF')
            yticks(0.2:0.1:0.7);
            yticklabels({'20','30','40','50','60','70'});
            ylabel('OEF (%)');
        elseif strcmp(pn1,'R2p')
            ylabel('R_2'' (s^-^1)');
        else
            ylabel(pn1);
        end
        
        ylabel(c,'Posterior Probability Density');
        axis([min(pv2),max(pv2),min(pv1),max(pv1)]);
        set(gca,'YDir','normal');
        set(c,'FontSize',18);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%    Maxima Analysis         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Find maxima
    % Calculate distribution's maximum position in 2D
    [V2G,V1G] = meshgrid(pv2,pv1);
    [~,mi] = max(pos(:));

    % Save out maximum location
    maxes(1,jj) = V1G(mi);
    maxes(2,jj) = V2G(mi);

    % % Display maximum information
    % disp('  ');
    % disp([  'R2p = ',num2str(params.R2p),...
    %     ', DBV = ',num2str(100*params.zeta)]);
    % disp(['  Maximum ',pnames{1},': ',num2str(V1G(mi),4)]);
    % disp(['  Maximum ',pnames{2},': ',num2str(100*V2G(mi),4)]);
    
    
    %% Save Data
    if save_data
        sddir = '../../Data/GridSearches/';
        sdname = strcat('TEST_GridSearch_OEF_',vOEF,'_DBV_',vDBV,'.mat');
        save([sddir,sdname],'params','pos','pv1','pv2','S_sample','T_sample','TE_sample');
    end
    
end % for jj = 1:nj

% save('GridMaxima_1.mat','taus','maxes','params');

